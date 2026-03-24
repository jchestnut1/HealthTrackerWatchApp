//
//  UserGoalsModel.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/18/26.
//



import Foundation


struct UserGoals: Codable {
    var dailyCalorieGoal: Double
    var dailyWaterGoal: Double
    
    static let defaultGoals = UserGoals(
               dailyCalorieGoal:2000,
               dailyWaterGoal: 2000
    )
}
