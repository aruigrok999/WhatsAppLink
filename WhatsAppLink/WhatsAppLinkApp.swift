//
//  WhatsAppLinkApp.swift
//  WhatsAppLink
//
//  Created by Adrian Ruigrok on 2025-11-10.
//

import SwiftUI

@main
struct WhatsAppLinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(width: 500, height: 150)
#endif
        }
#if os(macOS)
        .windowResizability(.contentSize)
#endif
    }
}
