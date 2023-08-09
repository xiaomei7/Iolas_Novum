import SwiftUI

struct Today: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @FetchRequest(
        entity: GoalEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var goals: FetchedResults<GoalEntity>
    
    @Environment(\.self) var env
    @StateObject var activityModel: ActivityViewModel = .init()
    @StateObject var todoModel: TodoViewModel = .init()
    @StateObject var goalModel: GoalViewModel = .init()
    @EnvironmentObject var userModel: UserViewModel
    
    @State private var isEditNavigationActive = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Today")
                .thicccboi(18, .bold)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Menu {
                        NavigationLink(destination: AddActivity().environmentObject(activityModel)) {
                            Text("Add Activity")
                        }
                        
                        NavigationLink(destination: TagManagement(isSelectionMode: false, onTagSelected: { _ in })) {
                            Text("Add Tag")
                        }
                        
                        NavigationLink(destination: AddGoal().environmentObject(goalModel)) {
                            Text("Add Goal")
                        }
                    } label: {
                        Label(
                            title: { Text("") },
                            icon: { Image(systemName: "plus.circle").foregroundColor(Color("DarkGreen")) }
                        )
                    }
                }
                .padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
                Text("Activity")
                    .thicccboi(16, .thin)
                    .foregroundColor(Color("Gray"))
                Divider()
                    .overlay(Color("DarkGreen"))
                
                VStack(spacing: 0) {
                    ForEach(activities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                
                Text("Todo")
                    .thicccboi(16, .thin)
                    .foregroundColor(Color("Gray"))
                Divider()
                    .overlay(Color("DarkGreen"))
                
                VStack(spacing: 0) {
                    ForEach(todoModel.todos, id: \.id) { todo in
                        TodoCard(todo: todo)
                            .onTapGesture {
                                let isComplete = !isTodoCompleted(todo: todo)
                                withAnimation(.linear) {
                                    if isComplete {
                                        userModel.points += todo.reward
                                    } else {
                                        userModel.points -= todo.reward
                                    }
                                    if userModel.updatePoints(context: env.managedObjectContext) {
                                        todoModel.updateTodoCompletionStatus(todo: todo, isComplete: isComplete, context: env.managedObjectContext)
                                        todoModel.fetchAndFilterTodos(context: env.managedObjectContext)
                                    }
                                }
                            }
                    }
                }
                
                Text("Goals")
                    .thicccboi(16, .thin)
                    .foregroundColor(Color("Gray"))
                Divider()
                    .overlay(Color("DarkGreen"))
                
                VStack(spacing: 0) {
                    ForEach(goals, id: \.id) { goal in
                        GoalCard(goal: goal)
                            .padding(.vertical)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                todoModel.addOrEditTodo.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Cream"))
                    .frame(width: 55, height: 55)
                    .background(Color("DarkGreen").shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: Circle())
            })
            .padding(15)
        })
        .sheet(isPresented: $todoModel.addOrEditTodo, onDismiss: {
            todoModel.fetchAndFilterTodos(context: env.managedObjectContext)
        }) {
            AddTodo()
                .environmentObject(todoModel)
                .presentationCornerRadius(30)
                .presentationBackground(Color("LightBrown"))
        }
        .onAppear {
            todoModel.fetchAndFilterTodos(context: env.managedObjectContext)
            goalModel.updateCurrentValue(for: Date(), context: env.managedObjectContext, userModel: userModel)
        }
    }
}


struct Today_Previews: PreviewProvider {
    static var previews: some View {
        Today()
    }
}

extension Today {
    @ViewBuilder
    func ActivityCard(activity: ActivityEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(activity.name ?? "Name")
                    .thicccboi(18, .bold)
                
                Spacer()
                
                NavigationLink(destination: AddActivity().environmentObject(activityModel)) {
                    Image(systemName: "pencil")
                }.simultaneousGesture(TapGesture().onEnded {
                    activityModel.editActivity = activity
                    activityModel.restoreEditData()
                })
                
            }
            
            Text(activity.describe ?? "Description")
                .thicccboi(14, .regular)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(activity.tags! as! Set<TagEntity>), id: \.id) { tag in
                        TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(activity.color ?? "PresetColor-1").opacity(0.7))
                
                Rectangle()
                    .fill(Color(activity.color ?? "PresetColor-1"))
                    .frame(height: 5)
            }
        }
        .cornerRadius(10)
        .padding()
    }
    
    @ViewBuilder
    private func TodoCard(todo: TodoEntity) -> some View {
        if todo.frequency?.isEmpty ?? true || Date().isInWeekday(todo.frequency ?? []) {
            HStack {
                Image(systemName: isTodoCompleted(todo: todo) ? "checkmark.circle" : "circle")
                    .foregroundColor(isTodoCompleted(todo: todo) ? .green : .red)
                Text(todo.name ?? "")
                Spacer()
            }
            .thicccboi(16, .regular)
            .padding(.vertical, 8)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func GoalCard(goal: GoalEntity) -> some View {
        VStack {
            if let cycle = GoalCycle(rawValue: goal.cycle ?? "") {
                switch cycle {
                case .daily, .weekly, .monthly, .yearly:
                    HStack(alignment: .center) {
                        Text(goal.name ?? "Goal Name")
                            .thicccboi(12, .regular)
                        Text("\((goal.cycle ?? "unkown").capitalized) Goal")
                            .thicccboi(12, .thin)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(goal.activities as? Set<ActivityEntity> ?? []), id: \.self) { activity in
                                ActivityStub(activity: activity, hasDelete: false, activities: .constant(Set<ActivityEntity>()))
                            }
                            ForEach(Array(goal.tags as? Set<TagEntity> ?? []), id: \.self) { tag in
                                TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                            }
                        }
                    }
                    ProgressView(value: min(goal.currentValue, goal.aim), total: goal.aim) // TODO: style this progress bar
                case .single:
                    HStack(alignment: .center) {
                        Text(goal.name ?? "Goal Name")
                            .thicccboi(12, .regular)
                        Text("Until \(goal.dueDate?.formatToString("dd MMM yyyy") ?? Date().formatToString("dd MMM yyyy"))")
                            .thicccboi(12, .thin)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(goal.activities as? Set<ActivityEntity> ?? []), id: \.self) { activity in
                                ActivityStub(activity: activity, hasDelete: false, activities: .constant(Set<ActivityEntity>()))
                            }
                            ForEach(Array(goal.tags as? Set<TagEntity> ?? []), id: \.self) { tag in
                                TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                            }
                        }
                    }
                    ProgressView(value: goal.currentValue, total: goal.aim)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func isTodoCompleted(todo: TodoEntity) -> Bool {
        if let completionDate = (todo.completionDates as? Set<TodoCompletionDates>)?.first(where: { Calendar.current.isDateInToday($0.date!) }) {
            return completionDate.isComplete
        } else {
            return false
        }
    }
}
