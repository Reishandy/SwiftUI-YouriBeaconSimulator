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
			let schema = Schema([
				BroadcastProject.self,
				BroadcastBeacon.self,
				LogSession.self,
				LogEvent.self
			])
			let config = ModelConfiguration(isStoredInMemoryOnly: true)
			let container = try ModelContainer(for: schema, configurations: [config])
			let context = container.mainContext
			
			let project1 = BroadcastProject(name: "Lobby System", proximityUUID: UUID().uuidString)
			let project2 = BroadcastProject(name: "Meeting Rooms", proximityUUID: UUID().uuidString)
			let project3 = BroadcastProject(name: "Cafeteria", proximityUUID: UUID().uuidString)
			let project4 = BroadcastProject(name: "Parking Garage", proximityUUID: UUID().uuidString)
			
			let beacon1 = BroadcastBeacon(beaconName: "Main Entrance", majorID: 2, minorID: 100)
			let beacon2 = BroadcastBeacon(beaconName: "Reception Desk", majorID: 1, minorID: 200)
			let beacon3 = BroadcastBeacon(beaconName: "Elevator Bank A", majorID: 1, minorID: 201)
			let beacon4 = BroadcastBeacon(beaconName: "Room A", majorID: 2, minorID: 101)
			let beacon5 = BroadcastBeacon(beaconName: "Room B", majorID: 1, minorID: 102)
			let beacon6 = BroadcastBeacon(beaconName: "Conference Hall", majorID: 3, minorID: 150)
			let beacon7 = BroadcastBeacon(beaconName: "Main Food Court", majorID: 1, minorID: 10)
			let beacon8 = BroadcastBeacon(beaconName: "Coffee Shop", majorID: 3, minorID: 20)
			let beacon9 = BroadcastBeacon(beaconName: "Level 1 North", majorID: 5, minorID: 1)
			let beacon10 = BroadcastBeacon(beaconName: "Level 2 South", majorID: 4, minorID: 2)
			
			beacon1.project = project1
			beacon2.project = project1
			beacon3.project = project1
			beacon4.project = project2
			beacon5.project = project2
			beacon6.project = project2
			beacon7.project = project3
			beacon8.project = project3
			beacon9.project = project4
			beacon10.project = project4
			
			context.insert(project1)
			context.insert(project2)
			context.insert(project3)
			context.insert(project4)
			
			let now = Date.now
			let defaultUUIDString = project1.proximityUUID
			
			let s1 = LogSession(id: UUID(), startTime: now.addingTimeInterval(-172800))
			let s1_e1 = LogEvent(message: "App Session Started", category: .system)
			s1_e1.timestamp = s1.startTime.addingTimeInterval(2)
			let s1_e2 = LogEvent(message: "Started scanning for UUID: \(defaultUUIDString)", category: .discovery)
			s1_e2.timestamp = s1.startTime.addingTimeInterval(15)
			let s1_e3 = LogEvent(message: "Discovered new beacon!\nMajor: 2\nMinor: 101\nDistance: 3.20m\nRSSI: -70 dBm", category: .discovery)
			s1_e3.timestamp = s1.startTime.addingTimeInterval(22)
			let s1_e4 = LogEvent(message: "Stopped scanning.", category: .discovery)
			s1_e4.timestamp = s1.startTime.addingTimeInterval(300)
			
			[s1_e1, s1_e2, s1_e3, s1_e4].forEach { $0.session = s1 }
			context.insert(s1)
			
			let s2 = LogSession(id: UUID(), startTime: now.addingTimeInterval(-86400))
			let s2_e1 = LogEvent(message: "Entered background region for UUID: \(defaultUUIDString)", category: .background)
			s2_e1.timestamp = s2.startTime.addingTimeInterval(10)
			let s2_e2 = LogEvent(message: "Background Ranged!\nMajor: 1\nMinor: 100\nDistance: Unknown\nRSSI: -85 dBm", category: .background)
			s2_e2.timestamp = s2.startTime.addingTimeInterval(15)
			let s2_e3 = LogEvent(message: "Background Ranged!\nMajor: 2\nMinor: 101\nDistance: 5.00m\nRSSI: -75 dBm", category: .background)
			s2_e3.timestamp = s2.startTime.addingTimeInterval(16)
			let s2_e4 = LogEvent(message: "Exited background region for UUID: \(defaultUUIDString)", category: .background)
			s2_e4.timestamp = s2.startTime.addingTimeInterval(3600)
			
			[s2_e1, s2_e2, s2_e3, s2_e4].forEach { $0.session = s2 }
			context.insert(s2)
			
			let s3 = LogSession(id: UUID(), startTime: now.addingTimeInterval(-7200))
			let s3_e1 = LogEvent(message: "App Session Started", category: .system)
			s3_e1.timestamp = s3.startTime.addingTimeInterval(1)
			let s3_e2 = LogEvent(message: "Started broadcasting\n'Main Entrance' (Major: 2, Minor: 100)\nat -59 dBm.", category: .broadcast)
			s3_e2.timestamp = s3.startTime.addingTimeInterval(45)
			let s3_e3 = LogEvent(message: "Updated TX Power for 'Main Entrance'\nto -65 dBm", category: .broadcast)
			s3_e3.timestamp = s3.startTime.addingTimeInterval(600)
			let s3_e4 = LogEvent(message: "Stopped broadcasting\n'Main Entrance'", category: .broadcast)
			s3_e4.timestamp = s3.startTime.addingTimeInterval(1800)
			
			[s3_e1, s3_e2, s3_e3, s3_e4].forEach { $0.session = s3 }
			context.insert(s3)
			
			let s4 = LogSession(id: UUID(), startTime: now.addingTimeInterval(-300))
			let s4_e1 = LogEvent(message: "App Session Started", category: .system)
			s4_e1.timestamp = s4.startTime.addingTimeInterval(1)
			let s4_e2 = LogEvent(message: "Started scanning for UUID: \(defaultUUIDString)", category: .discovery)
			s4_e2.timestamp = s4.startTime.addingTimeInterval(15)
			let s4_e3 = LogEvent(message: "Discovered new beacon!\nMajor: 1\nMinor: 100\nDistance: 0.80m\nRSSI: -42 dBm", category: .discovery)
			s4_e3.timestamp = s4.startTime.addingTimeInterval(17)
			let s4_e4 = LogEvent(message: "Beacon (Major: 1, Minor: 100) went out of range (stale).", category: .discovery)
			s4_e4.timestamp = s4.startTime.addingTimeInterval(45)
			let s4_e5 = LogEvent(message: "Beacon (Major: 1, Minor: 100) is back in range.", category: .discovery)
			s4_e5.timestamp = s4.startTime.addingTimeInterval(75)
			
			[s4_e1, s4_e2, s4_e3, s4_e4, s4_e5].forEach { $0.session = s4 }
			context.insert(s4)
			
			return container
		} catch {
			fatalError("Failed to create preview SwiftData container: \(error)")
		}
	}()
	
	static var discoveredBeaconPreviews: [DiscoveredBeacon] {
		let defaultUUID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
		let now = Date.now
		let staleDate = now.addingTimeInterval(-60.0) // 1 minute ago
		return [
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 100, rssi: -35, accuracy: 0.2, proximity: .immediate, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 101, rssi: -60, accuracy: 1.5, proximity: .near, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 102, rssi: -85, accuracy: 5.0, proximity: .far, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 1, minor: 103, rssi: 0, accuracy: -1.0, proximity: .unknown, lastSeen: now),
			
			DiscoveredBeacon(uuid: defaultUUID, major: 2, minor: 200, rssi: -90, accuracy: 8.0, proximity: .unknown, lastSeen: staleDate, isCurrentlyActive: false)
		]
	}
}
