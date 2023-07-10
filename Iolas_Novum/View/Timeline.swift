//
//  Timeline.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

//struct Timeline: View {
//    @StateObject private var dateTimeVM: DateTimeViewModel = DateTimeViewModel()
//
//    var body: some View {
//        LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
//            Section {
//                Timelines
//            } header: {
//                Header
//            }
//
//        }
//    }
//}
//
//struct Timeline_Previews: PreviewProvider {
//    static var previews: some View {
//        Timeline()
//    }
//}
//
//extension Timeline {
//    private var Header: some View {
//        VStack {
//            HStack(spacing: 10) {
//
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(dateTimeVM.selectedDay.formatted(date: .abbreviated, time: .omitted))
//                        .foregroundColor(Color("Gray"))
//
//                    Text(
//                        dateTimeVM.isToday(date: dateTimeVM.selectedDay) ? "Today" :
//                            dateTimeVM.isYesterday(date: dateTimeVM.selectedDay) ? "Yesterday" :
//                            dateTimeVM.isTomorrow(date: dateTimeVM.selectedDay) ? "Tomorrow" :
//                            dateTimeVM.selectedDay.formatted(.dateTime.weekday(.wide))
//                    )
//                    .foregroundColor(Color("DarkGreen"))
//                    .thicccboi(32, .thick)
//                }
//                .hAlign(.leading)
//
//                Button {
//
//                } label: {
//                    // can distill
//                    Image("avatar")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 45, height: 45)
//                        .clipShape(Circle())
//                        .background(
//                            Circle()
//                                .stroke(Color("DarkGreen"), lineWidth: 5)
//                        )
//                }
//
//
//            }
//
//        }
//        .padding()
//        .background {
//            VStack(spacing: 0) {
//                Color("Cream")
//
//                Rectangle()
//                    .fill(.linearGradient(colors: [
//                        Color("Cream"),
//                        .clear
//                    ], startPoint: .top, endPoint: .bottom))
//                    .frame(height: 10)
//            }
//        }
//
//    }
//
//    @ViewBuilder
//    private var Timelines: some View {
//        let timelineEntries =  []
//        if timelineEntries.isEmpty {
//            Text("No Timeline Entries")
//                .offset(y: 100)
//        } else {
//            LazyVStack(alignment: .leading, spacing: -26) {
//                ForEach(timelineEntries) { timelineEntry in
////                    TimelineCard(timeline: timelineEntry)
//                    Text("Timeline Card")
//                }
//            }
//
//        }
//    }
//}
