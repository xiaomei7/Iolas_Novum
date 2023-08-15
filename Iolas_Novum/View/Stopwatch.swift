import SwiftUI

struct Stopwatch: View {
    @FetchRequest(
        entity: ActivityEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityEntity.name, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activities: FetchedResults<ActivityEntity>
    
    @Environment(\.self) var env
    @EnvironmentObject var stopwatchModel: StopwatchViewModel
    @EnvironmentObject var timelineModel: TimelineEntryViewModel
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var activityStatModel: ActivityStatsViewModel
    
    var body: some View {
        ZStack {
            Color("Cream").ignoresSafeArea()
            
            VStack(spacing: 10) {
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
                    .frame(width: UIScreen.main.bounds.width * 2/3)
                
                TimerRing
                
                Buttons
            }
        }
        .onAppear {
            timelineModel.resetData()
        }
    }
}

struct Stopwatch_Previews: PreviewProvider {
    static var previews: some View {
        Stopwatch()
    }
}

extension Stopwatch {
    private var TimerRing: some View {
        GeometryReader { proxy in
            ZStack {
                // MARK: passed time effect
                Circle()
                    .trim(from: 0, to: CGFloat((stopwatchModel.elapsedTime.truncatingRemainder(dividingBy: 60)) / 60))
                    .stroke(Color("LightGreen").opacity(0.5), lineWidth: 40)
                
                // MARK: shadow
                Circle()
                    .stroke(Color("CreamGreen"), lineWidth: 5)
                    .blur(radius: 3)
                    .padding(-2)
                
                // MARK: inner passed time effect
                Circle()
                    .trim(from: 0, to: CGFloat((stopwatchModel.elapsedTime.truncatingRemainder(dividingBy: 60)) / 60))
                    .stroke(Color("LightGreen").opacity(0.7), lineWidth: 10)
                
                // MARK: knob
                GeometryReader { proxy in
                    let size = proxy.size
                    
                    Circle()
                        .fill(Color("DarkGreen").opacity(0.7))
                        .frame(width: 30, height: 30)
                        .overlay(content: {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .padding(5)
                            
                        })
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .offset(x: size.height / 2) // use x for view is rotated
                        .rotationEffect(.init(degrees: Double(stopwatchModel.elapsedTime.truncatingRemainder(dividingBy: 60)) * 6)) // 360/60 = 6 degrees per second
                }
                
                VStack(spacing: 0) {
                    Text(stopwatchModel.formatTime(time: stopwatchModel.elapsedTime))
                        .thicccboi(26, .thick)
                        .foregroundColor(Color("Brown"))
                        .animation(.none, value: stopwatchModel.elapsedTime)
                }
                .rotationEffect(.init(degrees: 90))
                
            }
            .padding(60)
            .frame(height: proxy.size.width)
            .rotationEffect(.init(degrees: -90))
            .animation(.easeInOut, value: stopwatchModel.elapsedTime)
        }
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .padding()
    }
    
    @ViewBuilder
    private var Buttons: some View {
        HStack(spacing: 15) {
            Button {
                switch stopwatchModel.stopwatchState {
                case .stopped, .paused:
                    stopwatchModel.start()
                case .running:
                    stopwatchModel.pause()
                }
            } label: {
                Image(systemName: stopwatchModel.stopwatchState == .running ? "pause.fill" : "play.fill")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width / 3, height: 50)
                    .background(
                        Circle()
                            .fill(Color("CreamGreen").opacity(0.6))
                    )
                    .shadow(color: Color("Black").opacity(0.3), radius: 8, x: 0, y: 0)
            }
            
            if stopwatchModel.stopwatchState != .stopped {
                Button {
                    stopwatchModel.stop()
                    timelineModel.start = stopwatchModel.startTime ?? Date()
                    timelineModel.end = stopwatchModel.endTime ?? Date()
                    if timelineModel.createTimelineEntry(context: env.managedObjectContext) {
                        userModel.points += timelineModel.points
                        if userModel.updatePoints(context: env.managedObjectContext) {
                            let durations = Date.calculateDurations(date1: timelineModel.start, date2: timelineModel.end)
                            activityStatModel.activity = timelineModel.activity
                            if activityStatModel.createOrUpdateActivityStats(context: env.managedObjectContext, newDurations: durations) {
                                env.dismiss()
                            }
                        }
                    }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width / 3, height: 50)
                        .background(
                            Circle()
                                .fill(Color("CreamGreen").opacity(0.6))
                        )
                        .shadow(color: Color("Black").opacity(0.3), radius: 8, x: 0, y: 0)
                }
            }
        }
    }
}
