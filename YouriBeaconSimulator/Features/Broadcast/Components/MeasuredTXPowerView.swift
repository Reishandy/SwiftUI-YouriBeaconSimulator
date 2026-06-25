//
//  MeasuredTXPowerView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct MeasuredTXPowerView: View {
	let onMeasuredTxPowerChange: (Int) -> Void
	
	@State private var measuredTxPower: Double
	
	init(
		initialValue: Int,
		onMeasuredTxPowerChange: @escaping (Int) -> Void
	) {
		self.onMeasuredTxPowerChange = onMeasuredTxPowerChange
		
		self._measuredTxPower = State(initialValue: Double(initialValue))
	}
	
    var body: some View {
		VStack {
			Slider(value: $measuredTxPower, in: (-100)...(-30)) {
			#if os(iOS)
				Text("Measured TX Power")
			#endif
			} minimumValueLabel: {
				Text("-100 dBm")
					.font(.caption)
			} maximumValueLabel: {
				Text("-30 dBm")
					.font(.caption)
			} onEditingChanged: { _ in
				onMeasuredTxPowerChange(Int(measuredTxPower.rounded()))
			}
			
			HStack {
				Text("Closer")
					.font(.caption)
					.opacity(0.8)
				
				Spacer()
				
				Text("Sets the measured TX power.")
					.font(.caption2)
					.opacity(0.8)
				
				Spacer()
				
				Text("Further")
					.font(.caption)
					.opacity(0.8)
			}
		}
    }
}

#Preview {
	MeasuredTXPowerView(initialValue: -59) { _ in }
}
