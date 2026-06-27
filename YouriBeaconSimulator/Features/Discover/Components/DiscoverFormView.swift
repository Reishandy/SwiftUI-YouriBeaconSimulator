//
//  DiscoverFormView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import SwiftUI
import SwiftData

struct DiscoverFormView: View {
	@Binding var selectedProject: BroadcastProject?
	@Binding var proximityUUID: String
	
#if os(iOS)
	@Binding var isBackgroundEnabled: Bool
	let isBackgroundReady: Bool
	let hasDeniedPermissions: Bool
	let onGrantPermissionClick: () -> Void
#endif
	
	var availableProjects: [BroadcastProject]
	let onStartDiscoveryClick: () -> Void
	
	private var isUUIDValid: Bool {
		UUID(uuidString: proximityUUID) != nil
	}
	
	var body: some View {
		VStack {
			Form {
				Section {
					Picker("Project", selection: $selectedProject) {
						Text("No Project").tag(BroadcastProject?(nil))
						
						ForEach(availableProjects) { project in
							Text(project.name).tag(BroadcastProject?(project))
						}
					}
					.onChange(of: selectedProject) { _, newValue in
						if let project = newValue {
							proximityUUID = project.proximityUUID
						} else {
							proximityUUID = ""
						}
					}
					
					HStack {
						TextField("Proximity UUID", text: $proximityUUID)
							.foregroundColor(selectedProject != nil ? .secondary : .primary)
							.disabled(selectedProject != nil)
							.onChange(of: proximityUUID) { _, newValue in
								if let matchedProject = availableProjects.first(where: { $0.proximityUUID.caseInsensitiveCompare(newValue) == .orderedSame }) {
									if selectedProject != matchedProject {
										selectedProject = matchedProject
									}
								} else if selectedProject != nil && selectedProject?.proximityUUID.caseInsensitiveCompare(newValue) != .orderedSame {
									selectedProject = nil
								}
							}
						
						if selectedProject == nil {
							Button {
								if let pastedString = ClipboardUtilities.paste() {
									proximityUUID = pastedString
								}
							} label: {
								Image(systemName: "document.on.clipboard")
									.font(.callout)
							}
							.buttonStyle(.plain)
						}
					}
				} footer: {
					Text("Enter a UUID or select an existing project to start discovering iBeacons. Your selection will be saved for next time.")
				}
				
#if os(iOS)
				Section {
					if isBackgroundReady {
						Toggle("Background Notifications", isOn: $isBackgroundEnabled)
					} else {
						Button(hasDeniedPermissions ? "Open Settings to Enable" : "Grant Permissions") {
							withAnimation {
								onGrantPermissionClick()
							}
						}
						.frame(maxWidth: .infinity)
					}
				} footer: {
					if hasDeniedPermissions {
						Text("To receive proximity alerts while the app is closed, you must grant both \"Always\" location access and Notification permissions.")
					} else {
						Text("This will trigger a notification whenever you enter or exit the range of a beacon with this UUID while the app is in the background.")
					}
				}
#endif
				
				Button(action: onStartDiscoveryClick) {
					Text("Start Discovery")
						.frame(maxWidth: .infinity)
						.foregroundStyle(isUUIDValid ? .prominentButtonText : .gray)
				}
				.buttonStyle(.borderedProminent)
				.disabled(!isUUIDValid)
				.listRowBackground(Color.clear)
			}
			.formStyle(.grouped)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
	@Previewable @State var selectedProject: BroadcastProject? = nil
	@Previewable @State var proximityUUID: String = ""
	@Previewable @State var isBackgroundEnabled: Bool = false
	
#if os(iOS)
	DiscoverFormView(
		selectedProject: $selectedProject,
		proximityUUID: $proximityUUID,
		isBackgroundEnabled: $isBackgroundEnabled,
		isBackgroundReady: false,
		hasDeniedPermissions: false,
		onGrantPermissionClick: {},
		availableProjects: [
			BroadcastProject(name: "Office Setup", proximityUUID: UUID().uuidString),
			BroadcastProject(name: "Home Lab", proximityUUID: UUID().uuidString)
		],
		onStartDiscoveryClick: {}
	)
#else
	DiscoverFormView(
		selectedProject: $selectedProject,
		proximityUUID: $proximityUUID,
		availableProjects: [
			BroadcastProject(name: "Office Setup", proximityUUID: UUID().uuidString),
			BroadcastProject(name: "Home Lab", proximityUUID: UUID().uuidString)
		],
		onStartDiscoveryClick: {}
	)
#endif
}
