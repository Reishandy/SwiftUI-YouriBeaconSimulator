//
//  BroadcastItemView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct BroadcastItemView: View {
	let beacon: BroadcastBeacon
	let isBroadcasting: Bool
	let shouldDisableBroadcast: Bool
	
	let onBroadcastClick: () -> Void
	let onDeleteClick: () -> Void
	let onEditCLick: () -> Void
	let onMeasuredTxPowerChange: (Int) -> Void
	
	var body: some View {
		VStack {
			HStack {
				if isBroadcasting {
					Image(systemName: "dot.radiowaves.left.and.right")
						.symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.periodic(delay: 0.3)))
				}
				
				VStack(alignment: .leading) {
					Text(beacon.beaconName)
						.font(.headline)
					
					HStack {
						Text("Major: \(beacon.majorID)")
							.font(.subheadline)
							.opacity(0.8)
						
						Text("Minor: \(beacon.minorID)")
							.font(.subheadline)
							.opacity(0.8)
					}
				}
				.foregroundStyle(shouldDisableBroadcast ? .gray : .primary)
				.alignmentGuide(.listRowSeparatorLeading) { dimensions in
					dimensions[.leading]
				}
				
				Spacer()
				
#if os(macOS)
				buttonComplex
#endif
				
				Button {
					withAnimation() {
						onBroadcastClick()
					}
				} label: {
					Label(isBroadcasting ? "Stop" : "Broadcast", systemImage: isBroadcasting ? "square.fill" : "play.fill")
						.contentTransition(.symbolEffect(.replace))
						.foregroundStyle(isBroadcasting ? .red : .primary)
#if os(iOS)
					// Larger hitbox
						.padding(10)
						.contentShape(Rectangle())
#endif
				}
#if os(iOS)
				.buttonStyle(.plain)
				.labelStyle(.iconOnly)
#endif
				.disabled(shouldDisableBroadcast)
				.geometryGroup()
			}
			
			if isBroadcasting {
				MeasuredTXPowerView(initialValue: -59) { power in
					onMeasuredTxPowerChange(power)
				}
			}
		}
		.listRowBackground(shouldDisableBroadcast ? Color.gray.opacity(0.2) : nil)
#if os(iOS)
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			buttonComplex
		}
		.contextMenu {
			buttonComplex
		}
#endif
	}
	
	@ViewBuilder
	private var buttonComplex: some View {
		if !isBroadcasting && !shouldDisableBroadcast {
			Button() {
				onDeleteClick()
			} label: {
				Label("Delete", systemImage: "trash")
			}
			.tint(.red)
			
			Button {
				onEditCLick()
			} label: {
				Label("Edit", systemImage: "square.and.pencil")
			}
			.tint(.orange)
			
			ShareLink(item: beacon.shareString) {
				Label("Share", systemImage: "square.and.arrow.up")
			}
			.tint(.blue)
		}
	}
}

#Preview {
	@Previewable @State var isBroadcasting: Bool = true
	
	List {
		// Simulate other beacon while one is broadcasting
		BroadcastItemView(
			beacon: BroadcastBeacon(
				beaconName: "Beacon", majorID: 10, minorID: 11
			),
			isBroadcasting: false,
			shouldDisableBroadcast: isBroadcasting,
			onBroadcastClick: {},
			onDeleteClick: {},
			onEditCLick: {},
			onMeasuredTxPowerChange: { _ in }
		)
		
		BroadcastItemView(
			beacon: BroadcastBeacon(
				beaconName: "Beacon", majorID: 10, minorID: 11
			),
			isBroadcasting: isBroadcasting,
			shouldDisableBroadcast: false,
			onBroadcastClick: { isBroadcasting.toggle() },
			onDeleteClick: {},
			onEditCLick: {},
			onMeasuredTxPowerChange: { _ in }
		)
		
		// Simulate other beacon while one is broadcasting
		BroadcastItemView(
			beacon: BroadcastBeacon(
				beaconName: "Beacon", majorID: 10, minorID: 11
			),
			isBroadcasting: false,
			shouldDisableBroadcast: isBroadcasting,
			onBroadcastClick: {},
			onDeleteClick: {},
			onEditCLick: {},
			onMeasuredTxPowerChange: { _ in }
		)
	}
}
