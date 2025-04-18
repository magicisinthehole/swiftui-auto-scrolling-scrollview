//
//  JunkGenerator.swift
//  AutoScrollingScrollViewExample
//
//  Created by Andrew Benson on 4/18/25.
//  Copyright (C) 2025 Nuclear Cyborg Corp
//

import Foundation
import Observation
import Combine

/// Generates random 'text'
@MainActor
@Observable
final class JunkGenerator {

    public var text: String = ""
    public var isGenerating = false

    public func startGenerating() {
        Task { @MainActor in
            text = ""
            isGenerating = true
            Task.detached { await self.generate() }
        }
    }

    public func stopGenerating() {
        Task { @MainActor in
            isGenerating = false
        }
    }

    
    private func generate() async {
        let delaySeconds = Double.random(in: 0.001...0.250)
        let delayMilliseconds = Int(delaySeconds * 1000)
        try? await Task.sleep(for: .milliseconds(delayMilliseconds))

        let charactersToGenerate = Int.random(in: 1...6)
        let newCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJnKLMNOPQRSTUVWXYZ0123456789")
            .shuffled()
            .prefix(charactersToGenerate)
        var newChars = String(newCharacters)
        if Double.random(in: 0.0...1.0) < 0.68 {
            newChars += " "
        }
        if Double.random(in: 0.0...1.0) < 0.15 {
            newChars += "\n"
            if Double.random(in: 0.0...1.0) < 0.3 {
                newChars += "\n"
            }
        }
        Task { @MainActor in
            text += newChars

            if isGenerating {
                Task.detached { await self.generate() }
            }
        }
    }
}
