# SwiftUIAutoScrollingScrollView

A wrapper to SwiftUI's `ScrollView` which automatically scrolls to the bottom on new content, while still respecting any manual scrolling from the user, even when content is being updated very frequently.

- Use `AutoScrollingScrollView` in place of `ScrollView`. All the normal modifiers should work as expected.
- The initializer is identical to that of `ScrollView`, but for the addition of a single `autoScrollingOnChangeOf` parameter. Just like `.onChange(of:initial:_:)`, this value is monitored for changes.

When a change is detected:
- if the content was already scrolled to the bottom, it will be automatically scrolled to the bottom again, as the new content is added and rendered.
- If the user had scrolled away from the bottom, no automatic scrolling will happen
- If the user scrolls back down to the bottom again, automatic scrolling will kill in again

## Getting Started

**Requires iOS 18 / macOS 15 or higher.**

Include SwiftUIAutoScrollingScrollView in your project.

### In Xcode:
- Add this package dependency by pasting the URL: [https://github.com/drewster99/swiftui-auto-scrolling-scrollview](https://github.com/drewster99/swiftui-auto-scrolling-scrollview)


### As a dependency in your own Swift Package

In a Swift Package's `Package.swift` file, add this to your package's "dependencies" array:
```swift
.package(url: "https://github.com/drewster99/swiftui-auto-scrolling-scrollview.git", branch: "main")
```

Then, add the dependency to any target's you've declared. If it doesn't already have one, add one after `name`:
```swift
.target(
  name: "MyTarget",
  dependencies: [
      .product(name: "SwiftUIAutoScrollingScrollView", package: "swiftui-auto-scrolling-scrollview")
]
```

### Use it in your own Swift code

Use it like you'd use `ScrollView`, with the addition of the `autoScrollingOnChangeOf` parameter, like this:

```swift
import Foundation
import SwiftUI
import SwiftUIAutoScrollingScrollView

struct ContentView: View {
    /// This would be the "data model" that will drive auto scrolling
    @State var items: [String] = []
    
    var body: some View {
        AutoScrollingScrollView(.vertical, autoScrollingOnChangeOf: dataModel) {
            LazyVStack {
                ForEach(items, id: \.self) { item in
                    Text("Item: \(item)")
                        .padding()
                }
            }
        }
    }
}   
```

## Example Project

Check out the `AutoScrollingScrollViewExample` project within the `Examples` folder.
It simulates a chat message list, where some number of messages are static, and there is current message at the bottom which is "streamed" in continuously, with many rapid updates.

