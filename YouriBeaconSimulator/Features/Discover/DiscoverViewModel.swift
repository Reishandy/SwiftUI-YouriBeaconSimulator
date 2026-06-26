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

@Observable
class DiscoverViewModel {
	private var modelContext: ModelContext
	private var preferenceService: PreferenceService
	private var permissionService: PermissionService
	
	private(set) var projects: [BroadcastProject] = []
	
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
	
	var hasDeniedBackgroundPermissions: Bool {
		permissionService.locationAuthorization == .denied ||
		permissionService.locationAuthorization == .restricted ||
		permissionService.notificationAuthorization == .denied
	}
	
	init(modelContext: ModelContext, preferenceService: PreferenceService, permissionService: PermissionService) {
		self.modelContext = modelContext
		self.preferenceService = preferenceService
		self.permissionService = permissionService
		
		if let savedUUID = preferenceService.selectedUUID {
			self.proximityUUID = savedUUID.uuidString
			self.startDiscovery()
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
			
			// TODO: Trigger actual core location discovery
		}
	}
	
	func stopDiscovery() {
		isDiscovering = false
		
		// TODO: Stop actual core location discovery
	}
}
