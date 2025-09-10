//
//  Purpleworks_WorkshopApp.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
import SwiftData

@main
struct Purpleworks_WorkshopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // SwiftData 모델 등록 (iOS/iPadOS 17
        .modelContainer(for: [Team.self])
    }
}
