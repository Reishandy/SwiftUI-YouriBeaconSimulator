//
//  DiscoverView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct DiscoverView: View {
	@State var discoverViewModel: DiscoverViewModel
	
	// TODO: Debug
	@State private var selectedItem: String?
	
	var body: some View {
		NavigationSplitView {
			Group {
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
#if os(iOS)
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
#endif
					}
				} else {
					ZStack {
						if discoverViewModel.isDiscovering {
							// TODO: Empty state with animation icon and stop button
							if true {
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
				}
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
			if let selectedItem {
				Text("Selected: \(selectedItem)")
					.navigationTitle(selectedItem)
			} else {
				Text("Select an item from the sidebar")
					.foregroundColor(.secondary)
			}
		}
	}
	
	@ViewBuilder
	private var listView: some View {
		// TODO: Haptic when new entry comes in
		// TODO: Item list
		List(1...99, id: \.self, selection: $selectedItem) { item in
			NavigationLink("Item \(item)", value: "Item \(item)")
		}
	}
}

#Preview {
	let permissionService = PermissionService()
	
	DiscoverView(discoverViewModel: DiscoverViewModel(modelContext: PreviewContainer.shared.mainContext, preferenceService: PreferenceService(), permissionService: permissionService))
}
