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
                .stroke(FocusPalette.surfaceStroke, lineWidth: 1)
        )
        .shadow(color: FocusPalette.cardShadow, radius: 22, x: 0, y: 16)
        .overlay(alignment: .topTrailing) {
            SettingsLink {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FocusPalette.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(FocusPalette.surface))
                    .overlay(Circle().stroke(FocusPalette.surfaceStroke, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Open settings")
            .padding(14)
        }
        .ignoresSafeArea()
        .background(
            WindowAccessor { window in
                AppDelegate.shared?.registerMainWindow(window)
            }
        )
    }
}

/// A calm dark gradient with a soft accent glow that tints with the current phase.
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
                colors: [FocusPalette.accentSoft(for: phase), .clear],
                center: .init(x: 0.5, y: 0.32),
                startRadius: 8,
                endRadius: 240
            )
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
    }
}
