//
//  DeviceSettingsView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/05.
//

import SwiftUI

struct DeviceSettingsView: View {
    @State var dev: SensorDevice? = nil
    @State var sensorValue: Int32 = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Hello, World!!")
            Text("\(sensorValue)")
            Button(action: {
                dev = SensorDevice()
            }) {
                Text("Button")
            }
        }.onReceive(timer, perform: { _ in
//            print(dev?.getValue())
            sensorValue = dev?.getValue() ?? 0
        })
    }
}

#Preview {
    DeviceSettingsView()
}
