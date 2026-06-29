import SwiftUI

/// A small, clean design system shared by the app and the widget.
enum FocusPalette {
    // Surfaces
    static let backgroundTop = Color(red: 0.12, green: 0.13, blue: 0.19)
    static let backgroundBottom = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let surface = Color.white.opacity(0.06)
    static let surfaceStrong = Color.white.opacity(0.10)
    static let surfaceStroke = Color.white.opacity(0.12)
    static let cardShadow = Color.black.opacity(0.40)

    // Text
    static let textPrimary = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let textSecondary = Color(red: 0.64, green: 0.68, blue: 0.78)

    // Ring
    static let ringTrack = Color.white.opacity(0.08)

    static func accent(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.40, green: 0.64, blue: 1.00)
        case .break:
            return Color(red: 0.34, green: 0.84, blue: 0.62)
        }
    }

    /// Gradient used to stroke the progress ring and fill the primary button.
    static func accentGradient(for phase: TimerPhase) -> [Color] {
        switch phase {
        case .focus:
            return [
                Color(red: 0.46, green: 0.78, blue: 1.00),
                Color(red: 0.36, green: 0.55, blue: 1.00)
            ]
        case .break:
            return [
                Color(red: 0.52, green: 0.93, blue: 0.71),
                Color(red: 0.28, green: 0.78, blue: 0.58)
            ]
        }
    }

    /// Soft tint used for the ambient glow behind the ring.
    static func accentSoft(for phase: TimerPhase) -> Color {
        accent(for: phase).opacity(0.22)
    }
}

enum FocusTypography {
    static func timer(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func label(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// A tactile press effect used across the app's buttons.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
