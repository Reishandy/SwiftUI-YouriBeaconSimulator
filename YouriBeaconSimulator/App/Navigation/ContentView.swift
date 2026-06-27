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
	
	var isPreview: Bool = false
	let preferenceService: PreferenceService
	let permissionService: PermissionService
	let beaconBroadcastService: BeaconBroadcastService
	let backgroundMonitorService: BackgroundMonitorService
	
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
			
			DiscoverView(discoverViewModel: DiscoverViewModel(
				modelContext: modelContext,
				preferenceService: preferenceService,
				permissionService: permissionService,
				discoveryService: BeaconDiscoveryService(permissionService: permissionService),
				backgroundMonitorService: backgroundMonitorService,
				previewBeacons: isPreview ? PreviewContainer.discoveredBeaconPreviews : nil
			))
			.tabItem {
				Label("Discover", systemImage: "dot.radiowaves.up.forward")
			}
		}
	}
}

#Preview {
	let permissionService = PermissionService()
	
	ContentView(
		isPreview: true,
		preferenceService: PreferenceService(),
		permissionService: permissionService,
		beaconBroadcastService: BeaconBroadcastService(permissionService: permissionService),
		backgroundMonitorService: BackgroundMonitorService.shared
	)
	.modelContainer(PreviewContainer.shared)
}
