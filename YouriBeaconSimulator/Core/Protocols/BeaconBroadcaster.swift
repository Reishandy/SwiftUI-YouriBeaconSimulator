//
//  BeaconBroadcaster.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

import Foundation
import CoreBluetooth

protocol BeaconBroadcaster {
	var delegate: BeaconBroadcasterDelegate? { get set }
	func prepareHardware()
	func startBroadcasting(uuid: UUID, major: UInt16, minor: UInt16, txPower: Int8)
	func stopBroadcasting()
}

@MainActor
protocol BeaconBroadcasterDelegate: AnyObject {
	func broadcaster(_ broadcaster: BeaconBroadcaster, didUpdateState state: CBManagerState)
}
