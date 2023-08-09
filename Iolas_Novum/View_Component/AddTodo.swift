import SwiftUI

struct AddTodo: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @Environment(\.self) var env
    @EnvironmentObject var todoModel: TodoViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack(alignment: .center) {
                Button {
                    env.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color("DarkOrange"))
                }
                .padding(.top, 15)
                
                Spacer()
                
                Text("Add Todo!")
                    .thicccboi(22, .bold)
                    .foregroundColor(Color("Gray"))
                
                Spacer()
                
                Button {
                    if todoModel.deleteTodo(context: env.managedObjectContext){
                        env.dismiss()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .opacity(todoModel.editTodo == nil ? 0 : 1)
            }
            .hSpacing(.leading)
            
            HStack(alignment: .center, spacing: 8) {
                Text("Name")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Name", text: $todoModel.name)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            HStack(alignment: .center, spacing: 8) {
                Text("Reward")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Points", value: $todoModel.reward, formatter: numberFormatter)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            ColorSelection
            
            FrequencySelection
            
            HStack(alignment: .center) {
                Text("Link Activity Linked")
                    .thicccboi(12, .regular)
                    .foregroundColor(Color("Gray"))
                
                Spacer()
                
                Picker(
                    "Select Activity",
                    selection: $todoModel.linkedActivity) {
                        Text("No Activity").tag(nil as ActivityEntity?)
                        ForEach(activities, id: \.id) { activity in
                            Text(activity.name ?? "Activity Name")
                                .tag(activity as ActivityEntity?)
                        }
                    }
                    .pickerStyle(.menu)
            }
            
            Button {
                if todoModel.editTodo != nil {
                    if todoModel.updateTodo(context: env.managedObjectContext) {
                        env.dismiss()
                    }
                } else if todoModel.createTodo(context: env.managedObjectContext) {
                    env.dismiss()
                }
            } label: {
                Text(todoModel.editTodo != nil ? "Change": "Add")
                    .thicccboi(12, .semibold)
                    .foregroundColor(Color("Black"))
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color("CreamGreen"), in: RoundedRectangle(cornerRadius: 10))
            }
            .disabled(todoModel.name == "")
            .opacity(todoModel.name == "" ? 0.5 : 1)
            
        }
        .padding()
    }
}

struct AddTodo_Previews: PreviewProvider {
    static var previews: some View {
        AddTodo()
    }
}

extension AddTodo {
    private var ColorSelection: some View {
        HStack(spacing: 0){
            ForEach(1...7, id: \.self) { index in
                let color = "PresetColor-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(content: {
                        if color == todoModel.color {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation{
                            todoModel.color = color
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var FrequencySelection: some View {
        HStack{
            VStack(alignment: .leading, spacing: 6) {
                Text("Repetitive?")
                    .thicccboi(16, .regular)
                    .foregroundColor(Color("Gray"))
                
                Text("Select Weekdays")
                    .thicccboi(12, .regular)
                    .foregroundColor(Color("Gray").opacity(0.8))
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            
            Toggle(isOn: $todoModel.isRepetitive) {}
                .labelsHidden()
        }
        
        VStack(alignment: .leading, spacing: 6) {
            Text("Frequency")
                .thicccboi(16, .regular)
                .foregroundColor(Color("Gray").opacity(0.8))
            
            let weekDays = Calendar.current.shortWeekdaySymbols
            let weekDaysIndices = Array(1...7)
            
            HStack(spacing: 10){
                ForEach(weekDays.indices, id: \.self){ index in
                    let day = weekDays[index]
                    let dayIndex = weekDaysIndices[index]
                    
                    let isSelected = todoModel.frequency.contains(dayIndex)
                    
                    Text(day.prefix(2))
                        .thicccboi(16, .semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,12)
                        .foregroundColor(index != -1 ? .white : .primary)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color(todoModel.color) : Color("Gray").opacity(0.4))
                        }
                        .onTapGesture {
                            withAnimation{
                                withAnimation{
                                    if let index = todoModel.frequency.firstIndex(of: dayIndex) {
                                        todoModel.frequency.remove(at: index)
                                    } else {
                                        todoModel.frequency.append(dayIndex)
                                    }
                                }
                            }
                        }
                }
            }
        }
        .frame(height: todoModel.isRepetitive ? nil : 0)
        .opacity(todoModel.isRepetitive ? 1 : 0)
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
