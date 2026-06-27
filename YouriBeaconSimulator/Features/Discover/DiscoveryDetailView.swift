//
//  DiscoveryDetailView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 27/06/26.
//

import SwiftUI

struct DiscoveryDetailView: View {
	let discoveredBeacon: DiscoveredBeacon
	
	var body: some View {
		Form {
			Section {
				proximityHeader
			}
			.listRowBackground(Color.clear)
			.listRowInsets(EdgeInsets())
			
			Section("Identifiers") {
				detailRow(title: "UUID", value: discoveredBeacon.uuid.uuidString, isCopyable: true)
				detailRow(title: "Major ID", value: String(discoveredBeacon.major), isCopyable: true)
				detailRow(title: "Minor ID", value: String(discoveredBeacon.minor), isCopyable: true)
			}
			
			Section("Signal & Distance") {
				detailRow(title: "RSSI (Raw Signal)", value: "\(discoveredBeacon.rssi) dBm")
				
				detailRow(
					title: "Estimated Distance",
					value: discoveredBeacon.accuracy < 0 ? "Unknown" : String(format: "%.2f meters", discoveredBeacon.accuracy)
				)
			}
			
			Section("Status") {
				HStack {
					Text("Last Seen")
						.foregroundStyle(.primary)
					
					Spacer(minLength: 16)
					
					TimelineView(.periodic(from: .now, by: 1)) { context in
						Text(Self.timeFormatter.localizedString(for: discoveredBeacon.lastSeen, relativeTo: context.date))
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.trailing)
							.font(.body.monospacedDigit())
					}
				}
			}
		}
		.formStyle(.grouped)
		.textSelection(.enabled)
		.animation(.easeInOut, value: discoveredBeacon.isCurrentlyActive)
	}
	
	@ViewBuilder
	private var proximityHeader: some View {
		VStack(spacing: 16) {
			Image(
				systemName: discoveredBeacon.isCurrentlyActive ? "wifi" : "wifi.slash",
				variableValue: discoveredBeacon.proximity.iconVariableValue
			)
			.font(.system(size: 85, weight: .semibold))
			.foregroundStyle(discoveredBeacon.isCurrentlyActive ? discoveredBeacon.proximity.iconColor : .gray)
			
			VStack(spacing: 6) {
				Text(discoveredBeacon.proximity.rawValue)
					.font(.largeTitle)
					.bold()
				
				Text(discoveredBeacon.isCurrentlyActive ? "Currently Active" : "Inactive")
					.font(.headline)
					.foregroundStyle(discoveredBeacon.isCurrentlyActive ? .secondary : Color.red)
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 24)
	}
	
	@ViewBuilder
	private func detailRow(title: String, value: String, isCopyable: Bool = false) -> some View {
		HStack(alignment: .top) {
			Text(title)
				.foregroundStyle(.primary)
			
			Spacer(minLength: 16)
			
			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.trailing)
				.font(.body.monospacedDigit())
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			if isCopyable {
				Button {
					ClipboardUtilities.copy(value)
				} label: {
					Label("Copy", systemImage: "doc.on.clipboard")
				}
				.tint(.blue)
			}
		}
		.contextMenu {
			if isCopyable {
				Button {
					ClipboardUtilities.copy(value)
				} label: {
					Label("Copy \(title)", systemImage: "doc.on.doc")
				}
			}
		}
	}
	
	private static let timeFormatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter
	}()
}

#Preview {
	DiscoveryDetailView(
		discoveredBeacon: DiscoveredBeacon(
			uuid: UUID(),
			major: 1,
			minor: 100,
			rssi: -35,
			accuracy: 0.2,
			proximity: .immediate,
			lastSeen: .now
		)
	)
}
