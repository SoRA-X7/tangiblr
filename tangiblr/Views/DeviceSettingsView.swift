//
//  DeviceSettingsView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/05.
//

import SwiftUI

struct DeviceSettingsView: View {
    @EnvironmentObject var global: AppState
    @State var sensorValue: String = ""
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            Text(global.dev.isConnected() ? "connected" : "disconnected")
                .foregroundColor(global.dev.isConnected() ? .blue: .red)
                .font(.largeTitle)
            
            Text("\(sensorValue)")
                .font(.largeTitle)
        }.onReceive(timer, perform: { _ in
            let sensorValue_l = global.dev.getValues()
            
            if (sensorValue_l?.count ?? 0 > 0){
                sensorValue = sensorValue_l?[0].description ?? ""
            }
                    })
        .onAppear {
            global.dev.start()
        }.onDisappear {
            global.dev.stop()
        }
    }
}
