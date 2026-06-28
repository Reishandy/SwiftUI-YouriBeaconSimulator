//
//  MacOSBeaconDiscoverer.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

#if os(macOS)
import Foundation
import CoreBluetooth

final class MacOSBeaconDiscoverer: NSObject, BeaconDiscoverer, CBCentralManagerDelegate {
	weak var delegate: BeaconDiscovererDelegate?
	
	private var centralManager: CBCentralManager?
	private var targetUUID: UUID?
	private var isScanning = false
	
	private var previousRSSIs: [String: Int] = [:]
	
	override init() {
		super.init()
	}
	
	private func prepareHardware() {
		if centralManager == nil {
			centralManager = CBCentralManager(delegate: self, queue: .main)
		}
	}
	
	func startDiscovery(uuid: UUID) {
		targetUUID = uuid
		isScanning = true
		prepareHardware()
		
		if centralManager?.state == .poweredOn {
			startScanningForBeacons()
		}
	}
	
	func stopDiscovery() {
		isScanning = false
		centralManager?.stopScan()
		previousRSSIs.removeAll()
	}
	
	private func startScanningForBeacons() {
		centralManager?.scanForPeripherals(
			withServices: nil,
			options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
		)
	}
	
	nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
		Task { @MainActor in
			if central.state == .poweredOn && self.isScanning {
				self.startScanningForBeacons()
			}
		}
	}
	
	nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
			  manufacturerData.count >= 25 else { return }
		
		let iBeaconPrefix = Data([0x4C, 0x00, 0x02, 0x15])
		guard manufacturerData.starts(with: iBeaconPrefix) else { return }
		
		var uuidBytes = [UInt8](repeating: 0, count: 16)
		manufacturerData.copyBytes(to: &uuidBytes, from: 4..<20)
		let beaconUUID = NSUUID(uuidBytes: uuidBytes) as UUID
		
		let major = UInt16(manufacturerData[20]) << 8 | UInt16(manufacturerData[21])
		let minor = UInt16(manufacturerData[22]) << 8 | UInt16(manufacturerData[23])
		let txPower = Int8(bitPattern: manufacturerData[24])
		
		Task { @MainActor in
			let beaconID = "\(beaconUUID.uuidString)-\(major)-\(minor)"
			var finalRSSI = RSSI.intValue
			
			// Low-Pass Filter for smoothing
			if let previousRSSI = self.previousRSSIs[beaconID] {
				let alpha = 0.1
				let smoothed = (Double(RSSI.intValue) * alpha) + (Double(previousRSSI) * (1.0 - alpha))
				finalRSSI = Int(round(smoothed))
			}
			self.previousRSSIs[beaconID] = finalRSSI
			
			let newBeacon = DiscoveredBeacon(uuid: beaconUUID, major: major, minor: minor, rssi: finalRSSI, txPower: txPower)
			self.delegate?.discoverer(self, didDiscover: newBeacon)
		}
	}
}
#endif
