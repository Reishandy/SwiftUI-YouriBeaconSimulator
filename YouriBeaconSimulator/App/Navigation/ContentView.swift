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
	
	let permissionService: PermissionService
	let beaconBroadcastService: BeaconBroadcastService
	
	var body: some View {
		TabView {
			BroadcastView(broadcastViewModel: BroadcastViewModel(
				modelContext: modelContext,
				permissionService: permissionService,
				broadcastService: beaconBroadcastService
			))
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
	let permissionService = PermissionService()
	
	ContentView(
		permissionService: permissionService,
		beaconBroadcastService: BeaconBroadcastService(permissionService: permissionService)
	)
	.modelContainer(PreviewContainer.shared)
}
