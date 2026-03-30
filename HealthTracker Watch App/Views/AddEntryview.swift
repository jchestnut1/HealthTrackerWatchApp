//
//  AddEntryview.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/23/26.
//


import SwiftUI

/// View for adding calories or water entries
/// Design Principle: No big swipes or complex interactions required
struct AddEntryView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HealthViewModel
    let entryType: EntryType
    
    @State private var selectedAmount: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Quick Add Options
    /// Design Principle: Pre-defined options reduce input effort
    private var quickAddOptions: [Double] {
        switch entryType {
        case .calories:
            return [100, 200, 300, 500]
        case .water:
            return [100, 200, 250, 500]
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                currentSelectionDisplay
                quickAddButtonsGrid
                adjustmentControls
                addButton
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Computed Properties
    private var primaryColor: Color {
        entryType == .calories ? .orange : .cyan
    }

    private var navigationTitle: String {
        entryType == .calories ? "Calories" : "Water"
    }

    private var entryTypeName: String {
        entryType == .calories ? "Calories" : "Water"
    }

    // MARK: - Header Section
    /// Design Principle: Clear visual context
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: entryType.icon)
                .font(.system(size: 28))
                .foregroundColor(primaryColor)

            Text("Add \(entryTypeName)")
                .font(.system(size: 14, weight: .medium))
        }
    }

    // MARK: - Current Selection Display
    /// Design Principle: Clear feedback on current state
    private var currentSelectionDisplay: some View {
        Text("\(Int(selectedAmount)) \(entryType.unit)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(primaryColor)
    }

    // MARK: - Quick Add Buttons Grid
    /// Design Principle: One-tap interactions for speed
    private var quickAddButtonsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 10) {
            ForEach(quickAddOptions, id: \.self) { amount in
                quickAddButton(for: amount)
            }
        }
    }

    private func quickAddButton(for amount: Double) -> some View {
        let isSelected = selectedAmount == amount
        let backgroundColor = isSelected ? primaryColor : Color.gray.opacity(0.3)
        let foregroundColor = isSelected ? Color.black : Color.white

        return Button {
            viewModel.playClickHaptic()
            selectedAmount = amount
        } label: {
            Text("+\(Int(amount))")
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Adjustment Controls
    /// Design Principle: Fine control when needed
    private var adjustmentControls: some View {
        HStack {
            decrementButton
            Spacer()
            adjustmentLabel
            Spacer()
            incrementButton
        }
        .padding(.horizontal, 8)
    }

    private var decrementButton: some View {
        Button {
            viewModel.playClickHaptic()
            selectedAmount = max(0, selectedAmount - 50)
        } label: {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var adjustmentLabel: some View {
        Text("Adjust")
            .font(.system(size: 12))
            .foregroundColor(.gray)
    }

    private var incrementButton: some View {
        Button {
            viewModel.playClickHaptic()
            selectedAmount += 50
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Add Button
    /// Design Principle: Clear primary action
    private var addButton: some View {
        let isEnabled = selectedAmount > 0
        let backgroundColor = isEnabled ? primaryColor : Color.gray.opacity(0.3)
        let foregroundColor = isEnabled ? Color.black : Color.gray

        return Button {
            if selectedAmount > 0 {
                if entryType == .calories {
                    viewModel.addCalories(selectedAmount)
                } else {
                    viewModel.addWater(selectedAmount)
                }
                dismiss()
            }
        } label: {
            Text("Add")
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(selectedAmount == 0)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddEntryView(viewModel: HealthViewModel(), entryType: .calories)
    }
}
