//
//  ContentView.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject var userModel: UserViewModel = UserViewModel()
    
    
    var body: some View {
        NavigationView {
            Home()
        }
        .onAppear {
            userModel.context = context
            userModel.fetchUser()
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
