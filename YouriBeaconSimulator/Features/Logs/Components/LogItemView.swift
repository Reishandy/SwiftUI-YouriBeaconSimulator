//
//  LogItemView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import SwiftUI

struct LogItemView: View {
	let event: LogEvent
	let onEventDeleteClick: () -> Void
	
	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: event.category.iconName)
				.foregroundStyle(event.category.color)
				.font(.title2)
			
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text(event.category.rawValue.uppercased())
						.font(.caption2)
						.bold()
						.foregroundStyle(event.category.color)
					
					Spacer()
					
					Text(event.timestamp.formatted(date: .omitted, time: .standard))
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				
				Text(event.message)
					.font(.subheadline)
					.multilineTextAlignment(.leading)
					.lineLimit(nil)
					.fixedSize(horizontal: false, vertical: true)
			}
			.alignmentGuide(.listRowSeparatorLeading) { dimensions in
				dimensions[.leading]
			}
			
#if os(macOS)
			buttonComplex
#endif
		}
		.padding(.vertical, 4)
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
		Button() {
			onEventDeleteClick()
		} label: {
			Label("Delete", systemImage: "trash")
		}
		.tint(.red)
	}
}

#Preview {
	List {
		LogItemView(event: LogEvent(message: "Test", category: .discovery), onEventDeleteClick: {})
		LogItemView(event: LogEvent(message: "Test", category: .broadcast), onEventDeleteClick: {})
		LogItemView(event: LogEvent(message: "Test", category: .background), onEventDeleteClick: {})
		LogItemView(event: LogEvent(message: "This is a long as message that sometimes happens because it is logging you know? I don't even know what I am doing", category: .system), onEventDeleteClick: {})
	}
}
