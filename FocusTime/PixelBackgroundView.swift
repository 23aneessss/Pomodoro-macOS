import SwiftUI

/// Window backdrop: a clipped, code-drawn pixel sky with a soft inner border.
struct PixelBackgroundView: View {
    var phase: TimerPhase
    var reduceMotion: Bool
    var style: FocusBackgroundStyle

    private var cornerRadius: CGFloat { FocusWindowMetrics.panelCornerRadius }

    var body: some View {
        PixelSkyView(phase: phase, style: style, animated: !reduceMotion)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}
