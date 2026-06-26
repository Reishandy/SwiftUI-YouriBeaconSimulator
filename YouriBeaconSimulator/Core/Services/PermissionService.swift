//
//  PermissionService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
import CoreLocation
import CoreBluetooth
import UserNotifications
import Observation

@Observable
@MainActor
public class PermissionService: NSObject {
	public private(set) var bluetoothAuthorization: CBManagerAuthorization = .notDetermined
	public private(set) var bluetoothState: CBManagerState = .unknown
	public private(set) var locationAuthorization: CLAuthorizationStatus = .notDetermined
	public private(set) var notificationAuthorization: UNAuthorizationStatus = .notDetermined
	
	var locationManager: CLLocationManager?
	var peripheralManager: CBPeripheralManager?
	
	private var bluetoothContinuation: CheckedContinuation<CBManagerAuthorization, Never>?
	private var locationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
	
	public override init() {
		super.init()
		self.bluetoothAuthorization = CBPeripheralManager.authorization
		self.locationAuthorization = CLLocationManager().authorizationStatus
		
		if self.bluetoothAuthorization != .notDetermined {
			self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
				CBPeripheralManagerOptionShowPowerAlertKey: false
			])
		}
		
		Task {
			await checkNotificationPermission()
		}
	}
	
	public func requestBluetoothPermission() async -> CBManagerAuthorization {
		let current = CBPeripheralManager.authorization
		guard current == .notDetermined else {
			self.bluetoothAuthorization = current
			return current
		}
		
		if self.bluetoothState == .unsupported || self.bluetoothState == .unauthorized {
			return .restricted
		}
		
		return await withCheckedContinuation { continuation in
			self.bluetoothContinuation = continuation
			self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
				CBPeripheralManagerOptionShowPowerAlertKey: true
			])
		}
	}
	
	public func requestLocationPermission() async -> CLAuthorizationStatus {
		let manager = CLLocationManager()
		let current = manager.authorizationStatus
		
		guard current == .notDetermined else {
			self.locationAuthorization = current
			return current
		}
		
		self.locationManager = manager
		manager.delegate = self
		
		return await withCheckedContinuation { continuation in
			self.locationContinuation = continuation
			manager.requestWhenInUseAuthorization()
		}
	}
	
	public func requestAlwaysLocationPermission() {
		let manager = CLLocationManager()
		self.locationManager = manager
		manager.delegate = self
		manager.requestAlwaysAuthorization()
	}
	
	public func checkNotificationPermission() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		self.notificationAuthorization = settings.authorizationStatus
	}
	
	public func requestNotificationPermission() async {
		do {
			_ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
			await checkNotificationPermission()
		} catch {
			print("Failed to request notification permission: \(error)")
		}
	}
}

extension PermissionService: CBPeripheralManagerDelegate {
	public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		self.bluetoothState = peripheral.state
		self.bluetoothAuthorization = CBPeripheralManager.authorization
		
		NotificationCenter.default.post(name: .bluetoothStateChanged, object: peripheral.state)
		
		if CBPeripheralManager.authorization != .notDetermined {
			bluetoothContinuation?.resume(returning: CBPeripheralManager.authorization)
			bluetoothContinuation = nil
		}
	}
}

extension PermissionService: CLLocationManagerDelegate {
	public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.locationAuthorization = manager.authorizationStatus

		if manager.authorizationStatus != .notDetermined {
			locationContinuation?.resume(returning: manager.authorizationStatus)
			locationContinuation = nil
		}
	}
}
