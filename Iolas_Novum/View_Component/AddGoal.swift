//
//  AddGoal.swift
//  Iolas_Novum
//
//  Created by Iolas on 24/07/2023.
//

import SwiftUI

struct AddGoal: View {
    
    @EnvironmentObject var goalModel: GoalViewModel
    @Environment(\.self) var env
    
    @State private var animateColor: Color = Color("Brown")
    @State private var animate: Bool = false
    @State private var linkOption = "Activity"
        
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        if goalModel.deleteGoal(context: env.managedObjectContext){
                            goalModel.resetData()
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(goalModel.editGoal == nil ? 0 : 1)
                    
                    Text(goalModel.editGoal != nil ? "Edit Goal" : "Create New Goal")
                        .thicccboi(28, .light)
                        .foregroundColor(Color("Cream"))
                        .padding(.vertical, 15)
                }
                
                Name
                
                Description
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background {
                AnimatedBackground
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ColorSelection
                
                FrequencySelection
                
                Aim
                
                RewardAndPunishment
                
                LinkActivityOrTag
                
                CreateButton
            }
            .padding(15)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            Color("Cream").ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: DismissButton)
    }
}

struct AddGoal_Previews: PreviewProvider {
    static var previews: some View {
        AddGoal()
    }
}

extension AddGoal {
    private func Title(_ value: String, _ color: Color = Color("Gray")) -> some View {
        Text(value)
            .thicccboi(12, .regular)
            .foregroundColor(color)
    }
    
    private func Underline(color: Color) ->  some View {
        Rectangle()
            .fill(color.opacity(0.7))
            .frame(height: 1)
    }
    
    private var AnimatedBackground: some View {
        ZStack {
            Color(goalModel.color)
            
            GeometryReader {
                let size = $0.size
                
                Rectangle()
                    .fill(animateColor)
                    .mask { Circle() }
                    .frame(width: animate ? size.width * 2 : 0, height: animate ? size.height * 2 : 0)
                    .offset(animate ? CGSize(width: -size.width / 2, height: -size.height / 2) : size)
            }
            .clipped()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var Name: some View {
        Title("NAME")
        
        TextField("Input Goal Name", text: $goalModel.name)
            .foregroundColor(Color("Cream"))
            .thicccboi(16, .regular)
            .tint(Color("Cream"))
            .padding(.top, 2)
        
        Underline(color: Color("Cream"))
    }
    
    @ViewBuilder
    private var Description: some View {
        Title("DESCRIPTION", Color("Cream"))
        
        TextField("About Your Goal", text: $goalModel.description)
            .foregroundColor(Color("Cream"))
            .thicccboi(16, .regular)
            .padding(.top, 2)
        
        Underline(color: Color("Cream"))
    }
    
    private var ColorSelection: some View {
        HStack(spacing: 0){
            ForEach(1...7, id: \.self) { index in
                let color = "PresetColor-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(content: {
                        if color == goalModel.color {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation{
                            goalModel.color = color
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var FrequencySelection: some View {
        Title("FREQUENCY")
        
        Picker("Select Frequency", selection: $goalModel.cycle) {
                ForEach(GoalCycle.allCases, id: \.self) { cycle in
                    Text(cycle.rawValue).tag(cycle)
                }
            }
        .pickerStyle(.segmented)
        
        if goalModel.cycle == .single {
            DatePicker("ACCOMPLISH Before",
                       selection: Binding<Date>(get: {goalModel.dueDate ?? Date()}, set: {goalModel.dueDate = $0}),
                       displayedComponents: .date)
                .datePickerStyle(.compact)
                .scaleEffect(0.9, anchor: .leading)
                .thicccboi(12, .regular)
                .foregroundColor(Color("Gray"))
        }
    }
    
    private var Aim: some View {
        HStack(alignment: .center) {
            Title("AIM:")
            
            TextField("0.0", value: $goalModel.aimInMinutes, formatter: numberFormatter)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            
            Title("Goal is >= Aim?")
            
            Toggle(isOn: $goalModel.exceedAim) {}
                .labelsHidden()
        }
    }
    
    private var RewardAndPunishment: some View {
        HStack(alignment: .center) {
            Title("REWARD If Accomplish:")
            
            TextField("0.0", value: $goalModel.reward, formatter: numberFormatter)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            
            Title("COST If Fail:")
            
            TextField("0.0", value: $goalModel.punishment, formatter: numberFormatter)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color("LightBrown").shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    @ViewBuilder
    private var LinkActivityOrTag: some View {
        Title("SELECT to Link TAGS or ACTIVITIES")
        
        Picker("TAG or ACTIVITY", selection: $linkOption) {
            Text("Activity").tag("Activity")
            Text("Tag").tag("Tag")
        }
        .pickerStyle(.segmented)
        
        if linkOption == "Activity" {
            ActivitySelection
        } else {
            TagSelection
        }
    }
    
    @ViewBuilder
    private var ActivitySelection: some View {
        HStack(alignment: .center) {
            Title("ACTIVITIES", Color("Gray"))
            
            Spacer()
            
            NavigationLink(destination: ActivityManagement(isSelectionMode: true) { selectedActivity in
                if !goalModel.linkedActivities.contains(where: { $0.id == selectedActivity.id }) {
                    goalModel.linkedActivities.insert(selectedActivity)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundColor(Color("Gray"))
            }
            .id(UUID())
            
        }
        .padding(.top, 15)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(goalModel.linkedActivities), id: \.id) { activity in
                    ActivityStub(activity: activity, hasDelete: true, activities: $goalModel.linkedActivities)
                }
            }
        }
    }
    
    @ViewBuilder
    private var TagSelection: some View {
        HStack(alignment: .center) {
            Title("TAGS", Color("Gray"))
            
            Spacer()
            
            NavigationLink(destination: TagManagement(isSelectionMode: true) { selectedTag in
                if !goalModel.linkedTags.contains(where: { $0.id == selectedTag.id }) {
                    goalModel.linkedTags.insert(selectedTag)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundColor(Color("Gray"))
            }
            .id(UUID())
        }
        .padding(.top, 15)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(goalModel.linkedTags), id: \.id) { tag in
                    TagStub(tag: tag, hasDelete: true, tags: $goalModel.linkedTags)
                }
            }
        }
    }
    
    private var DismissButton: some View {
        Button {
            goalModel.resetData()
            env.dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("Cream"))
                .contentShape(Rectangle())
        }
    }
    
    private var CreateButton: some View {
        Button {
            if goalModel.editGoal != nil {
                if goalModel.updateGoal(context: env.managedObjectContext) {
                    goalModel.resetData()
                    env.dismiss()
                }
            } else {
                if goalModel.createGoal(context: env.managedObjectContext) {
                    goalModel.resetData()
                    env.dismiss()
                }
            }
        } label: {
            Text(goalModel.editGoal != nil ? "Edit Done" : "Create Activity")
                .thicccboi(16, .regular)
                .foregroundColor(Color("Cream"))
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    Capsule()
                        .fill(Color(goalModel.color).gradient)
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .disabled(!goalModel.doneStatus())
        .opacity(!goalModel.doneStatus() ? 0.6 : 1)
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
