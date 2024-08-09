//
//  DeviceSettingsView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/05.
//

import SwiftUI

struct DeviceSettingsView: View {
    @EnvironmentObject var global: AppState
    @State var sensorValue: Int32 = 0
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            Text(global.dev.isConnected() ? "connected" : "disconnected")
                .foregroundColor(global.dev.isConnected() ? .blue: .red)
                .font(.largeTitle)
            
            Text("\(sensorValue)")
                .font(.largeTitle)
        }.onReceive(timer, perform: { _ in
            sensorValue = global.dev.getValue() ?? 0
        })
    }
}
