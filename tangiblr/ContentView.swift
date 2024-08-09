//
//  ContentView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI

struct ContentView: View {
    @State var tabSelection = 1;
    @StateObject var global = AppState()
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView().tabItem {
                Label("Timeline", systemImage: "text.bubble")
            }.tag(1)
            bookmark().tabItem {
                Label("bookmark", systemImage: "bookmark.fill")
            }.tag(2)
            CreatePostView().tabItem {
                Label("New Post", systemImage: "plus.circle")
            }.tag(3)
            DeviceSettingsView().tabItem {
                Label("Devices", systemImage: global.dev.isConnected() ? "wifi" : "wifi.slash")
            }.tag(4)

            
        }.environmentObject(global)
    }
}

#Preview {
    ContentView()
}
