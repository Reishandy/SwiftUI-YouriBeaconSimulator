//
//  LogViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
class LogViewModel {
	private var modelContext: ModelContext
	
	var showClearConfirmation = false
	
	var selectedEvent: LogEvent?
	var selectedSession: LogSession?
	var isDeleteEventConfirmationPresented = false
	var isDeleteSessionConfirmationPresented = false
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}
	
	func clearAllLogs() {
		do {
			let descriptor = FetchDescriptor<LogSession>(predicate: #Predicate<LogSession> { !$0.isActive })
			let sessionsToDelete = try modelContext.fetch(descriptor)
			
			for session in sessionsToDelete {
				modelContext.delete(session)
			}
			
			try modelContext.save()
		} catch {
			print("ERROR > Failed to clear logs: \(error)")
		}
	}
	
	func deleteSession() {
		guard let sessionToDelete = selectedSession else { return }
		guard !sessionToDelete.isActive else { return }
		
		modelContext.delete(sessionToDelete)
		do {
			try modelContext.save()
			selectedSession = nil
		} catch {
			print("ERROR > Failed to delete session: \(error)")
		}
	}
	
	func deleteEvent() {
		guard let eventToDelete = selectedEvent else { return }
		guard eventToDelete.category != .system else { return }
		
		let parentSession = eventToDelete.session
		modelContext.delete(eventToDelete)
		
		do {
			try modelContext.save()
			
			if let session = parentSession, (session.events?.isEmpty ?? true) {
				if !session.isActive {
					modelContext.delete(session)
					try modelContext.save()
				}
			}
			
			selectedEvent = nil
		} catch {
			print("ERROR > Failed to delete event: \(error)")
		}
	}
}
