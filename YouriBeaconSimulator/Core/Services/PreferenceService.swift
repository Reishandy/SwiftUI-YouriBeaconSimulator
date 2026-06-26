//
//  PreferenceService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import SwiftUI

@Observable
final class PreferenceService {
	private enum Keys {
		static let selectedUUID = "selectedUUID"
		static let isBackgroundNotificationEnabled = "isBackgroundNotificationEnabled"
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
	
	init() {
		if let uuidString = UserDefaults.standard.string(forKey: Keys.selectedUUID),
		   let savedUUID = UUID(uuidString: uuidString) {
			self.selectedUUID = savedUUID
		} else {
			self.selectedUUID = nil
		}
		
		self.isBackgroundNotificationEnabled = UserDefaults.standard.bool(forKey: Keys.isBackgroundNotificationEnabled)
	}
}
