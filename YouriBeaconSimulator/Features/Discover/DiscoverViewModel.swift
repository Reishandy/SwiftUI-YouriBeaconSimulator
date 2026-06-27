//
//  DiscoverViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import Foundation
import SwiftData
import CoreBluetooth
import CoreLocation
import UserNotifications
#if os(iOS)
import UIKit
#endif

@Observable
class DiscoverViewModel {
	private var modelContext: ModelContext
	private var preferenceService: PreferenceService
	private var permissionService: PermissionService
	private var discoveryService: BeaconDiscoveryService
	
	private var previewBeacons: [DiscoveredBeacon]?
	
	private(set) var projects: [BroadcastProject] = []
	var discoveredBeacons: [DiscoveredBeacon] {
		previewBeacons ?? discoveryService.discoveredBeacons
	}
	var targetBeacons: [DiscoveredBeacon] {
		let target = UUID(uuidString: proximityUUID)
		return discoveredBeacons.filter { $0.uuid == target }
	}
	var otherBeacons: [DiscoveredBeacon] {
		let target = UUID(uuidString: proximityUUID)
		return discoveredBeacons.filter { $0.uuid != target }
	}
	
	var bluetoothAuthorization: CBManagerAuthorization {
		permissionService.bluetoothAuthorization
	}
	var bluetoothState: CBManagerState {
		permissionService.bluetoothState
	}
	var locationAuthorization: CLAuthorizationStatus {
		permissionService.locationAuthorization
	}
	
	var isDiscovering: Bool = false
	var selectedBeaconID: String? = nil
	
	var selectedBeacon: DiscoveredBeacon? {
		discoveredBeacons.first(where: { $0.id == selectedBeaconID })
	}
	
	var selectedProject: BroadcastProject? = nil
	var proximityUUID: String = ""
	
	var isBackgroundEnabled: Bool {
		get { preferenceService.isBackgroundNotificationEnabled }
		set { preferenceService.isBackgroundNotificationEnabled = newValue }
	}
	
	var isBackgroundReady: Bool {
		permissionService.locationAuthorization == .authorizedAlways &&
		(permissionService.notificationAuthorization == .authorized || permissionService.notificationAuthorization == .provisional)
	}
	
#if os(iOS)
	var hasDeniedBackgroundPermissions: Bool {
		permissionService.locationAuthorization == .denied ||
		permissionService.locationAuthorization == .restricted ||
		permissionService.locationAuthorization == .authorizedWhenInUse ||
		permissionService.notificationAuthorization == .denied
	}
#endif
	
	init(
		modelContext: ModelContext,
		preferenceService: PreferenceService,
		permissionService: PermissionService,
		discoveryService: BeaconDiscoveryService,
		previewBeacons: [DiscoveredBeacon]? = nil
	) {
		self.modelContext = modelContext
		self.preferenceService = preferenceService
		self.permissionService = permissionService
		self.discoveryService = discoveryService
		self.previewBeacons = previewBeacons
		
		if let savedUUID = preferenceService.selectedUUID {
			self.proximityUUID = savedUUID.uuidString
		}
		
		self.fetchData()
	}
	
	func fetchData() {
		do {
			projects = try modelContext.fetch(FetchDescriptor<BroadcastProject>(
				sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
			))
			
			if !proximityUUID.isEmpty {
				selectedProject = projects.first(where: { $0.proximityUUID.caseInsensitiveCompare(proximityUUID) == .orderedSame })
			}
		} catch {
			print("ERROR > Failed populating DiscoverViewModel: \(error)")
		}
	}
	
	func requestLocationPermission() {
		Task {
			await permissionService.requestLocationPermission()
		}
	}
	
	func requestBluetoothPermission() {
		Task {
			await permissionService.requestBluetoothPermission()
		}
	}
	
#if os(iOS)
	func requestBackgroundPermissions() {
		Task {
			if permissionService.notificationAuthorization == .notDetermined {
				await permissionService.requestNotificationPermission()
			}
			
			if permissionService.locationAuthorization == .authorizedWhenInUse {
				permissionService.requestAlwaysLocationPermission()
			}
		}
	}
#endif
	
	func startDiscovery() {
		if let uuid = UUID(uuidString: proximityUUID) {
			preferenceService.selectedUUID = uuid
			isDiscovering = true
			
			// For Preview Only
			if let previewBeacons {
				self.discoveryService.discoveredBeacons = previewBeacons.map { mockBeacon in
					DiscoveredBeacon(
						uuid: uuid,
						major: mockBeacon.major,
						minor: mockBeacon.minor,
						rssi: mockBeacon.rssi,
						accuracy: mockBeacon.accuracy,
						proximity: mockBeacon.proximity,
						lastSeen: mockBeacon.lastSeen
					)
				}
				return
			}
			
			discoveryService.startDiscovery(uuid: uuid) {
#if os(iOS)
				// Trigger light haptic on new discovery on iOS
				Task { @MainActor in
					let generator = UIImpactFeedbackGenerator(style: .light)
					generator.prepare()
					generator.impactOccurred()
				}
#endif
			}
		}
	}
	
	func stopDiscovery() {
		isDiscovering = false
		discoveryService.stopDiscovery()
	}
}
