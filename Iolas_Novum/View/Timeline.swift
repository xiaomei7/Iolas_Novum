//
//  Timeline.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import SwiftUI

struct Timeline: View {
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var timelineEntries: [TimelineEntry] = []
    
    @StateObject var timelineModel: TimelineEntryViewModel = .init()
    @Environment(\.self) var env
    
    @Namespace private var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(timelineEntries, id: \.id) { timeline in
                        TimelineCard(timeline)
                            .padding(.horizontal, 12)
                            .background(alignment: .leading) {
                                if timelineEntries.last?.id != timeline.id {
                                    Rectangle()
                                        .frame(width: 1)
                                        .offset(x: 8)
                                        .padding(.bottom, -35)
                                }
                            }
                    }
                }
                .hSpacing(.center)
                .vSpacing(.center)
            }
        }
        .vSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                timelineModel.addorEditTimeline.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(Color("DarkGreen").shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: Circle())
            })
            .padding(15)
        })
        .onAppear(perform: {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }
                
                weekSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
            
            if timelineEntries.isEmpty {
                timelineEntries = timelineModel.fetchTimelineEntries(on: currentDate, context: env.managedObjectContext)
            }
        })
        .sheet(isPresented: $timelineModel.addorEditTimeline, content: {
            AddTimeline()
                .environmentObject(timelineModel)
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
                .presentationBackground(Color("Cream"))
        })
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

extension Timeline {
    private var Header: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Year and Month
            HStack(spacing: 5) {
                Text(currentDate.formatToString("MMMM"))
                    .foregroundColor(Color("DarkGreen"))
                
                Text(currentDate.formatToString("YYYY"))
                    .foregroundColor(Color("Brown"))
            }
            .thicccboi(28, .thick)
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .thicccboi(18, .medium)
                .foregroundColor(.gray)
            
            // Week Slider
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .overlay(alignment: .topTrailing, content: {
            Button(action: {}, label: {
                Image("avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .stroke(Color("DarkGreen"), lineWidth: 5)
                    )
            })
        })
        .padding(15)
        .background {
            VStack(spacing: 0) {
                Color("Cream").ignoresSafeArea()
                
                Rectangle()
                    .fill(.linearGradient(colors: [
                        Color("Cream"),
                        .clear
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(height: 10)
            }
        }
        .onChange(of: currentWeekIndex) { newValue in
            // Creating new week array when it reaches first/last Page
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
        .onChange(of: currentDate) { newValue in
            timelineEntries = timelineModel.fetchTimelineEntries(on: newValue, context: env.managedObjectContext)
        }
    }
    
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.id) { day in
                VStack(spacing: 8) {
                    Text(day.date.formatToString("E"))
                        .thicccboi(18, .semibold)
                        .foregroundColor(Color("DarkGreen"))
                    
                    Text(day.date.formatToString("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CreamGreen"))
                                    .matchedGeometryEffect(id: "date_indicator", in: animation)
                            }
                            
                            // Small dot to indicte today
                            if day.date.isToday {
                                Circle()
                                    .fill(Color("CreamGreen"))
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(Color("LightBrown").shadow(.drop(radius: 1)), in: RoundedRectangle(cornerRadius: 10))
                }
                .hSpacing(.center)
                .contentShape(Rectangle())
                .onTapGesture {
                    /// Updating Current Date
                    withAnimation(.easeInOut) {
                        currentDate = day.date
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        // When the Offset reaches 15 and if the createWeek is toggled then simply generating next set of week
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
    
    private func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                // Inserting New Week at 0th Index and Removing Last Array Item
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                // Appending New Week at Last Index and Removing First Array Item
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
        
        print(weekSlider.count)
    }
    
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
                HStack {
                    Text(timeline.activity?.name ?? "Unallocated")
                        .thicccboi(18, .semibold)
                        .foregroundColor(Color("Black"))
                    
                    HStack {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(Color("Gray"))
                        
                        Text("\(timeline.start!.formattedHourMinuteDifference(to: timeline.end!))")
                            .foregroundColor(Color("Black").opacity(0.8))
                            .thicccboi(12, .bold)
                    }
                }
                
                if let tags = timeline.activity?.tags {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            ForEach(Array(tags as! Set<TagEntity>), id: \.id) { tag in
                                TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                            }
                        }
                    }
                }
                
                HStack {
                    Label(timeline.start!.formatToString("HH:ss"), systemImage: "clock")
                        .thicccboi(12, .regular)
                        .foregroundColor(Color.black)
                    
                    Label(timeline.end!.formatToString("HH:ss"), systemImage: "arrow.forward")
                        .thicccboi(12, .regular)
                        .foregroundColor(Color.black)
                }
            })
            .padding(15)
            .hSpacing(.leading)
            .background(Color(timeline.activity?.color ?? "Brown"), in: RoundedRectangle(cornerRadius: 15))
        }
        .offset(y: 10)
    }
}

