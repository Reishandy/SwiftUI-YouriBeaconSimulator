//
//  BroadcastSectionHeaderView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct BroadcastSectionHeaderView: View {
	let title: String
	let uuid: String
	
	@State private var copied: Bool = false
	
    var body: some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.title3)
				.bold()
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			
			HStack {
				Text(uuid)
					.font(.callout.monospaced())
					.opacity(0.8)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
				
				Spacer()
				
				Image(systemName: copied ? "checkmark.circle" : "document.on.document")
					.font(.footnote)
					.contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
			}
			.onTapGesture {
				ClipboardUtilities.copy(uuid)
				
				withAnimation() {
					copied = true
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					withAnimation() {
						copied = false
					}
				}
			}
		}
    }
}

#Preview {
    BroadcastSectionHeaderView(title: "Project Name", uuid: UUID().uuidString)
}
