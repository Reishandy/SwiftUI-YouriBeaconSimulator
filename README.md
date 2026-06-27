<div align="center">
  <img src="images/icon.png" alt="Your iBeacon Simulator Logo" width="120">

  # Your iBeacon Simulator

  A native, multi-platform utility designed to simulate, broadcast, and discover iBeacons across iOS, iPadOS, and macOS.

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Swift-6.0-F05138.svg?style=flat&logo=swift" alt="Swift 6.0">
    <img src="https://img.shields.io/badge/iOS-17.0+-000000.svg?style=flat&logo=apple" alt="iOS">
    <img src="https://img.shields.io/badge/macOS-14.0+-000000.svg?style=flat&logo=apple" alt="macOS">
    <img src="https://img.shields.io/badge/License-AGPL%203.0-blue.svg?style=flat" alt="License">
  </p>
</div>

---

## Overview

Your iBeacon Simulator eliminates the need for physical beacon hardware when testing location-based applications, indoor navigation, or proximity marketing triggers. Built entirely in modern Swift, it leverages device capabilities to turn your iPhone, iPad, or Mac into a fully functioning, configurable iBeacon, while also acting as a highly accurate scanner for existing beacons in your environment.

### iOS & iPadOS Previews

<div align="center">
  <img src="images/ios-1.PNG" width="22%" alt="iOS Broadcast">
  <img src="images/ios-2.PNG" width="22%" alt="iOS Project Management">
  <img src="images/ios-3.PNG" width="22%" alt="iOS Discovery">
  <img src="images/ios-4.PNG" width="22%" alt="iOS Beacon Detail">
</div>

### macOS Previews

<div align="center">
  <img src="images/mac-1.png" width="45%" alt="macOS Broadcast">
  <img src="images/mac-2.png" width="45%" alt="macOS Discovery">
</div>

## Key Features

### iBeacon Broadcasting
* **Project-Based Organization:** Group multiple virtual beacons under a single Proximity UUID for clean organization, backed by SwiftData.
* **Full Configuration:** Define custom Major and Minor IDs for every virtual beacon.
* **Real-Time TX Power Calibration:** Dynamically adjust the "Measured TX Power" on the fly for accurate proximity calibration.
* **Quick Share:** Export and share beacon configurations (UUID, Major, Minor) instantly as text.

### Advanced Discovery & Scanning
* **Targeted Scanning:** Input a specific Proximity UUID to actively scan for associated beacons.
* **Session Persistence:** Saves the active UUID and resumes scanning on the next app cold start.
* **Real-Time Proximity Dashboard:** Live list of discovered beacons with dynamic visual indicators for Immediate, Near, Far, and Unknown states.
* **Smart Sorting & State Tracking:** Automatically dims stale beacons that drop off the radar and sorts active ones by closest proximity.
* **Deep-Dive Metrics:** Inspect raw RSSI (Signal Strength), estimated distance in meters, and last-seen timestamps.

### Background Monitoring
* **Always-On Regions:** Utilizes CoreLocation to monitor UUID regions even when the app is minimized or killed.
* **Background Ranging:** Temporarily wakes the app upon region entry to pinpoint the exact beacon (Major/Minor) that triggered the event.
* **Rich Notifications:** Delivers detailed local alerts on entry (e.g., "Found 2 beacons nearby") and exit, along with haptic feedback for foreground discoveries.

## Technical Architecture

This project was built to explore the boundaries of Apple's cross-platform frameworks and Bluetooth stacks. 

* **Multi-Platform Native:** Built with SwiftUI, utilizing adaptive layouts (`TabView` for iOS, `NavigationSplitView` with custom window resizing for macOS).
* **Framework Bridging:** 
  * **macOS:** Implements a custom `CoreBluetooth` (`CBCentralManager`) scanner with a bespoke Low-Pass Filter algorithm to stabilize erratic RSSI readings, alongside manual distance calculation via log-distance path loss approximation. Broadcasting utilizes undocumented CoreBluetooth payload construction.
  * **iOS:** Leverages native `CoreLocation` (`CLLocationManager` and `CLBeaconRegion`) for robust, system-level monitoring.
* **Modern Swift Concurrency:** Fully integrates Swift 6/5.9 features, specifically the new `@Observable` macro for state management across ViewModels and Services.
* **Data Persistence:** SwiftData handles local storage, with iCloud CloudKit synchronization seamlessly propagating configurations across devices.
* **Centralized Permissions Engine:** Asynchronously manages the complex matrix of Bluetooth, Always-On Location, and Notification authorizations across different operating systems.

## Tech Stack

* **Framework:** SwiftUI
* **Language:** Swift 6
* **Data Management:** SwiftData & CloudKit
* **Hardware APIs:** CoreLocation, CoreBluetooth
* **Architecture:** MVVM

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0). This ensures that the spirit of open-source collaboration is maintained. See the LICENSE file for full details.

---

<div align="center">
  <b>Created by Muhammad Akbar Reishandy</b><br>
  <a href="mailto:akbar@reishandy.id">Email</a> |
  <a href="https://reishandy.id">Website</a> |
  <a href="https://github.com/Reishandy">GitHub</a> |
  <a href="https://www.linkedin.com/in/reishandy/">LinkedIn</a>
</div>
