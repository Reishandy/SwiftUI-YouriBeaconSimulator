//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct BroadcastView: View {
	// TODO: Group by uuid sort by major asc
	// TODO: Add a default on the measured tx power slider that sets to -59 on form
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(1...5, id: \.self) { sec in
					Section {
						ForEach(1...3, id: \.self) { num in
							BroadcastItemView(
								isBroadcasting: false,
								shouldDisableBroadcast: false,
								onBroadcastClick: {},
								onDeleteClick: {},
								onEditCLick: {
									// TODO: Share Name, UUID, Major, Minor
								},
								onShareClick: {},
								onMeasuredTxPowerChange: { _ in }
							)
						}
					} header: {
						BroadcastSectionHeaderView(title: "App Name", uuid: UUID().uuidString)
							.padding(.leading, -10)
					}
					.headerProminence(.increased)
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
			}
		}
	}
}

#Preview {
	BroadcastView()
}
