//
//  PreviewContainer.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftData
import SwiftUI

@MainActor
class PreviewContainer {
	static let shared: ModelContainer = {
		do {
			let schema = Schema([BroadcastProject.self, BroadcastBeacon.self])
			let config = ModelConfiguration(isStoredInMemoryOnly: true)
			let container = try ModelContainer(for: schema, configurations: [config])
			let context = container.mainContext
			
			let project1 = BroadcastProject(name: "Lobby System", proximityUUID: UUID().uuidString)
			let project2 = BroadcastProject(name: "Meeting Rooms", proximityUUID: UUID().uuidString)
			
			container.mainContext.insert(project1)
			container.mainContext.insert(project2)
			
			let beacon1 = BroadcastBeacon(beaconName: "Main Entrance", majorID: 1, minorID: 100)
			let beacon2 = BroadcastBeacon(beaconName: "Reception Desk", majorID: 1, minorID: 200)
			let beacon3 = BroadcastBeacon(beaconName: "Room A", majorID: 2, minorID: 101)
			
			beacon1.project = project1
			beacon2.project = project1
			beacon3.project = project2
			
			return container
		} catch {
			fatalError("Failed to create preview SwiftData container: \(error)")
		}
	}()
}
