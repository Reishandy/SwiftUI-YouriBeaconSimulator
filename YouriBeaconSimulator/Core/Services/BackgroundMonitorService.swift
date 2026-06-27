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
#if os(iOS)
	private var monitor: CLMonitor?
	
	private var backgroundLocationManager: CLLocationManager = CLLocationManager()
	private var discoveredBackgroundBeacons: [CLBeacon] = []
	
	private var isRanging = false
	private var rangingContinuation: CheckedContinuation<[CLBeacon], Never>?
#endif
	
	override init() {
		super.init()
		
#if os(iOS)
		backgroundLocationManager.delegate = self
		backgroundLocationManager.allowsBackgroundLocationUpdates = true
		
		Task {
			await setupMonitorAndListen()
		}
#endif
	}
	
#if os(iOS)
	private func setupMonitorAndListen() async {
		if monitor != nil { return }
		
		let authStatus = CLLocationManager().authorizationStatus
		guard authStatus != .notDetermined else {
			return
		}
		
		monitor = await CLMonitor("BeaconBackgroundMonitor")
		guard let activeMonitor = monitor else { return }
		
		Task {
			do {
				for try await event in await activeMonitor.events {
					await handleEvent(event)
				}
			} catch {
				print("Background monitor stream error: \(error)")
			}
		}
	}
	
	private func handleEvent(_ event: CLMonitor.Event) async {
		guard let uuid = UUID(uuidString: event.identifier) else { return }
		
		switch event.state {
		case .satisfied:
			let beacons = await performBackgroundRangingBurst(for: uuid)
			
			if beacons.isEmpty {
				NotificationUtilities.send(
					title: "Beacon Region Entered",
					body: "You entered the region for \(uuid.uuidString), but couldn't range specific beacons in time."
				)
			} else {
				var bodyText = "Found \(beacons.count) beacons nearby:\n"
				for beacon in beacons {
					let distance = beacon.accuracy < 0 ? "Unknown" : String(format: "%.2fm", beacon.accuracy)
					bodyText += "• Major: \(beacon.major) Minor: \(beacon.minor) | \(distance) | \(beacon.rssi) dBm\n"
				}
				
				NotificationUtilities.send(
					title: "Beacons Detected!",
					body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
				)
			}
			
		case .unsatisfied:
			NotificationUtilities.send(
				title: "Beacon Lost",
				body: "You left the range of \(uuid.uuidString)"
			)
			
		default:
			break
		}
	}
	
	private func performBackgroundRangingBurst(for uuid: UUID) async -> [CLBeacon] {
		guard !isRanging else { return [] }
		isRanging = true
		discoveredBackgroundBeacons = []
		
		return await withCheckedContinuation { continuation in
			self.rangingContinuation = continuation
			
			DispatchQueue.main.async {
				let constraint = CLBeaconIdentityConstraint(uuid: uuid)
				self.backgroundLocationManager.startRangingBeacons(satisfying: constraint)
				
				// 3-second burst
				DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
					self.backgroundLocationManager.stopRangingBeacons(satisfying: constraint)
					
					let beaconsToReturn = self.discoveredBackgroundBeacons
					self.isRanging = false
					
					if let cont = self.rangingContinuation {
						self.rangingContinuation = nil
						cont.resume(returning: beaconsToReturn)
					}
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		var uniqueBeacons: [CLBeacon] = []
		var seenIds: Set<String> = []
		
		for beacon in beacons {
			let id = "\(beacon.major)-\(beacon.minor)"
			if !seenIds.contains(id) {
				seenIds.insert(id)
				uniqueBeacons.append(beacon)
			}
		}
		
		if !uniqueBeacons.isEmpty {
			self.discoveredBackgroundBeacons = uniqueBeacons
		}
	}
	
	func updateMonitoring(for uuid: UUID, isEnabled: Bool) {
		Task {
			await setupMonitorAndListen()
			
			guard let monitor = monitor else { return }
			let identifier = uuid.uuidString
			
			if isEnabled {
				let currentIdentifiers = await monitor.identifiers
				for existingID in currentIdentifiers {
					await monitor.remove(existingID)
				}
				
				let condition = CLMonitor.BeaconIdentityCondition(uuid: uuid)
				await monitor.add(condition, identifier: identifier, assuming: .unknown)
			} else {
				await monitor.remove(identifier)
			}
		}
	}
#endif
}
