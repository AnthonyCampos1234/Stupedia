//
//  ScrollOffsetPreferenceKey.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/12/24.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
