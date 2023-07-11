//
//  AddTimeline.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import SwiftUI

struct AddTimeline: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @Environment(\.self) var env
    @EnvironmentObject var timelineModel: TimelineEntryViewModel
    
    let lastTimeline: TimelineEntry?
        
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            HStack {
                Button(action: {
                    timelineModel.addorEditTimeline.toggle()
                    env.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color("DarkOrange"))
                })
                
                Spacer()
                
                VStack {
                    Text("Total Record Time: \(timelineModel.timeDifferenceString)")
                        .thicccboi(16, .regular)
                    
                    Text("Points: \(timelineModel.points.mostTwoDigitsAsNumberString())")
                        .thicccboi(16, .regular)
                }
                
                Spacer()
                
                Button {
                    if timelineModel.deleteTimelineEntry(context: env.managedObjectContext){
                        env.dismiss()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .opacity(timelineModel.editTimeline == nil ? 0 : 1)
            }
            .hSpacing(.leading)
            
            VStack(alignment: .center, spacing: 0) {
                HStack(spacing: 0) {
                    DatePicker("Start", selection: $timelineModel.start)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                    
                    Button {
                        if let lastTimeline = self.lastTimeline {
                            timelineModel.start = lastTimeline.end!
                        }
                    } label: {
                        Text("Last")
                            .thicccboi(12, .regular)
                            .foregroundColor(Color("LightBrown"))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("DarkOrange"))
                            }
                    }
                    
                }
                
                HStack(spacing: 0) {
                    DatePicker("End", selection: $timelineModel.end)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                    
                    Button {
                        timelineModel.end = Date()
                    } label: {
                        Text("Now")
                            .thicccboi(12, .regular)
                            .foregroundColor(Color("LightBrown"))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("DarkOrange"))
                            }
                    }
                }
            }
            
            HStack {
                Picker(
                    "Select Activity",
                    selection: $timelineModel.activity) {
                        Text("No Activity").tag(nil as ActivityEntity?)
                        ForEach(activities, id: \.id) { activity in
                            Text(activity.name ?? "Activity Name")
                                .tag(activity as ActivityEntity?)
                        }
                    }
                    .pickerStyle(.menu)
                
                TextField("Description", text: $timelineModel.description)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color("LightBrown").shadow(.drop(color: Color("DarkOrange").opacity(0.25), radius: 2)), in: RoundedRectangle(cornerRadius: 10))
            }
            
            Button {
                if timelineModel.createTimelineEntry(context: env.managedObjectContext) {
                    timelineModel.addorEditTimeline.toggle()
                    env.dismiss()
                }
            } label: {
                Text("Add Timespent")
                    .thicccboi(16, .semibold)
                    .foregroundColor(Color("Cream"))
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(timelineModel.activity != nil ? Color(timelineModel.activity!.color!) : Color("Gray"), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .vSpacing(.bottom)
    }
}

struct AddTimeline_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
