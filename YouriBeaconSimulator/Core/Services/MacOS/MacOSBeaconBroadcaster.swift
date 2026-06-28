//
//  MacOSBeaconBroadcaster.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

#if os(macOS)
import Foundation
import CoreBluetooth

final class MacOSBeaconBroadcaster: NSObject, BeaconBroadcaster, CBPeripheralManagerDelegate {
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
		
		var advertisementBytes = [UInt8](repeating: 0, count: 21)
		let uuidBytes = withUnsafeBytes(of: uuid.uuid) { Array($0) }
		for i in 0..<16 { advertisementBytes[i] = uuidBytes[i] }
		
		advertisementBytes[16] = UInt8(major >> 8)
		advertisementBytes[17] = UInt8(major & 0x00FF)
		advertisementBytes[18] = UInt8(minor >> 8)
		advertisementBytes[19] = UInt8(minor & 0x00FF)
		advertisementBytes[20] = UInt8(bitPattern: txPower)
		
		let data: [String: Any] = ["kCBAdvDataAppleBeaconKey": Data(advertisementBytes)]
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
