//
//  DeviceIdentifierService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 30/06/26.
//

import Foundation
import Security

struct DeviceIdentifierService {
	private let account = "LocalDeviceUUID"
	
	func getDeviceUUID() -> String {
		let service = Bundle.main.bundleIdentifier ?? "id.reishandy.YouriBeaconSimulator"
		
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecReturnData as String: true
		]
		
		var item: CFTypeRef?
		if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
		   let data = item as? Data,
		   let uuid = String(data: data, encoding: .utf8) {
			return uuid
		}
		
		let newUUID = UUID().uuidString
		let data = Data(newUUID.utf8)
		
		let addQuery: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecValueData as String: data,
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		]
		
		SecItemAdd(addQuery as CFDictionary, nil)
		
		return newUUID
	}
}
