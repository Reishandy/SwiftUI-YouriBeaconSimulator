//
//  BeaconBroadcastService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import CoreBluetooth
import CoreLocation
import Observation

@Observable
class BeaconBroadcastService {
	private let permissionService: PermissionService
	
	private(set) var activeBeacon: BroadcastBeacon?
	
	init(permissionService: PermissionService) {
		self.permissionService = permissionService
		
		setupBluetoothStateListener()
	}
	
	func startBroadcasting(beacon: BroadcastBeacon, txPower: Int8) {
		guard let manager = permissionService.peripheralManager,
			  manager.state == .poweredOn else { return }
		
		guard let project = beacon.project,
			  let uuid = UUID(uuidString: project.proximityUUID) else { return }
		
		let major = UInt16(clamping: beacon.majorID)
		let minor = UInt16(clamping: beacon.minorID)
		
		let beaconPeripheralData: [String: Any]
		
#if os(macOS)
		// Mnually build the 21-byte iBeacon payload for MacOS
		var advertisementBytes = [UInt8](repeating: 0, count: 21)
		
		// UUID bytes (16 bytes)
		let uuidBytes = withUnsafeBytes(of: uuid.uuid) { Array($0) }
		for i in 0..<16 {
			advertisementBytes[i] = uuidBytes[i]
		}
		
		// Major (2 bytes, Big Endian)
		advertisementBytes[16] = UInt8(major >> 8)
		advertisementBytes[17] = UInt8(major & 0x00FF)
		
		// Minor (2 bytes, Big Endian)
		advertisementBytes[18] = UInt8(minor >> 8)
		advertisementBytes[19] = UInt8(minor & 0x00FF)
		
		// Tx Power (1 byte)
		advertisementBytes[20] = UInt8(bitPattern: txPower)
		
		// Use Apple's undocumented CoreBluetooth key for iBeacons
		beaconPeripheralData = ["kCBAdvDataAppleBeaconKey": Data(advertisementBytes)]
		
#else
		let beaconRegion = CLBeaconRegion(
			uuid: uuid,
			major: major,
			minor: minor,
			identifier: beacon.beaconName
		)
		
		guard let data = beaconRegion.peripheralData(withMeasuredPower: NSNumber(value: txPower)) as? [String: Any] else { return }
		beaconPeripheralData = data
#endif
		
		self.activeBeacon = beacon
		manager.startAdvertising(beaconPeripheralData)
	}
	
	func stopBroadcasting() {
		permissionService.peripheralManager?.stopAdvertising()
		activeBeacon = nil
	}
	
	func updateTxPower(to newPower: Int8) {
		guard let currentBeacon = activeBeacon else { return }
		
		stopBroadcasting()
		startBroadcasting(beacon: currentBeacon, txPower: newPower)
	}
	
	private func setupBluetoothStateListener() {
		NotificationCenter.default.addObserver(
			forName: .bluetoothStateChanged,
			object: nil,
			queue: .main
		) { [weak self] notification in
			guard let self = self,
				  let state = notification.object as? CBManagerState else { return }
			
			if state == .poweredOff || state == .unauthorized || state == .unsupported {
				if self.activeBeacon != nil {
					self.stopBroadcasting()
				}
			}
		}
	}
}
