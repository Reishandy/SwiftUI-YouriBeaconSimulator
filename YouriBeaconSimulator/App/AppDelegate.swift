//
//  AppDelegate.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 27/06/26.
//

import SwiftUI
#if os(iOS)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		BackgroundMonitorService.shared.bootstrap()
		
		return true
	}
}
#endif
