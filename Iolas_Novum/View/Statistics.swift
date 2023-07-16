//
//  Statistics.swift
//  Iolas_Novum
//
//  Created by Iolas on 16/07/2023.
//

import SwiftUI

struct Statistics: View {
    @FetchRequest(
        entity: ActivityStats.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityStats.date, ascending: false)],
        predicate: nil,
        animation: .easeInOut)
    var activityStats: FetchedResults<ActivityStats>
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    var body: some View {
        ZStack {
            Color("Cream").ignoresSafeArea()
            
            VStack {
                ForEach(activityStats, id: \.id) { activityStat in
                    VStack {
                        Text("Statistic")
                        Text("\(activityStat.date ?? Date(), formatter: formatter)")
                        Text("\(activityStat.activity?.name ?? "Unallocated")")
                        Text("\(activityStat.accumulateTime.asMinutes()) minutes")
                    }
                }
            }
        }
    }
}

struct Statistics_Previews: PreviewProvider {
    static var previews: some View {
        Statistics()
    }
}
