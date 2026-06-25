//
//  ContentView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData // TODO: Debug

struct ContentView: View {
    var body: some View {
		TabView {
			BroadcastView()
				.tabItem {
					Label("Broadcast", systemImage: "antenna.radiowaves.left.and.right")
				}
			
			DiscoverView()
				.tabItem {
					Label("Discover", systemImage: "dot.radiowaves.up.forward")
				}
		}
    }
}

#Preview {
    ContentView()
		.modelContainer(PreviewContainer.shared) // TODO: Debug
}
