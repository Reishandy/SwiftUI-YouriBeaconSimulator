//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData
import CoreBluetooth

struct BroadcastView: View {
	@State var broadcastViewModel: BroadcastViewModel
	
	var body: some View {
		let animatedSearchBinding = Binding<String>(
			get: { broadcastViewModel.searchTerm },
			set: { newValue in
				withAnimation(.default) {
					broadcastViewModel.searchTerm = newValue
				}
			}
		)
		
		NavigationStack {
			Group {
				if broadcastViewModel.bluetoothAuthorization == .notDetermined {
					EmptyStateView(
						systemImage: "sensor.radiowaves.left.and.right",
						title: "Broadcast as an iBeacon",
						subtitle: "To turn your device into a simulator, we need permission to use your Bluetooth antenna.",
						actionText: "Enable Broadcasting"
					) {
						broadcastViewModel.requestBluetoothPermission()
					}
				} else if broadcastViewModel.bluetoothAuthorization == .denied ||
							broadcastViewModel.bluetoothAuthorization == .restricted {
#if os(iOS)
					EmptyStateView(
						systemImage: "exclamationmark.lock.fill",
						title: "Bluetooth Access Blocked",
						subtitle: "Please enable Bluetooth permission in Settings to simulate an iBeacon.",
						actionText: "Open Settings"
					) {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}
#else
					EmptyStateView(
						systemImage: "exclamationmark.lock.fill",
						title: "Bluetooth Access Blocked",
						subtitle: "Please enable Bluetooth permission in System Settings to discover iBeacons."
					)
#endif
				} else if broadcastViewModel.bluetoothAuthorization == .allowedAlways &&
							broadcastViewModel.bluetoothState == .poweredOff {
					EmptyStateView(
						systemImage: "exclamationmark.triangle.fill",
						title: "Bluetooth is Powered Off",
						subtitle: "Please turn on Bluetooth from your Control Center or Settings to start broadcasting.",
						actionText: nil
					)
				} else {
					ZStack {
						listView
						
						if broadcastViewModel.projects.isEmpty {
							EmptyStateView(
								systemImage: "antenna.radiowaves.left.and.right.slash",
								title: "No iBeacon here",
								subtitle: "Add a new iBeacon first",
								actionText: "Add iBeacon"
							) {
								broadcastViewModel.isAddSheetPresented = true
							}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(.background)
						} else if broadcastViewModel.filteredProjectGroups.isEmpty {
							EmptyStateView(
								systemImage: "magnifyingglass",
								title: "No results found",
								subtitle: "Check the spelling or try a new search",
								actionText: "Clear Search"
							) {
								broadcastViewModel.searchTerm = ""
							}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(.background)
						}
					}
#if os(iOS)
					.searchable(
						text: animatedSearchBinding,
						placement: .navigationBarDrawer(displayMode: .always),
						prompt: "Search Project or Beacon..."
					)
#else
					.searchable(
						text: animatedSearchBinding,
						prompt: "Search Project or Beacon..."
					)
#endif
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("Add") {
						broadcastViewModel.isAddSheetPresented = true
					}
					.disabled(broadcastViewModel.bluetoothAuthorization != .allowedAlways || broadcastViewModel.currentBroadcastingBeacon != nil)
				}
			}
			.sheet(isPresented: $broadcastViewModel.isAddSheetPresented) {
				BroadcastAddSheetView(
					selectedProject: $broadcastViewModel.addSelectedProject,
					projectName: $broadcastViewModel.addProjectName,
					proximityUUID: $broadcastViewModel.addProximityUUID,
					beaconName: $broadcastViewModel.addBeaconName,
					majorID: $broadcastViewModel.addMajorID,
					minorID: $broadcastViewModel.addMinorID,
					availableProjects: broadcastViewModel.projects,
					onDismissClick: {
						broadcastViewModel.isAddSheetPresented = false
						broadcastViewModel.clearAddBeacon()
					},
					onSaveClick: {
						withAnimation {
							broadcastViewModel.addBeacon()
						}
						broadcastViewModel.isAddSheetPresented = false
					}
				)
			}
			.sheet(isPresented: $broadcastViewModel.isEditSheetPresented) {
				if let selectedBeacon = broadcastViewModel.selectedBeacon {
					BroadcastEditSheetView(
						beacon: selectedBeacon,
						availableProjects: broadcastViewModel.projects,
						onDismissClick: {
							broadcastViewModel.isEditSheetPresented = false
							broadcastViewModel.selectedBeacon = nil
						},
						onSaveClick: { selectedProject, projectName, proximityUUID, beaconName, major, minor in
							withAnimation {
								broadcastViewModel.updateBeacon(
									selectedBeacon,
									selectedProject: selectedProject,
									projectName: projectName,
									proximityUUID: proximityUUID,
									beaconName: beaconName,
									majorID: major,
									minorID: minor
								)
							}
							broadcastViewModel.isEditSheetPresented = false
							broadcastViewModel.selectedBeacon = nil
						}
					)
				}
			}
			.alert(
				"Delete Beacon?",
				isPresented: $broadcastViewModel.isDeleteConfirmmationPresented,
				presenting: broadcastViewModel.selectedBeacon
			) { beacon in
				Button("Delete", role: .destructive) {
					withAnimation {
						broadcastViewModel.deleteBeacon()
					}
				}
				Button("Cancel", role: .cancel) {
					broadcastViewModel.selectedBeacon = nil
				}
			} message: { beacon in
				Text("Are you sure you want to delete \(beacon.beaconName)?")
			}
			.onChange(of: broadcastViewModel.bluetoothAuthorization == .allowedAlways) {
				broadcastViewModel.fetchData()
			}
		}
	}
	
	@ViewBuilder
	private var listView: some View {
		List {
			ForEach(broadcastViewModel.filteredProjectGroups) { group in
				Section {
					ForEach(group.beacons) { beacon in
						BroadcastItemView(
							beacon: beacon,
							isBroadcasting: broadcastViewModel.currentBroadcastingBeacon == beacon,
							shouldDisableBroadcast: broadcastViewModel.currentBroadcastingBeacon != nil && broadcastViewModel.currentBroadcastingBeacon != beacon,
							onBroadcastClick: {
								broadcastViewModel.broadcast(beacon)
							},
							onDeleteClick: {
								broadcastViewModel.selectedBeacon = beacon
								broadcastViewModel.isDeleteConfirmmationPresented = true
							},
							onEditCLick: {
								broadcastViewModel.selectedBeacon = beacon
								broadcastViewModel.isEditSheetPresented = true
							},
							onMeasuredTxPowerChange: { newValue in
								broadcastViewModel.updateTxPower(to: Int8(newValue))
							}
						)
					}
				} header: {
					BroadcastSectionHeaderView(title: group.project.name, uuid: group.project.proximityUUID)
#if os(iOS)
						.padding(.leading, -10)
#endif
				}
				.headerProminence(.increased)
			}
		}
	}
}

#Preview {
	BroadcastView(
		broadcastViewModel: BroadcastViewModel(
			modelContext: PreviewContainer.shared.mainContext,
			bluetoothManager: BluetoothPermissionManager(),
			broadcastService: BeaconBroadcastService()
		)
	)
}
