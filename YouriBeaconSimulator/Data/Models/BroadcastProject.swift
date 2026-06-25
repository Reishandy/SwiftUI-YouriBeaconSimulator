//
//  BroadcastProject.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
import SwiftData

@Model
class BroadcastProject: Identifiable {
	var id: UUID
	var timestamp: Date
	
	var name: String
	var proximityUUID: String
	
	@Relationship(deleteRule: .cascade, inverse: \BroadcastBeacon.project)
	var beacons: [BroadcastBeacon]?
	
	init(name: String, proximityUUID: String) {
		self.id = UUID()
		self.timestamp = .now
		self.name = name
		self.proximityUUID = proximityUUID
	}
}
