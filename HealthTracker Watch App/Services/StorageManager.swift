//
//  StorageManager.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/18/26.
//


import Foundation
import Combine


class StorageManager{
    static let shared = StorageManager()
    private init(){}
    
    private enum Keys {
        static let userGoals = "userGoals"
        static let diaryEntries = "diary_entries"
    }
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func saveGoals(_ goals: UserGoals){
        if let encoded = try? encoder.encode(goals){
            defaults.set(encoded, forKey: Keys.userGoals)
        }
    }
    
    func loadGoals() -> UserGoals {
        guard let data = defaults.data(forKey: Keys.userGoals),
              let goals = try? decoder.decode(UserGoals.self, from: data)
        else {
            return UserGoals.defaultGoals
        }
        return goals
    }
    
    func saveEntries(_ entries: [DiaryEntry]) {
        if let encoded = try? encoder.encode(entries){
            defaults.set(encoded, forKey: Keys.diaryEntries)
        }
    }
    
    func loadEntries() -> [DiaryEntry] {
        guard let data = defaults.data(forKey: Keys.diaryEntries),
              let entries = try? decoder.decode([DiaryEntry].self, from: data)
                else {
            return []
        }
        return entries
    }
    
    func addEntry(_ entry: DiaryEntry){
        var entries = loadEntries()
        entries.append(entry)
        saveEntries(entries)
    }
    
    func getTodaysEntries() -> [DiaryEntry] {
        let entries = loadEntries()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
    
    func getTodaysTotal(for type: EntryType) -> Double{
        getTodaysEntries()
            .filter { $0.type == type }
            .reduce(0) { $0 + $1.value }
    }
}
