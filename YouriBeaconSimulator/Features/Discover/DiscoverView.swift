//
//  DiscoverView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData
import CoreLocation
import CoreBluetooth

struct DiscoverView: View {
	@State var discoverViewModel: DiscoverViewModel
	
	var body: some View {
		NavigationSplitView {
			Group {
#if os(iOS)
				if discoverViewModel.locationAuthorization == .notDetermined {
					EmptyStateView(
						systemImage: "location.fill",
						title: "Location Access Required",
						subtitle: "iBeacon discovery requires location permissions to detect and measure distances to nearby beacons.",
						actionText: "Enable Location"
					) {
						discoverViewModel.requestLocationPermission()
					}
				} else if discoverViewModel.locationAuthorization == .denied ||
							discoverViewModel.locationAuthorization == .restricted {
					EmptyStateView(
						systemImage: "location.slash.fill",
						title: "Location Access Blocked",
						subtitle: "Please enable Location permission in Settings to discover iBeacons.",
						actionText: "Open Settings"
					) {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}
				} else {
					mainDiscoveryContent
				}
#elseif os(macOS)
				if discoverViewModel.bluetoothAuthorization == .notDetermined {
					EmptyStateView(
						systemImage: "sensor.radiowaves.left.and.right",
						title: "Bluetooth Required",
						subtitle: "To discover nearby iBeacons, we need permission to use your Bluetooth antenna.",
						actionText: "Enable Bluetooth"
					) {
						discoverViewModel.requestBluetoothPermission()
					}
				} else if discoverViewModel.bluetoothAuthorization == .denied ||
							discoverViewModel.bluetoothAuthorization == .restricted {
					EmptyStateView(
						systemImage: "exclamationmark.lock.fill",
						title: "Bluetooth Access Blocked",
						subtitle: "Please enable Bluetooth permission in System Settings to discover iBeacons."
					)
				} else if discoverViewModel.bluetoothAuthorization == .allowedAlways &&
							discoverViewModel.bluetoothState == .poweredOff {
					EmptyStateView(
						systemImage: "exclamationmark.triangle.fill",
						title: "Bluetooth is Powered Off",
						subtitle: "Please turn on Bluetooth to start discovering.",
						actionText: nil
					)
				} else {
					mainDiscoveryContent
				}
#endif
			}
			.navigationTitle(discoverViewModel.isDiscovering ? "Discovering" : "Discover")
			.navigationSubtitle(discoverViewModel.isDiscovering ? discoverViewModel.proximityUUID : "")
			.navigationSplitViewColumnWidth(min: 300, ideal: 300, max: 500)
			.toolbar {
				if discoverViewModel.isDiscovering {
					ToolbarItem(placement: .primaryAction) {
						HStack {
							Button("Stop") {
								withAnimation {
									discoverViewModel.stopDiscovery()
								}
							}
							
							Image(systemName: "dot.radiowaves.up.forward")
								.symbolEffect(
									.variableColor.iterative.dimInactiveLayers.nonReversing,
									options: .repeat(.periodic(delay: 0.3))
								)
								.padding(.leading, -10)
						}
						.padding(.trailing, 6)
					}
				}
			}
		} detail: {
			if !discoverViewModel.isDiscovering {
				Text("Start iBeacon discovery first")
					.foregroundColor(.secondary)
			} else if let selectedBeacon = discoverViewModel.selectedBeacon {
				DiscoveryDetailView(discoveredBeacon: selectedBeacon)
			} else {
				Text("Select an item from the sidebar")
					.foregroundColor(.secondary)
			}
		}
	}
	
	@ViewBuilder
	private var mainDiscoveryContent: some View {
		ZStack {
			if discoverViewModel.isDiscovering {
				if discoverViewModel.discoveredBeacons.isEmpty {
					EmptyStateView(
						systemImage: "dot.radiowaves.up.forward",
						title: "Discovering",
						subtitle: "No nearby iBeacon has been discovered yet.",
						actionText: "Stop Discovering"
					) {
						withAnimation {
							discoverViewModel.stopDiscovery()
						}
					}
				} else {
					listView
				}
			} else {
#if os(iOS)
				DiscoverFormView(
					selectedProject: $discoverViewModel.selectedProject,
					proximityUUID: $discoverViewModel.proximityUUID,
					isBackgroundEnabled: Binding(
						get: { discoverViewModel.isBackgroundEnabled },
						set: { discoverViewModel.isBackgroundEnabled = $0 }
					),
					isBackgroundReady: discoverViewModel.isBackgroundReady,
					hasDeniedPermissions: discoverViewModel.hasDeniedBackgroundPermissions,
					onGrantPermissionClick: {
						if discoverViewModel.hasDeniedBackgroundPermissions {
							if let url = URL(string: UIApplication.openSettingsURLString) {
								UIApplication.shared.open(url)
							}
						} else {
							discoverViewModel.requestBackgroundPermissions()
						}
					},
					availableProjects: discoverViewModel.projects,
					onStartDiscoveryClick: {
						withAnimation {
							discoverViewModel.startDiscovery()
						}
					}
				)
#else
				DiscoverFormView(
					selectedProject: $discoverViewModel.selectedProject,
					proximityUUID: $discoverViewModel.proximityUUID,
					availableProjects: discoverViewModel.projects,
					onStartDiscoveryClick: {
						withAnimation {
							discoverViewModel.startDiscovery()
						}
					}
				)
#endif
			}
		}
		.onAppear {
			discoverViewModel.fetchData()
		}
	}
	
	@ViewBuilder
	private var listView: some View {
		List(selection: $discoverViewModel.selectedBeaconID) {
			if !discoverViewModel.targetBeacons.isEmpty {
				Section {
					ForEach(discoverViewModel.targetBeacons) { beacon in
						NavigationLink(value: beacon.id) {
							DiscoverItemView(discoveredBeacon: beacon)
						}
					}
				}
			}
			
			if !discoverViewModel.otherBeacons.isEmpty {
				Section("Other Discovered iBeacons") {
					ForEach(discoverViewModel.otherBeacons) { beacon in
						NavigationLink(value: beacon.id) {
							DiscoverItemView(discoveredBeacon: beacon)
						}
					}
				}
			}
		}
	}
}

#Preview {
	DiscoverView(
		discoverViewModel: DiscoverViewModel(
			modelContext: PreviewContainer.shared.mainContext,
			preferenceService: PreferenceService(),
			locationPermissionManager: LocationPermissionManager(),
			bluetoothPermissionManager: BluetoothPermissionManager(),
			notificationPermissionManager: NotificationPermissionManager(),
			discoveryService: BeaconDiscoveryService(),
			backgroundMonitorService: BackgroundMonitorService.shared
		)
	)
}
