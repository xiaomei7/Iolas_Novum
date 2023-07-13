//
//  Home.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

struct Home: View {
    @State private var selectedTab: String = "Timeline"
    @Environment(\.scenePhase) var phase
    
    @StateObject var timelineModel: TimelineEntryViewModel = .init()
    @StateObject var stopwatchModel : StopwatchViewModel = .init()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                Timeline(selectedTab: $selectedTab)
            }
            .environmentObject(timelineModel)
            .environmentObject(stopwatchModel)
            .tabItem{
                Image(systemName: "calendar.day.timeline.left")
                Text("Timeline")
            }
            .tag("Timeline")
            .toolbarBackground(Color("Cream"), for: .tabBar)
            
            NavigationView {
                Today()
            }
            .tabItem {
                Image(systemName: "sun.max")
                Text("Today")
            }
            .tag("Today")
            
            Stopwatch()
                .environmentObject(timelineModel)
                .environmentObject(stopwatchModel)
                .tabItem {
                    Image(systemName: "digitalcrown.arrow.clockwise")
                    Text("Timer")
                }
                .toolbarBackground(Color("Cream"), for: .tabBar)
                .tag("Timer")
            
            Text("Statistic View")
                .tabItem {
                    Image(systemName: "numbersign")
                    Text("Statistic")
                }
                .tag("Statistic")
            
            Text("Shop View")
                .tabItem {
                    Image(systemName: "fleuron")
                    Text("Shop")
                }
                .tag("Shop")
        }
        .accentColor(Color("DarkGreen"))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
