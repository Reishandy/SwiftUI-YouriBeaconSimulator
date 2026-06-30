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
	
	private var logger: LoggingService?
	
	init() {
#if os(macOS)
		self.broadcaster = MacOSBeaconBroadcaster()
#else
		self.broadcaster = IOSBeaconBroadcaster()
#endif
		self.broadcaster.delegate = self
	}
	
	func setLogger(_ logger: LoggingService) {
		self.logger = logger
	}
	
	func startBroadcasting(beacon: BroadcastBeacon, txPower: Int8, isChangePower: Bool = false) {
		guard let project = beacon.project, let uuid = UUID(uuidString: project.proximityUUID) else { return }
		
		self.activeBeacon = beacon
		self.pendingTxPower = txPower
		
		let major = UInt16(clamping: beacon.majorID)
		let minor = UInt16(clamping: beacon.minorID)
		
		if !isChangePower {
			Task { await logger?.log(message: "Started broadcasting\n'\(beacon.beaconName)' (Major: \(major), Minor: \(minor))\nat \(txPower) dBm.", category: .broadcast) }
		}
		
		broadcaster.startBroadcasting(uuid: uuid, major: major, minor: minor, txPower: txPower)
	}
	
	func stopBroadcasting(isChangePower: Bool = false) {
		if let beacon = activeBeacon {
			if !isChangePower {
				Task { await logger?.log(message: "Stopped broadcasting\n'\(beacon.beaconName)'", category: .broadcast) }
			}
		}
		
		activeBeacon = nil
		pendingTxPower = nil
		broadcaster.stopBroadcasting()
	}
	
	func updateTxPower(to newPower: Int8) {
		guard let currentBeacon = activeBeacon else { return }
		
		Task { await logger?.log(message: "Updated TX Power for\n'\(currentBeacon.beaconName)'\ninto \(newPower) dBm", category: .broadcast) }
		
		stopBroadcasting(isChangePower: true)
		startBroadcasting(beacon: currentBeacon, txPower: newPower, isChangePower: true)
	}
	
	func broadcaster(_ broadcaster: BeaconBroadcaster, didUpdateState state: CBManagerState) {
		if state != .poweredOn && activeBeacon != nil {
			Task { await logger?.log(message: "Bluetooth powered off. Broadcasting halted.", category: .system) }
			activeBeacon = nil
			pendingTxPower = nil
		}
	}
}
