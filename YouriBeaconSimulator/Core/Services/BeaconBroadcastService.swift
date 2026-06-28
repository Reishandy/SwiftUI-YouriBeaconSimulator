//
//  BeaconBroadcastService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import CoreBluetooth
import Observation

@Observable
@MainActor
class BeaconBroadcastService: BeaconBroadcasterDelegate {
	private var broadcaster: BeaconBroadcaster
	
	private(set) var activeBeacon: BroadcastBeacon?
	private var pendingTxPower: Int8?
	
	init() {
#if os(macOS)
		self.broadcaster = MacOSBeaconBroadcaster()
#else
		self.broadcaster = IOSBeaconBroadcaster()
#endif
		
		self.broadcaster.delegate = self
	}
	
	func startBroadcasting(beacon: BroadcastBeacon, txPower: Int8) {
		self.activeBeacon = beacon
		self.pendingTxPower = txPower
		
		guard let project = beacon.project, let uuid = UUID(uuidString: project.proximityUUID) else { return }
		let major = UInt16(clamping: beacon.majorID)
		let minor = UInt16(clamping: beacon.minorID)
		
		broadcaster.startBroadcasting(uuid: uuid, major: major, minor: minor, txPower: txPower)
	}
	
	func stopBroadcasting() {
		broadcaster.stopBroadcasting()
		activeBeacon = nil
		pendingTxPower = nil
	}
	
	func updateTxPower(to newPower: Int8) {
		guard let currentBeacon = activeBeacon else { return }
		stopBroadcasting()
		startBroadcasting(beacon: currentBeacon, txPower: newPower)
	}
	
	func broadcaster(_ broadcaster: BeaconBroadcaster, didUpdateState state: CBManagerState) {
		if state != .poweredOn && activeBeacon != nil {
			activeBeacon = nil
			pendingTxPower = nil
		}
	}
}
