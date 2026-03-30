import SwiftUI
import Combine
import WatchKit

@MainActor
class HealthViewModel: ObservableObject {
    
    @Published var goals: UserGoals
    @Published var todaysCalories: Double = 0
    @Published var todaysWater: Double = 0
    
    @Published var currentHeartRate: Double = 0
    @Published var isHealthKitAvailable: Bool = true
    @Published var heartRateErrors: String?
    
    private let healthKit = HealthKitManager.shared
    
    
    // MARK: - Computed Properties
    var caloriesProgress: Double {
        min(todaysCalories / goals.dailyCalorieGoal, 1.0)
    }
    
    var waterProgress: Double {
        min(todaysWater / goals.dailyWaterGoal, 1.0)
    }
    
    var caloriesGoalMet: Bool {
        todaysCalories >= goals.dailyCalorieGoal
    }
    
    var waterGoalMet: Bool {
        todaysWater >= goals.dailyWaterGoal
    }
    
    var formattedHeartRate: String {
        "\(Int(currentHeartRate)) BPM"
    }
    
    // MARK: - Initialization
    init() {
        self.goals = StorageManager.shared.loadGoals()
        refreshTodaysData()
    }
    
    // MARK: - Public Methods
    
    func refreshTodaysData() {
        self.todaysCalories = StorageManager.shared.getTodaysTotal(for: .calories)
        self.todaysWater = StorageManager.shared.getTodaysTotal(for: .water)
    }
    
    func addCalories(_ amount: Double) {
        let caloriesEntry = DiaryEntry(
            type: .calories,
            value: amount
        )
        
        StorageManager.shared.addEntry(caloriesEntry)
        
        todaysCalories += amount
        
        WKInterfaceDevice.current().play(.directionUp)
    }
    
    func addWater(_ amount: Double) {
        let waterEntry = DiaryEntry(
            type: .water,
            value: amount
        )

        StorageManager.shared.addEntry(waterEntry)

        todaysWater += amount

        WKInterfaceDevice.current().play(.notification)
    }

    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    func requestHealthKitAuthorization() async {
        guard isHealthKitAvailable else {
            heartRateErrors = "Heart Rate is not available"
            return
        }
        
        do {
            try await healthKit.requestAuthorization()
            isHealthKitAvailable = true
            WKInterfaceDevice.current().play(.success)
        } catch {
            heartRateErrors = "Authorization Failed"
            isHealthKitAvailable = false
        }
    }
    
    func startHeartRateMonitoring() async {
        guard isHealthKitAvailable else {
            heartRateErrors = "Heart Rate is not available"
            return
        }
        
        do {
            if let sample = try await healthKit.fetchLatestHeartRateMeasure() {
                currentHeartRate = sample.bpm
            }
        } catch {
            heartRateErrors = "Failed to fetch latest heart rate"
        }
    }
}
