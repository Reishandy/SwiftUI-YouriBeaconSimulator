//
//  BeaconDiscoverer.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

import Foundation

protocol BeaconDiscoverer {
	var delegate: BeaconDiscovererDelegate? { get set }
	func startDiscovery(uuid: UUID)
	func stopDiscovery()
}

@MainActor
protocol BeaconDiscovererDelegate: AnyObject {
	func discoverer(_ discoverer: BeaconDiscoverer, didDiscover incomingBeacon: DiscoveredBeacon)
}
