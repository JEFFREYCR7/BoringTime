//
//  BoringTimeApp.swift
//  BoringTime
//


import SwiftUI

@main
struct BoringTimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // 注入模型
                .modelContainer(for: Recent.self)
        }
    }
}
