//
//  YouriBeaconSimulatorApp.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData // TODO: Debug

@main
struct YouriBeaconSimulatorApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(PreviewContainer.shared) // TODO: Debug
			#if os(macOS)
				.frame(minWidth: 700)
				.frame(maxWidth: 1000)
			#endif
		}
		#if os(macOS)
		.windowResizability(.contentSize)
		#endif
	}
}
