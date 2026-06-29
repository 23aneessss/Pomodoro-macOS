import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        ZStack {
            BackgroundView(phase: viewModel.phase)
            TimerView(viewModel: viewModel)
        }
        .frame(width: FocusWindowMetrics.defaultWidth, height: FocusWindowMetrics.defaultHeight)
        .clipShape(RoundedRectangle(cornerRadius: FocusWindowMetrics.panelCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FocusWindowMetrics.panelCornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .ignoresSafeArea()
        .background(
            WindowAccessor { window in
                AppDelegate.shared?.registerMainWindow(window)
            }
        )
    }
}

/// A calm dark gradient with a restrained accent glow that tints with the phase.
struct BackgroundView: View {
    var phase: TimerPhase

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FocusPalette.backgroundTop, FocusPalette.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [FocusPalette.accent(for: phase).opacity(0.14), .clear],
                center: .init(x: 0.5, y: 0.30),
                startRadius: 4,
                endRadius: 260
            )
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
    }
}
