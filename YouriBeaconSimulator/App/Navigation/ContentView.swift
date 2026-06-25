//
//  ContentView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	
	@State var permissionService = PermissionService()
	
	var body: some View {
		TabView {
			BroadcastView(broadcastViewModel: BroadcastViewModel(
				modelContext: modelContext,
				permissionService: permissionService)
			)
			.tabItem {
				Label("Broadcast", systemImage: "sensor.radiowaves.left.and.right.fill")
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
		.modelContainer(PreviewContainer.shared)
}
