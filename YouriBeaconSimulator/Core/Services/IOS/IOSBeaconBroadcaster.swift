//
//  IOSBeaconBroadcaster.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

#if os(iOS)
import Foundation
import CoreBluetooth
import CoreLocation

final class IOSBeaconBroadcaster: NSObject, BeaconBroadcaster, CBPeripheralManagerDelegate {
	weak var delegate: BeaconBroadcasterDelegate?
	private var peripheralManager: CBPeripheralManager?
	
	private var pendingBroadcastData: [String: Any]?
	
	func prepareHardware() {
		if peripheralManager == nil {
			peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
		}
	}
	
	func startBroadcasting(uuid: UUID, major: UInt16, minor: UInt16, txPower: Int8) {
		prepareHardware()
		
		let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
		guard let data = beaconRegion.peripheralData(withMeasuredPower: NSNumber(value: txPower)) as? [String: Any] else { return }
		
		self.pendingBroadcastData = data
		
		if peripheralManager?.state == .poweredOn {
			peripheralManager?.startAdvertising(data)
		}
	}
	
	func stopBroadcasting() {
		peripheralManager?.stopAdvertising()
		pendingBroadcastData = nil
	}
	
	nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		Task { @MainActor in
			delegate?.broadcaster(self, didUpdateState: peripheral.state)
			
			if peripheral.state == .poweredOn, let data = pendingBroadcastData {
				peripheral.startAdvertising(data)
			} else {
				peripheral.stopAdvertising()
			}
		}
	}
}
#endif
