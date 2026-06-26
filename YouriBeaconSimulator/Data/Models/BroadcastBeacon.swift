//
//  BroadcastBeacon.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
import SwiftData

@Model
class BroadcastBeacon: Identifiable, Equatable {
	var id: UUID = UUID()
	var timestamp: Date = Date.now
	
	var beaconName: String = ""
	var majorID: Int = 0
	var minorID: Int = 0
	
	var project: BroadcastProject?
	
	init(beaconName: String, majorID: Int, minorID: Int) {
		self.id = UUID()
		self.timestamp = .now
		self.beaconName = beaconName
		self.majorID = majorID
		self.minorID = minorID
	}
	
	var shareString: String {
		 """
		 iBeacon configuration for \(beaconName)
		 ------------------------------------
		 Project: \(project?.name ?? "Unknown")
		 UUID: \(project?.proximityUUID ?? "Unknown")
		 Beacon: \(beaconName)
		 Major: \(majorID)
		 Minor: \(minorID)
		 """
	}
}
