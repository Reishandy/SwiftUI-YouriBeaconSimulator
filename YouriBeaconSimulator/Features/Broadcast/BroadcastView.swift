//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData // TODO: Debug

struct BroadcastView: View {
	
	// TODO: Debug change to viewmodel
	@Query(sort: \BroadcastProject.name) private var projects: [BroadcastProject]
	@State private var currentBroadcastingBeacon: BroadcastBeacon?
	
	
	// TODO: Add a default on the measured tx power slider that sets to -59 on form
	// TODO: Searchable
	// TODO: Animation
	var body: some View {
		NavigationStack {
			// TODO: Group by uuid sort by major asc
			// TODO: Empty and permission state
			List {
				ForEach(projects) { project in
					Section {
						ForEach(project.beacons ?? []) { beacon in
							BroadcastItemView(
								beacon: beacon,
								isBroadcasting: currentBroadcastingBeacon == beacon,
								shouldDisableBroadcast: currentBroadcastingBeacon != nil && currentBroadcastingBeacon != beacon,
								onBroadcastClick: {
									if currentBroadcastingBeacon == beacon {
										currentBroadcastingBeacon = nil
									} else {
										currentBroadcastingBeacon = beacon
									}
								},
								onDeleteClick: {
									// TODO: Delete confirmation sheet
								},
								onEditCLick: {
									// TODO: Share Name, UUID, Major, Minor
								},
								onMeasuredTxPowerChange: { _ in
									// TODO: on TX change
								}
							)
							#if os(macOS)
							.padding(.vertical, 10)
							#endif
						}
					} header: {
						BroadcastSectionHeaderView(title: project.name, uuid: project.proximityUUID)
							.padding(.leading, -10)
					}
					.headerProminence(.increased)
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						// TODO: Plus
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
				
//				ToolbarItem(placement: .primaryAction) {
//					EditButton()
//				}
			}
		}
	}
}

#Preview {
	BroadcastView()
		.modelContainer(PreviewContainer.shared) // TODO: Debug
}
