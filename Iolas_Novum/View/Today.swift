//
//  Today.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

struct Today: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @Environment(\.self) var env
    @StateObject var activityModel: ActivityViewModel = .init()
    @StateObject var todoModel: TodoViewModel = .init()
    
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
                        
                        NavigationLink(destination: TagManagement(isSelectionMode: false)) {
                            Text("Add Tag")
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
                VStack(spacing: 0) {
                    ForEach(activities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                
                Text("Todos")
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
                                    todoModel.updateTodoCompletionStatus(todo: todo, isComplete: isComplete, context: env.managedObjectContext)
                                    todoModel.fetchAndFilterTodos(context: env.managedObjectContext)
                                }
                            }
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
        }) {
            AddTodo()
                .environmentObject(todoModel)
                .presentationCornerRadius(30)
                .presentationBackground(Color("LightBrown"))
        }
        .onAppear {
            todoModel.fetchAndFilterTodos(context: env.managedObjectContext)
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
            .font(.title2)
            .padding(.vertical, 8)
        } else {
            EmptyView()
        }
    }
    
    private func isTodoCompleted(todo: TodoEntity) -> Bool {
        if let completionDate = (todo.completionDates as? Set<TodoCompletionDates>)?.first(where: { Calendar.current.isDateInToday($0.date!) }) {
            return completionDate.isComplete
        } else {
            return false
        }
    }
}
