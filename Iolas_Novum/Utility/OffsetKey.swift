//
//  OffsetKey.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
