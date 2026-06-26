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
	var id: UUID = UUID()
	var timestamp: Date = Date.now
	
	var name: String = ""
	var proximityUUID: String = ""
	
	@Relationship(deleteRule: .cascade, inverse: \BroadcastBeacon.project)
	var beacons: [BroadcastBeacon]?
	
	init(name: String, proximityUUID: String) {
		self.id = UUID()
		self.timestamp = .now
		self.name = name
		self.proximityUUID = proximityUUID
	}
	
	var sortedBeacons: [BroadcastBeacon] {
		return (beacons ?? []).sorted { beacon1, beacon2 in
			if beacon1.majorID != beacon2.majorID {
				return beacon1.majorID < beacon2.majorID
			}
			
			if beacon1.minorID != beacon2.minorID {
				return beacon1.minorID < beacon2.minorID
			}
			
			return beacon1.timestamp > beacon2.timestamp
		}
	}
}
