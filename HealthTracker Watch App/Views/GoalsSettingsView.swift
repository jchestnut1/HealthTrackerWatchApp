//
//  GoalsSettingsView.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/23/26.
//


import SwiftUI

struct GoalSettingsView: View {
    
    @ObservedObject var viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var caloriesGoal: Double
    @State private var waterGoal: Double
    
    private let pressets: [Double] = [1500, 2000, 2500, 3000]
    
    init(viewModel: HealthViewModel) {
        self.viewModel = viewModel
        _caloriesGoal = State(initialValue:  viewModel.goals.dailyCalorieGoal)
        _waterGoal = State(initialValue: viewModel.goals.dailyWaterGoal)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                caloriesSection

                Divider()
                    .background(Color.gray.opacity(0.3))

                waterSection
            }
        }
    }

    // MARK: - Calories Section
    private var caloriesSection: some View {
        VStack(spacing: 20) {
            caloriesHeader
            caloriesGoalText
            caloriesPresetButtons
        }
    }

    private var caloriesHeader: some View {
        VStack {
            Image(systemName: EntryType.calories.icon)
                .foregroundColor(EntryType.calories.color)
            Text("Calories Goal")
                .font(.system(size: 13, weight: .medium))

            Spacer()
        }
    }

    private var caloriesGoalText: some View {
        Text("\(Int(caloriesGoal)) Kcal")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.orange)
    }

    private var caloriesPresetButtons: some View {
        HStack(spacing: 6) {
            ForEach(pressets, id: \.self) { preset in
                caloriesPresetButton(for: preset)
            }
        }
    }

    private func caloriesPresetButton(for preset: Double) -> some View {
        let isSelected = caloriesGoal == preset
        let backgroundColor = isSelected ? Color.orange : Color.orange.opacity(0.2)
        let foregroundColor = isSelected ? Color.black : Color.orange

        return Button {
            caloriesGoal = preset
        } label: {
            Text("\(Int(preset/1000))K")
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Water Section
    private var waterSection: some View {
        VStack(spacing: 20) {
            waterHeader
            waterGoalText
            waterPresetButtons
        }
    }

    private var waterHeader: some View {
        VStack {
            Image(systemName: EntryType.water.icon)
                .foregroundColor(EntryType.water.color)
            Text("Water Goal")
                .font(.system(size: 13, weight: .medium))

            Spacer()
        }
    }

    private var waterGoalText: some View {
        Text("\(Int(waterGoal)) ml")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.cyan)
    }

    private var waterPresetButtons: some View {
        HStack(spacing: 6) {
            ForEach(pressets, id: \.self) { preset in
                waterPresetButton(for: preset)
            }
        }
    }

    private func waterPresetButton(for preset: Double) -> some View {
        let isSelected = waterGoal == preset
        let backgroundColor = isSelected ? Color.cyan : Color.cyan.opacity(0.2)
        let foregroundColor = isSelected ? Color.black : Color.cyan

        return Button {
            waterGoal = preset
        } label: {
            Text("\(Int(preset))ml")
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
