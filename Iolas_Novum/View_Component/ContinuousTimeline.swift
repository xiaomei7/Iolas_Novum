//
//  TimelineCard.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import SwiftUI

struct ContinuousTimeline: View {
    @FetchRequest(
        entity: TimelineEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TimelineEntry.end, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var timelines: FetchedResults<TimelineEntry>
    
    @EnvironmentObject var timelineModel: TimelineEntryViewModel
    
    var body: some View {
        ForEach(timelines, id: \.id) { timeline in
            TimelineCard(timeline)
        }
    }
}

struct ContinuousTimeline_Previews: PreviewProvider {
    static var previews: some View {
        ContinuousTimeline()
    }
}

extension ContinuousTimeline {
    private func TimelineCard(_ timeline: TimelineEntry) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(Color(timeline.activity?.color ?? "Brown").opacity(0.7))
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: Circle())
                .overlay {
                    Circle()
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
//                                task.isCompleted.toggle()
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text(timeline.activity?.name ?? "Unallocated")
                    .thicccboi(16, .semibold)
                    .foregroundColor(Color.black)
                
                Label(timeline.end!.formatToString("hh:mm a"), systemImage: "clock")
                    .thicccboi(12, .regular)
                    .foregroundColor(Color.black)
            })
            .padding(15)
            .hSpacing(.leading)
            .background(Color(timeline.activity?.color ?? "Brown"), in: RoundedRectangle(cornerRadius: 15))
            .offset(y: -8)
        }
    }
}
