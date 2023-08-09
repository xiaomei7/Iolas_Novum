import SwiftUI

enum Thicccboi: String {
    case thin = "THICCCBOI-Thin"
    case light = "THICCCBOI-Light"
    case regular = "THICCCBOI-Regular"
    case medium = "THICCCBOI-Medium"
    case semibold = "THICCCBOI-SemiBold"
    case bold = "THICCCBOI-Bold"
    case extrabold = "THICCCBOI-Extrabold"
    case black = "THICCCBOI-Black"
    case thick = "THICCCBOI-ThicccAF"
}

extension View {
    func thicccboi(_ size: CGFloat, _ weight: Thicccboi) -> some View {
        self
            .font(.custom(weight.rawValue, size: size))
    }
}
