import Foundation

final class StopwatchViewModel: ObservableObject {
    enum StopwatchState {
        case stopped
        case running
        case paused
    }
    
    @Published var stopwatchState: StopwatchState = .stopped
    @Published var elapsedTime: Float = 0
    
    @Published var startTime: Date?
    @Published var endTime: Date?
    
    private var timer: Timer?
    
    func start() {
        stopwatchState = .running
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    func pause() {
        stopwatchState = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func stop() {
        stopwatchState = .stopped
        endTime = Date()
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    func formatTime(time: Float) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
