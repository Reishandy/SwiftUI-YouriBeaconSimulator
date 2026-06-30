//
//  LogSectionHeaderView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import SwiftUI

struct LogSectionHeaderView: View {
	let session: LogSession
	let onSessionDeleteClick: () -> Void
	
	var body: some View {
		HStack {
			Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
				.font(.subheadline)
				.textCase(nil)
			
			Spacer()
			
			HStack(spacing: 4) {
				Image(systemName: session.isActive ? "tag.circle" : "tag.fill")
					.font(session.isActive ? .callout : .caption2)
				Text(session.id.uuidString.prefix(8))
					.font(session.isActive ? .caption : .caption2)
			}
			.foregroundStyle(session.isActive ? Color.accent : .secondary)
			.textCase(nil)
			
			if !session.isActive {
				Menu {
					Button(role: .destructive) {
						onSessionDeleteClick()
					} label: {
						Label("Delete Session", systemImage: "trash")
					}
				} label: {
					Image(systemName: "trash")
						.foregroundStyle(.red)
						.font(.subheadline)
				}
			}
		}
	}
}

#Preview {
	List {
		Section {
			LogItemView(event: LogEvent(message: "Test", category: .discovery), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .broadcast), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .background), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "This is a long as message that sometimes happens because it is logging you know? I don't even know what I am doing", category: .system), onEventDeleteClick: {})
		} header: {
			LogSectionHeaderView(session: LogSession(), onSessionDeleteClick: {})
		}
		
		Section {
			LogItemView(event: LogEvent(message: "Test", category: .discovery), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .broadcast), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .background), onEventDeleteClick: {})
			LogItemView(event: LogEvent(message: "This is a long as message that sometimes happens because it is logging you know? I don't even know what I am doing", category: .system), onEventDeleteClick: {})
		} header: {
			LogSectionHeaderView(session: LogSession(isActive: false), onSessionDeleteClick: {})
		}
	}
}
