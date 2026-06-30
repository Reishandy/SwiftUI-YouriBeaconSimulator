//
//  YouriBeaconSimulatorApp.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData

@main
struct YouriBeaconSimulatorApp: App {
	@Environment(\.scenePhase) private var scenePhase
	
#if os(iOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
	
	let container: ModelContainer
	let loggingService: LoggingService
	
	@State var preferenceService = PreferenceService()
	@State var locationPermissionManager = LocationPermissionManager()
	@State var bluetoothPermissionManager = BluetoothPermissionManager()
	@State var notificationPermissionManager = NotificationPermissionManager()
	@State var deviceIdentifierService = DeviceIdentifierService()
	
	@State var beaconBroadcastService = BeaconBroadcastService()
	@State var beaconDiscoveryService = BeaconDiscoveryService()
	
	var deviceDescription: String {
#if os(iOS)
		return "\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
#elseif os(macOS)
		let version = ProcessInfo.processInfo.operatingSystemVersion
		return "\(Host.current().localizedName ?? "Mac") (macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion))"
#else
		return "Unknown Device"
#endif
	}
	
	init() {
		do {
			let schema = Schema([
				BroadcastProject.self,
				BroadcastBeacon.self,
				LogSession.self,
				LogEvent.self
			])
			
			container = try ModelContainer(for: schema)
			
			loggingService = LoggingService(modelContainer: container)
		} catch {
			fatalError("Failed to initialize SwiftData container: \(error)")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				preferenceService: preferenceService,
				locationPermissionManager: locationPermissionManager,
				bluetoothPermissionManager: bluetoothPermissionManager,
				notificationPermissionManager: notificationPermissionManager,
				beaconBroadcastService: beaconBroadcastService,
				beaconDiscoveryService: beaconDiscoveryService,
				backgroundMonitorService: BackgroundMonitorService.shared
			)
			.modelContainer(container)
#if os(macOS)
			.frame(minWidth: 700)
			.frame(maxWidth: 1000)
#endif
		}
#if os(macOS)
		.windowResizability(.contentSize)
#endif
		.onChange(of: scenePhase) { oldPhase, newPhase in
			switch newPhase {
			case .active:
				// App launched or came back to the foreground
				beaconBroadcastService.setLogger(loggingService)
				beaconDiscoveryService.setLogger(loggingService)
				BackgroundMonitorService.shared.setLogger(loggingService)
				
				Task {
					await loggingService.startNewSession(
						deviceDescription: deviceDescription,
						deviceIdentifier: deviceIdentifierService.getDeviceUUID()
					)
				}
				
			case .background:
				// App was hidden, swiped to home, or is about to be terminated
				beaconBroadcastService.stopBroadcasting()
				
				Task {
					await loggingService.endCurrentSession()
				}
				
			case .inactive:
				// App is transitioning (e.g., pulling down Control Center)
				break
				
			@unknown default:
				break
			}
		}
	}
}
