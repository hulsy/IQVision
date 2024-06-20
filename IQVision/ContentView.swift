//
//  ContentView.swift
//  IQVision
//
//  Created by Alex Hulford on 2023-06-29.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var randomNumber = 0
    @Published var isGeneratingNumber = false
    @Published var isGeneratingRainbow = false
    @Published var randomRainbowColor = Color.clear
    @Published var randomRainbowColorName = ""
    @Published var timerInterval = 1.0 // Initial timer interval

    private var numberTimer: Timer?
    private var rainbowTimer: Timer?

    func toggleRandomNumberGeneration() {
        isGeneratingRainbow = false
        randomRainbowColorName = ""
        isGeneratingNumber.toggle()
        if isGeneratingNumber {
            startGeneratingRandomNumbers()
        } else {
            stopGeneratingRandomNumbers()
        }
    }

    func toggleRandomRainbowGeneration() {
        isGeneratingNumber = false
        randomNumber = 0
        isGeneratingRainbow.toggle()
        if isGeneratingRainbow {
            startGeneratingRandomRainbowColors()
        } else {
            stopGeneratingRandomRainbowColors()
        }
    }

    func updateTimerInterval(value: Double) {
        timerInterval = value
        // Restart the timers with the updated interval if they are active
        if isGeneratingNumber {
            stopGeneratingRandomNumbers()
            startGeneratingRandomNumbers()
        }
        if isGeneratingRainbow {
            stopGeneratingRandomRainbowColors()
            startGeneratingRandomRainbowColors()
        }
    }

    private func startGeneratingRandomNumbers() {
        numberTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            self?.randomNumber = Int.random(in: 1...99)
        }
    }

    private func stopGeneratingRandomNumbers() {
        numberTimer?.invalidate()
        randomNumber = 0
    }

    private func startGeneratingRandomRainbowColors() {
        rainbowTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            let (color, name) = Color.randomRainbowColorWithNames(excluding: self?.randomRainbowColorName)
            self?.randomRainbowColor = color
            self?.randomRainbowColorName = name
        }
    }

    private func stopGeneratingRandomRainbowColors() {
        rainbowTimer?.invalidate()
    }
}

extension Color {
    static func randomRainbowColorWithNames(excluding currentColorName: String?) -> (Color, String) {
        let colors: [(Color, String)] = [
            (.red, "Blue"),
            (.orange, "Green"),
            (.yellow, "Red"),
            (.green, "Purple"),
            (.blue, "Yellow"),
            (.purple, "Orange")
        ]
        
        // Filter out the current color
        let filteredColors = colors.filter { $0.1 != currentColorName }
        
        return filteredColors.randomElement() ?? (.black, "Black")
    }
}

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var isLoading = true

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                LoadingView(isLoading: $isLoading)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isLoading = false
                        }
                    }
            } else {
                // Your existing content when loading is complete
                MainContentView()
            }
        }
    }
}

struct MainContentView: View {
    @StateObject private var timerManager = TimerManager()

    var body: some View {
        ZStack(alignment: .bottom) { // Use a ZStack to overlay buttons at the bottom
            VStack {
                Spacer()

                if timerManager.isGeneratingNumber {
                    Text("\(timerManager.randomNumber)")
                        .font(.system(size: 400))
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.white)
                }

                Text(timerManager.randomRainbowColorName)
                    .font(.system(size: 300))
                    .padding()
                    .foregroundColor(timerManager.isGeneratingRainbow ? timerManager.randomRainbowColor : .white) // Set text color conditionally

                Spacer()
                                    
            }
            .background(Color.black)
            .ignoresSafeArea(.all)

            HStack {
                Spacer()

                Button(action: {
                    timerManager.toggleRandomNumberGeneration()
                }) {
                    Text(timerManager.isGeneratingNumber ? "Stop Number Drill" : "Start Number Drill")
                        .font(.headline)
                        .padding()
                        .background(timerManager.isGeneratingNumber ? Color("iq_green") : Color("iq_green"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .disabled(timerManager.isGeneratingRainbow)
                .frame(width: 300)

                Spacer()
                
                
                VStack {
                    
                    Text("Time Interval").font(.title2).foregroundColor(Color.white)
                    
                    Slider(
                            value: $timerManager.timerInterval,
                            in: 1.0...2.0,
                            step: 0.5
                        ) {
                            Text("Seconds")
                        } minimumValueLabel: {
                            Text("1s").font(.title2).fontWeight(.thin).foregroundColor(.white)
                        } maximumValueLabel: {
                            Text("2s").font(.title2).fontWeight(.thin).foregroundColor(.white)
                        }
                            .padding()
                            .accentColor(.gray)
                    
                }
                

                Spacer()
                
                Button(action: {
                    timerManager.toggleRandomRainbowGeneration()
                }) {
                    Text(timerManager.isGeneratingRainbow ? "Stop Color Drill" : "Start Color Drill")
                        .font(.headline)
                        .padding()
                        .background(timerManager.isGeneratingRainbow ? Color("iq_green") : Color("iq_green"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .disabled(timerManager.isGeneratingNumber)
                .frame(width: 300)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LoadingView: View {
    @Binding var isLoading: Bool

    var body: some View {
        ZStack {
            Image("loading_background")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)

        }
        .ignoresSafeArea()
    }
}
