//
//  ActivityManagement.swift
//  Iolas_Novum
//
//  Created by Iolas on 27/07/2023.
//

import SwiftUI

struct ActivityManagement: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @Environment(\.self) var env
    
    let isSelectionMode: Bool
    let onActivitySelected: (ActivityEntity) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Activities")
                .thicccboi(22, .thick)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.primary)
                }
                .padding(.bottom, 10)
            
            ScrollView(activities.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack {
                    ForEach(activities) { activity in
                        Button {
                            if isSelectionMode {
                                onActivitySelected(activity)
                                env.dismiss()
                            }
                        } label: {
                            ActivityStub(activity: activity, hasDelete: false, activities: .constant(Set<ActivityEntity>()))
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}
