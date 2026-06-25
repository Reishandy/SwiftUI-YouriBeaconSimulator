//
//  BroadcastViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
import SwiftData
import CoreBluetooth

@Observable
class BroadcastViewModel {
	private var modelContext: ModelContext
	private var permissionService: PermissionService
	
	private(set) var projects: [BroadcastProject] = []
	
	var bluetoothAuthorization: CBManagerAuthorization {
		permissionService.bluetoothAuthorization
	}
	var bluetoothState: CBManagerState {
		permissionService.bluetoothState
	}
	
	var currentBroadcastingBeacon: BroadcastBeacon?
	var selectedBeacon: BroadcastBeacon?
	
	var searchTerm: String = ""
	var filteredProjectGroups: [BroadcastProjectGroup] {
		if searchTerm.isEmpty {
			return projects.map { BroadcastProjectGroup(project: $0, beacons: $0.sortedBeacons) }
		}
		
		let term = searchTerm.lowercased()
		
		return projects.compactMap { project in
			let projectMatches = project.name.lowercased().contains(term)
			let matchingBeacons = project.sortedBeacons.filter { $0.beaconName.lowercased().contains(term) }
			
			if projectMatches {
				return BroadcastProjectGroup(project: project, beacons: project.sortedBeacons)
			} else if !matchingBeacons.isEmpty {
				return BroadcastProjectGroup(project: project, beacons: matchingBeacons)
			} else {
				return nil
			}
		}
	}
	
	var isAddSheetPresented: Bool = false
	var isEditSheetPresented: Bool = false
	var isDeleteConfirmmationPresented: Bool = false
	
	var addSelectedProject: BroadcastProject? = nil
	var addProjectName: String = ""
	var addProximityUUID: String = ""
	var addBeaconName: String = ""
	var addMajorID: Int? = nil
	var addMinorID: Int? = nil
	
	init(modelContext: ModelContext, permissionService: PermissionService) {
		self.modelContext = modelContext
		self.permissionService = permissionService
	}
	
	func fetchData() {
		do {
			projects = try modelContext.fetch(FetchDescriptor<BroadcastProject>(
				sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
			))
		} catch {
			print("ERROR > Failed populating BroadcastViewModel: \(error)")
		}
	}
	
	func requestBluetoothPermission() {
		Task {
			await permissionService.requestBluetoothPermission()
		}
	}
	
	func addBeacon() {
		guard let major = addMajorID, let minor = addMinorID else { return }
		
		let newBeacon = BroadcastBeacon(beaconName: addBeaconName, majorID: major, minorID: minor)
		
		if let selected = addSelectedProject {
			selected.name = addProjectName
			selected.proximityUUID = addProximityUUID
			newBeacon.project = selected
		} else {
			let newProject = BroadcastProject(name: addProjectName, proximityUUID: addProximityUUID)
			modelContext.insert(newProject)
			newBeacon.project = newProject
		}
		
		modelContext.insert(newBeacon)
		try? modelContext.save()
		
		fetchData()
		clearAddBeacon()
	}
	
	func clearAddBeacon() {
		addSelectedProject = nil
		addProjectName = ""
		addProximityUUID = ""
		addBeaconName = ""
		addMajorID = nil
		addMinorID = nil
	}
	
	func updateBeacon(
		_ beacon: BroadcastBeacon,
		selectedProject: BroadcastProject?,
		projectName: String,
		proximityUUID: String,
		beaconName: String,
		majorID: Int,
		minorID: Int
	) {
		let oldProject = beacon.project
		let wasLastBeaconInOldProject = (oldProject?.beacons?.count ?? 0) <= 1
		
		beacon.beaconName = beaconName
		beacon.majorID = majorID
		beacon.minorID = minorID
		
		let targetProject: BroadcastProject
		if let selected = selectedProject {
			selected.name = projectName
			selected.proximityUUID = proximityUUID
			targetProject = selected
		} else {
			let newProject = BroadcastProject(name: projectName, proximityUUID: proximityUUID)
			modelContext.insert(newProject)
			targetProject = newProject
		}
		
		if oldProject != targetProject {
			beacon.project = targetProject
			
			if let old = oldProject, wasLastBeaconInOldProject {
				modelContext.delete(old)
			}
		}
		
		try? modelContext.save()
		fetchData()
	}
	
	func deleteBeacon() {
		if let beaconToDelete = selectedBeacon {
			let parentProject = beaconToDelete.project
			let isLastBeacon = (parentProject?.beacons?.count ?? 0) <= 1
			
			modelContext.delete(beaconToDelete)
			
			if currentBroadcastingBeacon == beaconToDelete {
				currentBroadcastingBeacon = nil
			}
			
			if let project = parentProject, isLastBeacon {
				modelContext.delete(project)
			}
			
			try? modelContext.save()
			fetchData()
			selectedBeacon = nil
		}
	}
	
	func broadcast(_ beacon: BroadcastBeacon) {
		// TODO: Proper broadcasting mechanism
		if currentBroadcastingBeacon == beacon {
			currentBroadcastingBeacon = nil
		} else {
			currentBroadcastingBeacon = beacon
		}
		
		selectedBeacon = nil
	}
}
