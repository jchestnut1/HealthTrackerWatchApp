//
//  HeartRateView.swift
//  HealthTracker
//
//  Created by Jay Chestnut on 3/30/26.
//


import SwiftUI

struct HeartRateView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.isHealthKitAvailable {
                    heartRateContent
                } else {
                    authorizationContent
                }
            }
            .padding()
        }.navigationTitle("HeartRate")
    }
    
    private var heartRateContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
                .scaleEffect(1.15)
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: true
                )
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(viewModel.formattedHeartRate)
            }
        }
    }
    
    private var authorizationContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("Heart Rate")
                .font(.headline)
            
            Text("Alow Acces to Heart Rate")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if !viewModel.isHealthKitAvailable {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("HealthKit is not available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button(action: {
                    Task {
                        await viewModel.requestHealthKitAuthorization()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("Authorize")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            
            if let error = viewModel.heartRateErrors {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
