//
//  IOSBeaconDiscoverer.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

#if os(iOS)
import Foundation
import CoreLocation

final class IOSBeaconDiscoverer: NSObject, BeaconDiscoverer, CLLocationManagerDelegate {
	weak var delegate: BeaconDiscovererDelegate?
	
	private var locationManager: CLLocationManager?
	private var targetConstraint: CLBeaconIdentityConstraint?
	
	override init() {
		super.init()
	}
	
	private func prepareHardware() {
		if locationManager == nil {
			locationManager = CLLocationManager()
			locationManager?.delegate = self
		}
	}
	
	func startDiscovery(uuid: UUID) {
		prepareHardware()
		let constraint = CLBeaconIdentityConstraint(uuid: uuid)
		self.targetConstraint = constraint
		locationManager?.startRangingBeacons(satisfying: constraint)
	}
	
	func stopDiscovery() {
		if let constraint = targetConstraint {
			locationManager?.stopRangingBeacons(satisfying: constraint)
			self.targetConstraint = nil
		}
	}
	
	nonisolated func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		let now = Date.now
		
		Task { @MainActor in
			for beacon in beacons {
				let proximity: BeaconProximity
				switch beacon.proximity {
				case .immediate: proximity = .immediate
				case .near: proximity = .near
				case .far: proximity = .far
				default: proximity = .unknown
				}
				
				let discoveredBeacon = DiscoveredBeacon(
					uuid: beacon.uuid,
					major: beacon.major.uint16Value,
					minor: beacon.minor.uint16Value,
					rssi: beacon.rssi,
					accuracy: beacon.accuracy,
					proximity: proximity,
					lastSeen: now,
					isCurrentlyActive: true
				)
				
				delegate?.discoverer(self, didDiscover: discoveredBeacon)
			}
		}
	}
}
#endif
