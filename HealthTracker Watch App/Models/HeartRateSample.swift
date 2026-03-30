//
//  HeartRateSample.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/30/26.
//



import Foundation
import Combine


struct HeartRateSample: Identifiable {
    let id = UUID()
    let bpm: Double
    let timestamp: Date
    
    var formattedBPM: String {
        "\(Int(bpm)) BPMs"
    }
}
