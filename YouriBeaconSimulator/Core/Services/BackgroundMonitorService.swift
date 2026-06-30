//
//  BackgroundMonitorService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 27/06/26.
//

import Foundation
import CoreLocation
import Observation

@Observable
class BackgroundMonitorService: NSObject, CLLocationManagerDelegate {
	static let shared = BackgroundMonitorService()
	private var logger: LoggingService?
	
#if os(iOS)
	private let locationManager = CLLocationManager()
	private var isRanging = false
#endif
	
	private override init() {
		super.init()
#if os(iOS)
		locationManager.delegate = self
		locationManager.allowsBackgroundLocationUpdates = true
#endif
	}
	
	func setLogger(_ logger: LoggingService) {
		self.logger = logger
	}
	
	func bootstrap() {
#if os(iOS)
		_ = locationManager
#endif
	}
	
#if os(iOS)
	func updateMonitoring(for uuid: UUID, isEnabled: Bool) {
		let identifier = uuid.uuidString
		
		for region in locationManager.monitoredRegions {
			locationManager.stopMonitoring(for: region)
		}
		
		if isEnabled {
			let region = CLBeaconRegion(uuid: uuid, identifier: identifier)
			region.notifyOnEntry = true
			region.notifyOnExit = true
			region.notifyEntryStateOnDisplay = true
			
			locationManager.startMonitoring(for: region)
			
			Task { await logger?.log(message: "Enabled background notifications for UUID:\n\(uuid)", category: .background) }
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		
		Task { await logger?.log(message: "Entered background region for UUID: \(beaconRegion.uuid.uuidString)", category: .background) }
		
		NotificationUtilities.send(
			title: "Beacon Region Entered",
			body: "You entered the region for \(beaconRegion.uuid.uuidString)."
		)
		
		let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid)
		manager.startRangingBeacons(satisfying: constraint)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			manager.stopRangingBeacons(satisfying: constraint)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		
		Task { await logger?.log(message: "Exited background region for UUID: \(beaconRegion.uuid.uuidString)", category: .background) }
		
		NotificationUtilities.send(
			title: "Beacon Lost",
			body: "You left the range of \(beaconRegion.uuid.uuidString)"
		)
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		guard !beacons.isEmpty else { return }
		
		guard !isRanging else { return }
		isRanging = true
		
		var uniqueBeacons: [CLBeacon] = []
		var seenIds: Set<String> = []
		
		for beacon in beacons {
			let id = "\(beacon.major)-\(beacon.minor)"
			if !seenIds.contains(id) {
				seenIds.insert(id)
				uniqueBeacons.append(beacon)
				
				let distance = beacon.accuracy < 0 ? "Unknown" : String(format: "%.2fm", beacon.accuracy)
				Task {
					await logger?.log(
						message: "Background Ranged!\nMajor: \(beacon.major)\nMinor: \(beacon.minor)\nDistance: \(distance)\nRSSI: \(beacon.rssi) dBm",
						category: .background
					)
				}
			}
		}
		
		var bodyText = "Found \(uniqueBeacons.count) beacons nearby:\n"
		for beacon in uniqueBeacons {
			let distance = beacon.accuracy < 0 ? "Unknown" : String(format: "%.2fm", beacon.accuracy)
			bodyText += "• Major: \(beacon.major) Minor: \(beacon.minor) | \(distance) | \(beacon.rssi) dBm\n"
		}
		
		NotificationUtilities.send(
			title: "Beacons Detected!",
			body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
		)
		
		manager.stopRangingBeacons(satisfying: beaconConstraint)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
			self.isRanging = false
		}
	}
#endif
}
