//
//  EmptyStateView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct EmptyStateView: View {
	let systemImage: String
	let title: String
	let subtitle: String
	var actionText: String? = nil
	var action: (() -> Void)? = nil
	
    var body: some View {
		VStack(spacing: 18) {
			Image(systemName: systemImage)
				.font(.largeTitle)
			
			VStack(spacing: 4) {
				Text(title)
					.font(.title2)
					.bold()
				
				Text(subtitle)
					.opacity(0.8)
			}
			.multilineTextAlignment(.center)
			
			if let action = action, let actionText = actionText {
				Button {
					action()
				} label: {
					Text(actionText)
						.frame(minWidth: 150)
						.foregroundStyle(.prominentButtonText)
				}
				.buttonStyle(.borderedProminent)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.horizontal, 20)
    }
}

#Preview {
    EmptyStateView(
		systemImage: "tray",
		title: "Nothing here",
		subtitle: "Add something first"
	)
}

#Preview {
	EmptyStateView(
		systemImage: "tray",
		title: "Nothing here",
		subtitle: "Add something first",
		actionText: "Action"
	) {
		//
	}
}
