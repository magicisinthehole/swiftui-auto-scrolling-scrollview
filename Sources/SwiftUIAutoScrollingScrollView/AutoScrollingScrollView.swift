//
//  AutoScrollingScrollView.swift
//  SwiftUIAutoScrollingScrollView
//
//  Created by Andrew Benson on 4/18/25.
//  Copyright (C) 2025 Nuclear Cyborg Corp
//
//  MIT License
//

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "SwiftUIAutoScrollingScrollView", category: "AutoScrollingScrollView")

/// A `SwiftUI` `ScrollView` that will automatically scroll to
/// the bottom when content changes, while respecting manual scrolling
/// performed by the user. This is accomplished by monitoring the provided
/// `value` for changes. When a change is observed, if the `content`
/// was already scrolled to the bottom (or very near to it), it will be scrolled
/// to the bottom again. However, if it wasn't near the bottom, no automatic
/// scrolling will be performed.
@available(iOS 18.0, macOS 15, tvOS 13.0, watchOS 6.0, *)
public struct AutoScrollingScrollView<Content, OverlayContent, V, ScrollPositionType> : View where Content : View, OverlayContent: View, V : Equatable, ScrollPositionType : (Hashable & Sendable) {
    /// An identifier for the current message.  This is so
    /// we can pull it out of the `ForEach` and (hopefully) not re-render ALL
    /// of the content when the current message changes.
    ///
    /// This is only part of the example, not part of the scrolling solution
    @Namespace private var currentMessageNamespace

    // MARK: - State used as part of the scrolling solution

    /// `true` if the bottom of the scroll view is visible
    @State private var isBottomOfScrollViewContentVisible = true
    //    @Binding private var shouldScrollOnAnyChange: Bool

    @Namespace private var bottomOfScrollView
    @State private var bottomDetector = "bottom detector"
    @State private var scrollPositionID: String?

    @Binding private var lockToBottom: Bool

    /// The scroll view's content.
    public var content: Content

    /// Overlay content is overlaid at the bottom of the scroll area when there is additional content
    /// which will not be automatically scrolled to reveal
    public var overlayContent: OverlayContent

    /// The scrollable axes of the scroll view.
    ///
    /// The default value is ``Axis/vertical``.
    public var axes: Axis.Set

    /// Used to trigger changes
    public var value: V

    /// Creates a new instance that's scrollable in the direction of the given
    /// axis and can show indicators while scrolling.  f was scrollled to the
    /// bottom previously, will automatically scroll to the bottom on change
    /// of the given `value`.
    ///
    /// - Parameters:
    ///   - axes: The scroll view's scrollable axis. The default axis is the
    ///     vertical axis.
    ///   - value: An `equatable` value to monitor for changes.  Changes
    ///     in this value are used to trigger automatic scroll-to-bottom.
    ///   - content: The view builder that creates the scrollable view.
    @available(iOS 18.0, macOS 15.0, tvOS 13.0, watchOS 6.0, *)
    public init(_ axes: Axis.Set = .vertical, lockToBottom: Binding<Bool>, lastScrollViewID: ScrollPositionType, autoScrollingOnChangeOf value: V, @ViewBuilder overlayContent: () -> OverlayContent, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self._lockToBottom = lockToBottom
        //        self._shouldScrollOnAnyChange = shouldScrollOnAnyChange
        self.value = value
        self.content = content()
        self.overlayContent = overlayContent()
        self.lastScrollViewID = lastScrollViewID
    }
    let lastScrollViewID: ScrollPositionType

    @State private var scrollPhase: ScrollPhase = .idle
//    @State private var shouldDisplayScrollToBottomOverlay: Bool = false
    @State private var lastSeenID: ScrollPositionType?
    @State private var scrollViewPositionChecker = ScrollPosition(idType: ScrollPositionType.self)

    private var shouldDisplayScrollToBottomOverlay: Bool {
        let currentViewID = scrollViewPositionChecker.viewID(type: ScrollPositionType.self)
        let currentIsBottomDetector = scrollViewPositionChecker.viewID(type: String.self) == bottomDetector
        return scrollPhase == .idle && currentViewID != lastScrollViewID && currentViewID != nil && !currentIsBottomDetector
    }
//    private func updateShouldDisplayScrollToBottomOverlay() {
//        let newValue = !isBottomOfScrollViewContentVisible && scrollPhase == .idle
//        if shouldDisplayScrollToBottomOverlay != newValue {
//            withAnimation(Animation.easeInOut(duration: 0.5)) {
//                shouldDisplayScrollToBottomOverlay = newValue
//            }
//        }
//    }
    struct ScrollData: Equatable {
        let size: CGSize
        let visible: CGRect
    }
    @State private var scrollData: ScrollData?
    @State private var weSeeIt: Bool = false
    @State private var isBottomVisible: Bool = false

    @State private var shouldAutoScrollOnNewContent: Bool = true

    /// The content and behavior of the scroll view.
    public var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(axes) {
                content
                    .overlay(alignment: .bottom) {
                        Text("")

                        // This .frame is kind of a hack, so this is still not ideal
                            .frame(height: 111)
                            .id(bottomDetector)
//                            .onScrollVisibilityChange(threshold: 0.10) { isVisible in
//                                if isBottomVisible != isVisible {
//                                    isBottomVisible = isVisible
//                                    if isVisible {
//                                        if shouldAutoScrollOnNewContent != true {
//                                            DispatchQueue.main.async {
//                                                shouldAutoScrollOnNewContent = true
//                                            }
//                                        }
//                                    }
//                                }
//                            }
                    }
                    .id(bottomOfScrollView)
            }
            .simultaneousGesture(DragGesture(minimumDistance: 0.01)
                .onChanged { _ in
                    Task { @MainActor in
                        if shouldAutoScrollOnNewContent != false {
                            shouldAutoScrollOnNewContent = false
                        }
                    }
                }
                                 )
            .defaultScrollAnchor(.bottom, for: .sizeChanges)
            .scrollPosition($scrollViewPositionChecker, anchor: .bottom)
            .onScrollPhaseChange({ _, newPhase in
                DispatchQueue.main.async {
                    if scrollPhase != newPhase {
                        scrollPhase = newPhase
                    }
                }
            })
            /*
            .overlay(alignment: .top) {
                Text("Target = \(lastScrollViewID)\n\(scrollViewPositionChecker.viewID(type: ScrollPositionType.self))\nisPositionedByUser = \(scrollViewPositionChecker.isPositionedByUser ? "YES" : "no")")
                    .background(.ultraThinMaterial)
            }
             */
            .overlay(alignment: .bottom) {
                Button {
                    for index in 0 ... 3 {
                        let delay = TimeInterval(index) * 0.55
                        withAnimation(Animation.easeIn(duration: 0.25).delay(0.25)) {
//                            scrollProxy.scrollTo(bottomOfScrollView, anchor: .bottom)
                            scrollViewPositionChecker.scrollTo(edge: .bottom)
                        }
                    }
                    shouldAutoScrollOnNewContent = true
                } label: {
                    overlayContent
                }
                .buttonStyle(.plain)
                .disabled(!shouldDisplayScrollToBottomOverlay)
                .opacity(shouldDisplayScrollToBottomOverlay ? 1.0 : 0.0).animation(Animation.easeInOut(duration: 0.55))
            }

            .onChange(of: value) {
//                Task { @MainActor in
//                    // We got new content - if we can see the bottom of the
//                    // ScrollView, then we should scroll to the bottom (of the
//                    // new content)
//                    if shouldAutoScrollOnNewContent {
//                        logger.log(">>> auto scroll to bottom \(Date())")
//                        scrollViewPositionChecker.scrollTo(edge: .bottom)
////                        scrollProxy.scrollTo(bottomOfScrollView, anchor: .bottom)
//                    }
//                }
            }
        }
    }
}
