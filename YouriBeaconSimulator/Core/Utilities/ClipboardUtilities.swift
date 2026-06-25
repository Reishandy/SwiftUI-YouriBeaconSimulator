//
//  ClipboardUtilities.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ClipboardUtilities {
	static func copy(_ text: String) {
	#if os(macOS)
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(text, forType: .string)
	#else
		UIPasteboard.general.string = text
	#endif
	}
}
