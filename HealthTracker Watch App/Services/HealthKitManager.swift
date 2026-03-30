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
    
    func fetchLatestHeartRateMeasure() async throws -> HeartRateSample? {
           return try await withCheckedThrowingContinuation { continuation in
               let sortDescriptor = NSSortDescriptor(
                   key: HKSampleSortIdentifierStartDate,
                   ascending: true
               )

               let query = HKSampleQuery(
                   sampleType: heartRateType,
                   predicate: nil,
                   limit: 1,
                   sortDescriptors: [sortDescriptor]
               ) { _, samples, error in
                   if let error = error {
                       continuation.resume(throwing: error)
                       return
                   }

                   guard let sample = samples?.first as? HKQuantitySample else {
                       continuation.resume(returning: nil)
                       return
                   }

                   let bpm = sample.quantity.doubleValue(for: self.heartRateUnit)
                   let heartRateSample = HeartRateSample(
                       bpm: bpm,
                       timestamp: sample.startDate
                   )
                   continuation.resume(returning: heartRateSample)
               }

               healthStore.execute(query)
           }
       }
       
       func startHeartRateMonitoring(onUpdate: @escaping ([HeartRateSample]) -> Void) {
           stopHeartRateMonitoring()

           let query = HKAnchoredObjectQuery(
               type: heartRateType,
               predicate: nil,
               anchor: nil,
               limit: HKObjectQueryNoLimit
           ) { [weak self] query, samples, deletedObjects, anchor, error in
               guard let self = self else { return }
               self.processHeartRateSample(samples, onUpdate: onUpdate)
           }
           
           query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
               guard let self = self else { return }
               self.processHeartRateSample(samples, onUpdate: onUpdate)
           }

           heartRateQuery = query
           healthStore.execute(query)
       }
       
       func stopHeartRateMonitoring() {
           if let query = heartRateQuery {
               healthStore.stop(query)
               heartRateQuery = nil
           }
       }
       
       func processHeartRateSample(_ samples: [HKSample]?, onUpdate: @escaping ([HeartRateSample]) -> Void) {
           guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
               return
           }
           
           let heartRateSamples = quantitySamples.map { sample in
               HeartRateSample(
                   bpm: sample.quantity.doubleValue(for: heartRateUnit),
                   timestamp: sample.startDate
               )
           }
           
           // Call update handler on main thread
           DispatchQueue.main.async {
               onUpdate(heartRateSamples)
           }
       }
       
   }

