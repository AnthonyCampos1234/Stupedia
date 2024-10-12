//
//  TrackableScrollView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/12/24.
//

import SwiftUI

struct TrackableScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    @Binding var scrollOffset: CGFloat

    init(_ axes: Axis.Set = .vertical,
         showsIndicators: Bool = true,
         scrollOffset: Binding<CGFloat>,
         @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
        self._scrollOffset = scrollOffset
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                }
                .frame(height: 0)

                content
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
}
