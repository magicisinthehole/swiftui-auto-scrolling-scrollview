//
//  ContentView.swift
//  AutoScrollingScrollViewExample
//
//  Created by Andrew Benson on 4/18/25.
//
//
// A simulated stream of fake junk "messages",
// to demonstrate the use of `SwiftUIAutoScrollingScrollView`
//

import SwiftUI
import SwiftUIAutoScrollingScrollView

struct ContentView: View {
    /// Generates random text
    @State private var junkGenerator = JunkGenerator()

    /// An array of prior "messages"
    @State private var previousJunk: [String] = []

    var body: some View {
        VStack {
            HStack {
                Button("Start") { junkGenerator.startGenerating() }
                Button("Stop") { junkGenerator.stopGenerating()}
                Button("Next \"Message\"") { previousJunk.append(junkGenerator.text); junkGenerator.text = "" }
            }
            .buttonStyle(.bordered)
            AutoScrollingScrollView(.vertical, autoScrollingOnChangeOf: junkGenerator.text) {
                LazyVStack {
                    ForEach(previousJunk, id: \.self) { someJunk in
                        JunkView(junk: someJunk)
                    }
                    JunkView(junk: junkGenerator.text)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
    }
}

/// Displays our junk message
struct JunkView: View {
    let junk: String

    var body: some View {
        Text(junk)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
