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
    @State private var timelineEntries: [TimelineEntry] = [] {
        didSet {
            calculatePoints()
        }
    }
    @State private var earn: Double = 0.0
    @State private var cost: Double = 0.0
    @State private var total: Double = 0.0
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var timelineModel: TimelineEntryViewModel
    @Environment(\.self) var env
    
    @Namespace private var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(timelineEntries, id: \.id) { timeline in
                        TimelineCard(timeline)
                            .background(alignment: .leading) {
                                if timelineEntries.last?.id != timeline.id {
                                    Rectangle()
                                        .frame(width: 1)
                                        .offset(x: 8)
                                        .padding(.bottom, -35)
                                }
                            }
                            .padding(.horizontal, 12)
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
            timelineModel.income = userViewModel.income
            
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
            
            timelineEntries = timelineModel.fetchTimelineEntries(on: currentDate, context: env.managedObjectContext)
        })
        .sheet(isPresented: $timelineModel.addorEditTimeline, onDismiss: {
            timelineEntries = timelineModel.fetchTimelineEntries(on: currentDate, context: env.managedObjectContext)
        }) {
            AddTimeline()
                .environmentObject(timelineModel)
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
                .presentationBackground(Color("Cream"))
        }
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
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Earn: \(earn.mostTwoDigitsAsNumberString())")
                        .thicccboi(12, .regular)
                        .foregroundColor(Color("DarkGreen"))
                    Text("Spent: \(cost.mostTwoDigitsAsNumberString())")
                        .thicccboi(12, .regular)
                        .foregroundColor(Color("DarkOrange"))
                    Text("Total: \(total.mostTwoDigitsAsNumberString())")
                        .thicccboi(12, .regular)
                        .foregroundColor(total > 0 ? Color("DarkGreen") : Color("DarkOrange"))
                }
                
                NavigationLink(destination: UserPreference()) {
                    Image("avatar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .background(
                            Circle()
                                .stroke(Color("DarkGreen"), lineWidth: 5)
                        )
                }
                
            }
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
    }
    
    private func TimelineCard(_ timeline: TimelineEntry) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(Influence(rawValue: timeline.activity?.influence ?? "Neutral")!.color.opacity(0.7))
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: Circle())
                .overlay {
                    Circle()
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                timelineModel.editTimeline = timeline
                                timelineModel.restoreEditData()
                                timelineModel.addorEditTimeline.toggle()
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(timeline.activity?.name ?? "Unallocated")
                            .thicccboi(16, .semibold)
                            .foregroundColor(Color("Black"))
                        
                        HStack {
                            Label(timeline.start?.formatToString("HH:ss") ?? "N/A", systemImage: "clock")
                                .thicccboi(12, .regular)
                                .foregroundColor(Color.black)
                            
                            Label(timeline.end?.formatToString("HH:ss") ?? "N/A", systemImage: "arrow.forward")
                                .thicccboi(12, .regular)
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        HStack {
                            Image(systemName: "stopwatch")
                                .font(.system(size: 12))
                                .fontWeight(.light)
                                .foregroundColor(Color("Gray"))
                            
                            Text("\(timeline.start?.formattedHourMinuteDifference(to: timeline.end ?? Date()) ?? "N/A")")
                                .foregroundColor(Color("Black").opacity(0.8))
                                .thicccboi(12, .bold)
                        }
                        
                        calculatePoints(timeline: timeline)
                    }
                }
                
                if timeline.describe != "" {
                    Text(timeline.describe!)
                        .thicccboi(14, .light)
                        .foregroundColor(Color("Gray"))
                }
                
                if (timeline.activity != nil) && timeline.activity!.tags?.count != 0 {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            ForEach(Array(timeline.activity!.tags as! Set<TagEntity>), id: \.id) { tag in
                                TagStub(tag: tag, hasDelete: false, tags: .constant(Set<TagEntity>()))
                            }
                        }
                    }
                }
            }
            .padding(15)
            .hSpacing(.leading)
            .background {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color((timeline.activity?.color ?? "Gray")))
                        .frame(width: 4)
                    
                    Rectangle()
                        .fill(Color((timeline.activity?.color ?? "Gray")).opacity(0.25))
                }
            }
            .cornerRadius(20, corners: [.topLeft, .bottomRight])
        }
        .offset(y: 10)
        
    }
    
    private func calculatePoints(timeline: TimelineEntry) -> some View {
        guard let activity = timeline.activity else {
            return HStack {
                Image(systemName: "arrow.down.heart")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Brown"))
                Text("No Points")
                    .foregroundColor(Color("Brown"))
                    .thicccboi(12, .bold)
            }
        }
        
        let hourlyRate = 3000.0 / (30 * 24)
        let points = activity.factor * timeline.start!.hourDifference(to: timeline.end!)  * hourlyRate
        let pointsString: String
        let color: Color
        let iconName: String
        
        switch points {
        case 0:
            pointsString = ""
            color = Color("Gray")
            iconName = "heart"
        case let x where x > 0:
            pointsString = "+ \(x.mostTwoDigitsAsNumberString())"
            color = Color("DarkGreen")
            iconName = "tree"
        case let x where x < 0:
            pointsString = "- \((-x).mostTwoDigitsAsNumberString())"
            color = Color("DarkOrange")
            iconName = "drop"
        default:
            pointsString = ""
            color = Color("Gray")
            iconName = "heart"
        }
        
        return HStack {
            Image(systemName: iconName)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(pointsString)
                .foregroundColor(color)
                .thicccboi(12, .bold)
        }
        
    }
    
    private func calculatePoints() {
        let points = timelineEntries.map { $0.points }
        earn = points.filter { $0 > 0 }.reduce(0, +)
        cost = points.filter { $0 < 0 }.reduce(0, +)
        total = earn + cost
    }
}
