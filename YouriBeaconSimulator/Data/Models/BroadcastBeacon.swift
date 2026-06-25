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
	var id: UUID
	var timestamp: Date
	
	var beaconName: String
	var majorID: Int
	var minorID: Int
	
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
		Beacon: \(beaconName)
		Major: \(majorID)
		Minor: \(minorID)
		----------
		UUID: \(project?.proximityUUID ?? "Unknown")
		Project: \(project?.name ?? "Unknown")
		"""
	}
}
