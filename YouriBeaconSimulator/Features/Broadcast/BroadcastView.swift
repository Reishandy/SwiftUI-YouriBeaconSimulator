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
	
	// TODO: Check what happens if we turn of bt when is broadcasting
	//			escpecialy the currentBroadcastingBeacon
	var body: some View {
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
					EmptyStateView(
						systemImage: "exclamationmark.lock.fill",
						title: "Bluetooth Access Blocked",
						subtitle: "Please enable Bluetooth permission in Settings to simulate an iBeacon.",
						actionText: "Open Settings"
					) {
#if os(iOS)
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
#endif
					}
				} else if broadcastViewModel.bluetoothAuthorization == .allowedAlways &&
							broadcastViewModel.bluetoothState == .poweredOff {
					EmptyStateView(
						systemImage: "exclamationmark.triangle.fill",
						title: "Bluetooth is Powered Off",
						subtitle: "Please turn on Bluetooth from your Control Center or Settings to start broadcasting.",
						actionText: nil
					)
					
				} else if broadcastViewModel.projects.isEmpty {
					EmptyStateView(
						systemImage: "antenna.radiowaves.left.and.right.slash",
						title: "No iBeacon here",
						subtitle: "Add a new iBeacon first",
						actionText: "Add iBeacon"
					) {
						broadcastViewModel.isAddSheetPresented = true
					}
				} else {
					Group {
						if broadcastViewModel.filteredProjectGroups.isEmpty {
							EmptyStateView(
								systemImage: "magnifyingglass",
								title: "No results found",
								subtitle: "Check the spelling or try a new search",
								actionText: "Clear Search"
							) {
								broadcastViewModel.searchTerm = ""
							}
						} else {
							listView
						}
					}
					.animation(.default, value: broadcastViewModel.searchTerm)
#if os(iOS)
					.searchable(
						text: $broadcastViewModel.searchTerm,
						placement: .navigationBarDrawer(displayMode: .always),
						prompt: "Search Project or Beacon..."
					)
#else
					.searchable(
						text: $broadcastViewModel.searchTerm,
						prompt: "Search Project or Beacon..."
					)
#endif
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						broadcastViewModel.isAddSheetPresented = true
					} label: {
						Label("Add", systemImage: "plus")
					}
					.disabled(broadcastViewModel.bluetoothAuthorization != .allowedAlways)
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
							onMeasuredTxPowerChange: { _ in
								// TODO: on TX change
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
	BroadcastView(broadcastViewModel: BroadcastViewModel(modelContext: PreviewContainer.shared.mainContext, permissionService: PermissionService()))
}
