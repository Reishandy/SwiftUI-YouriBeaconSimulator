//
//  BeaconDiscoveryService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
class BeaconDiscoveryService: BeaconDiscovererDelegate {
	var discoveredBeacons: [DiscoveredBeacon] = []
	
	private var discoverer: BeaconDiscoverer
	
	private var isScanning = false
	private var onNewBeaconFound: (() -> Void)?
	private var refreshTask: Task<Void, Never>?
	
	private var logger: LoggingService?
	
	init() {
#if os(macOS)
		self.discoverer = MacOSBeaconDiscoverer()
#else
		self.discoverer = IOSBeaconDiscoverer()
#endif
		self.discoverer.delegate = self
	}
	
	func setLogger(_ logger: LoggingService) {
		self.logger = logger
	}
	
	func startDiscovery(uuid: UUID, onNewBeaconFound: @escaping () -> Void) {
		guard !isScanning else { return }
		self.isScanning = true
		self.discoveredBeacons = []
		self.onNewBeaconFound = onNewBeaconFound
		
		Task { await logger?.log(message: "Started scanning for UUID:\n\(uuid.uuidString)", category: .discovery) }
		
		discoverer.startDiscovery(uuid: uuid)
		startRefreshTask()
	}
	
	func stopDiscovery() {
		self.isScanning = false
		self.onNewBeaconFound = nil
		self.refreshTask?.cancel()
		self.refreshTask = nil
		
		Task { await logger?.log(message: "Stopped scanning.", category: .discovery) }
		
		discoverer.stopDiscovery()
	}
	
	private func startRefreshTask() {
		refreshTask?.cancel()
		
		refreshTask = Task { [weak self] in
			while !Task.isCancelled {
				do { try await Task.sleep(for: .seconds(1)) } catch { break }
				guard let self = self else { return }
				
				let now = Date.now
				var hasChanges = false
				var updatedBeacons = self.discoveredBeacons
				
				// Mark stale beacons as inactive
				for i in 0..<updatedBeacons.count {
					if updatedBeacons[i].isCurrentlyActive &&
						now.timeIntervalSince(updatedBeacons[i].lastSeen) >= 1.0 {
						
						updatedBeacons[i].isCurrentlyActive = false
						hasChanges = true
						
						let major = updatedBeacons[i].major
						let minor = updatedBeacons[i].minor
						Task { await self.logger?.log(message: "Beacon (Major: \(major), Minor: \(minor))\nwent out of range (stale).", category: .discovery) }
					}
				}
				
				if hasChanges {
					self.sortDiscoveredBeacons(&updatedBeacons)
					self.discoveredBeacons = updatedBeacons
				}
			}
		}
	}
	
	private func sortDiscoveredBeacons(_ beacons: inout [DiscoveredBeacon]) {
		beacons.sort {
			if $0.isCurrentlyActive != $1.isCurrentlyActive {
				return $0.isCurrentlyActive && !$1.isCurrentlyActive
			}
			if $0.uuid != $1.uuid {
				return $0.uuid.uuidString < $1.uuid.uuidString
			}
			return $0.accuracy < $1.accuracy
		}
	}
	
	func discoverer(_ discoverer: BeaconDiscoverer, didDiscover incomingBeacon: DiscoveredBeacon) {
		var updatedBeacons = self.discoveredBeacons
		var hasNewBeacon = false
		
		if let index = updatedBeacons.firstIndex(where: { $0.id == incomingBeacon.id }) {
			if !updatedBeacons[index].isCurrentlyActive {
				Task { await logger?.log(message: "Beacon (Major: \(incomingBeacon.major), Minor: \(incomingBeacon.minor))\nis back in range.", category: .discovery) }
			}
			
			updatedBeacons[index] = incomingBeacon
		} else {
			updatedBeacons.append(incomingBeacon)
			hasNewBeacon = true
			
			let distance = incomingBeacon.accuracy < 0 ? "Unknown" : String(format: "%.2fm", incomingBeacon.accuracy)
			Task { await logger?.log(message: "Discovered new beacon!\nMajor: \(incomingBeacon.major)\nMinor: \(incomingBeacon.minor)\nDistance: \(distance)\nRSSI: \(incomingBeacon.rssi) dBm", category: .discovery) }
		}
		
		self.sortDiscoveredBeacons(&updatedBeacons)
		self.discoveredBeacons = updatedBeacons
		
		if hasNewBeacon {
			self.onNewBeaconFound?()
		}
	}
}
