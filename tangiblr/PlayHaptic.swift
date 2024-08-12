//
//  PlayHaptic.swift
//  haptical
//
//  Created by SoRA_X7 on 2023/06/08.
//

import Foundation
import CoreHaptics

class PlayHaptic {
    var engine: CHHapticEngine!
    init() {
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine()
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        try! engine.start()
    }
    public func play(intensity: Float) throws -> Void {
        let pattern = try CHHapticPattern(events: [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: min(1, intensity * 3)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: pow(intensity, 1.4)),
            ], relativeTime: CHHapticTimeImmediate, duration: 1.0)
        ], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try! player.start(atTime: 0)
    }
}
