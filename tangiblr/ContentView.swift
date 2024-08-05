//
//  ContentView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI

struct ContentView: View {
    @State var tabSelection = 1;
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView().tabItem {
                Label("Timeline", systemImage: "text.bubble")
            }.tag(1)
            CreatePostView().tabItem {
                Label("New Post", systemImage: "plus.circle")
            }.tag(2)
            DeviceSettingsView().tabItem {
                Label("Devices", systemImage: "wifi.circle")
            }.tag(3)
        }
    }
}

#Preview {
    ContentView()
}
