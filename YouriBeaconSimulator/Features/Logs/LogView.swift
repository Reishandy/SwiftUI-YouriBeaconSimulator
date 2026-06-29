//
//  LogView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import SwiftUI
import SwiftData

struct LogView: View {
	@State var logViewModel: LogViewModel
	
	@Query(sort: \LogSession.startTime, order: .reverse) private var sessions: [LogSession]
	
	var body: some View {
		NavigationStack {
			Group {
				if sessions.isEmpty {
					EmptyStateView(
						systemImage: "doc.text.magnifyingglass",
						title: "No Logs Yet",
						subtitle: "Background events, discovery, and broadcast logs will appear here."
					)
				} else {
					List {
						ForEach(sessions) { session in
							Section {
								let sortedEvents = (session.events ?? []).sorted { $0.timestamp > $1.timestamp }
								
								ForEach(sortedEvents) { event in
									LogItemView(
										event: event,
										onEventDeleteClick: {
											logViewModel.selectedEvent = event
											logViewModel.isDeleteEventConfirmationPresented = true
										}
									)
								}
							} header: {
								LogSectionHeaderView(
									session: session,
									onSessionDeleteClick: {
										logViewModel.selectedSession = session
										logViewModel.isDeleteSessionConfirmationPresented = true
									}
								)
							}
						}
					}
#if os(iOS)
					.listStyle(.insetGrouped)
#endif
				}
			}
			.navigationTitle("Logs")
			.toolbar {
				if !sessions.isEmpty {
					ToolbarItem(placement: .primaryAction) {
						Button(role: .destructive) {
							logViewModel.showClearConfirmation = true
						} label: {
							Text("Clear All")
								.bold()
								.foregroundStyle(.red)
						}
					}
				}
			}
			.alert(
				"Clear All Logs?",
				isPresented: $logViewModel.showClearConfirmation
			) {
				Button("Clear All", role: .destructive) {
					withAnimation {
						logViewModel.clearAllLogs()
					}
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				Text("This will permanently delete all recorded sessions and events.")
			}
			.alert(
				"Delete Log Event?",
				isPresented: $logViewModel.isDeleteEventConfirmationPresented,
				presenting: logViewModel.selectedEvent
			) { event in
				Button("Delete", role: .destructive) {
					withAnimation {
						logViewModel.deleteEvent()
					}
				}
				Button("Cancel", role: .cancel) {
					logViewModel.selectedEvent = nil
				}
			} message: { event in
				Text("Are you sure you want to delete this event?")
			}
			.alert(
				"Delete Log Session?",
				isPresented: $logViewModel.isDeleteSessionConfirmationPresented,
				presenting: logViewModel.selectedSession
			) { session in
				Button("Delete", role: .destructive) {
					withAnimation {
						logViewModel.deleteSession()
					}
				}
				Button("Cancel", role: .cancel) {
					logViewModel.selectedSession = nil
				}
			} message: { session in
				Text("Are you sure you want to delete this session and all its events?")
			}
		}
	}
}

#Preview {
	LogView(logViewModel: LogViewModel(modelContext: PreviewContainer.shared.mainContext))
}
