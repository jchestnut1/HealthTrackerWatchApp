//
//  HealthKitManager.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/23/26.
//


import Foundation
import Combine
import HealthKit


class HealthKitManager {
    
    static let shared = HealthKitManager()
    private init() {}
    
    let healthStore = HKHealthStore()
    
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    
    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [heartRateType]
        let typesToWrite: Set<HKSampleType> = []
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    
    func checkAuthorizationStatus() -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: heartRateType)
    }
}
