//
//  PreferenceService.swift
//  YouriBeaconSimulator
//

import SwiftUI

@Observable
final class PreferenceService {
	private enum Keys {
		static let selectedUUID = "selectedUUID"
		static let isBackgroundNotificationEnabled = "isBackgroundNotificationEnabled"
		static let hasRequestedAlwaysLocation = "hasRequestedAlwaysLocation"
	}
	
	var selectedUUID: UUID? {
		didSet {
			if let selectedUUID {
				UserDefaults.standard.set(selectedUUID.uuidString, forKey: Keys.selectedUUID)
			} else {
				UserDefaults.standard.removeObject(forKey: Keys.selectedUUID)
			}
		}
	}
	
	var isBackgroundNotificationEnabled: Bool {
		didSet {
			UserDefaults.standard.set(isBackgroundNotificationEnabled, forKey: Keys.isBackgroundNotificationEnabled)
		}
	}
	
	var hasRequestedAlwaysLocation: Bool {
		didSet {
			UserDefaults.standard.set(hasRequestedAlwaysLocation, forKey: Keys.hasRequestedAlwaysLocation)
		}
	}
	
	init() {
		if let uuidString = UserDefaults.standard.string(forKey: Keys.selectedUUID),
		   let savedUUID = UUID(uuidString: uuidString) {
			self.selectedUUID = savedUUID
		} else {
			self.selectedUUID = nil
		}
		
		self.isBackgroundNotificationEnabled = UserDefaults.standard.bool(forKey: Keys.isBackgroundNotificationEnabled)
		self.hasRequestedAlwaysLocation = UserDefaults.standard.bool(forKey: Keys.hasRequestedAlwaysLocation)
	}
}
