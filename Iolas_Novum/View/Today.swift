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
    
    @StateObject var activityModel: ActivityViewModel = .init()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Today")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        Menu {
                            NavigationLink(destination: AddActivity().environmentObject(activityModel)) {
                                Text("Add Activity")
                            }
                            
                            NavigationLink(destination: TagManagement()) {
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
                
                ScrollView(activities.isEmpty ? .init() : .vertical, showsIndicators: false) {
                    VStack(spacing: 15){
                        ForEach(activities) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
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
                
                Button {
                    
                } label: {
                    Image(systemName: "pencil")
                }
            }
            
            Text(activity.describe ?? "Description")
                .thicccboi(14, .regular)
            
            // TODO: Tags
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
}
