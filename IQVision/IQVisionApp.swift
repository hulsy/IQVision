//
//  IQVisionApp.swift
//  IQVision
//
//  Created by Alex Hulford on 2023-06-29.
//

import SwiftUI

@main
struct IQVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black // Set the background color to black
                    .ignoresSafeArea(.all) // Ignore safe area to cover the entire screen
                
                ContentView()
            }
        }
    }
}
