//
//  LoggingService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData

@ModelActor
public actor LoggingService {
	private var currentSessionID: PersistentIdentifier?
	
	func startNewSession(deviceDescription: String, deviceIdentifier: String) {
		let descriptor = FetchDescriptor<LogSession>(predicate: #Predicate<LogSession> {
			$0.isActive == true && $0.deviceIdentifier == deviceIdentifier
		})
		
		if let activeSessions = try? modelContext.fetch(descriptor) {
			for oldSession in activeSessions {
				oldSession.isActive = false
			}
		}
		
		let session = LogSession(deviceIdentifier: deviceIdentifier)
		modelContext.insert(session)
		
		do {
			try modelContext.save()
			currentSessionID = session.persistentModelID
			
			self.log(message: "App Session Started on \(deviceDescription)", category: .system)
			
			print("Started new logging session: \(session.id) for device: \(deviceIdentifier)")
		} catch {
			print("Failed to start logging session: \(error)")
		}
	}
	
	func log(message: String, category: LogCategory) {
		guard let sessionID = currentSessionID,
			  let session = modelContext.model(for: sessionID) as? LogSession else {
			return
		}
		
		let event = LogEvent(message: message, category: category)
		modelContext.insert(event)
		event.session = session
		
		do {
			try modelContext.save()
		} catch {
			print("Failed to save log event: \(error)")
		}
	}
	
	func endCurrentSession() {
		guard let sessionID = currentSessionID,
			  let session = modelContext.model(for: sessionID) as? LogSession else {
			return
		}
		
		session.isActive = false
		
		do {
			try modelContext.save()
			print("Ended logging session: \(session.id)")
			currentSessionID = nil
		} catch {
			print("Failed to end logging session: \(error)")
		}
	}
}
