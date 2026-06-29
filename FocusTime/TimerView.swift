import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        VStack(spacing: 30) {
            timerCluster
            controls
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var timerCluster: some View {
        ZStack {
            RingView(
                progress: viewModel.progress,
                phase: viewModel.phase,
                lineWidth: 13,
                animated: !viewModel.settings.reduceMotion
            )
            .frame(width: 196, height: 196)

            VStack(spacing: 6) {
                Text(viewModel.phase.title.uppercased())
                    .font(FocusTypography.label(size: 11))
                    .tracking(2.6)
                    .foregroundStyle(FocusPalette.accent(for: viewModel.phase))

                Text(viewModel.timeLabel)
                    .font(FocusTypography.timer(size: 48))
                    .monospacedDigit()
                    .foregroundStyle(FocusPalette.textPrimary)
                    .contentTransition(.numericText())

                Text(viewModel.todayFocusLabel + " today")
                    .font(FocusTypography.body(size: 11, weight: .medium))
                    .foregroundStyle(FocusPalette.textSecondary)
                    .padding(.top, 2)
            }
        }
        .frame(width: 196, height: 196)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue(viewModel.timerAccessibilityValue)
    }

    private var controls: some View {
        HStack(spacing: 26) {
            SecondaryControlButton(
                systemName: "arrow.counterclockwise",
                accessibilityLabel: "Restart timer",
                action: viewModel.resetTimer
            )

            PrimaryControlButton(
                isRunning: viewModel.isRunning,
                phase: viewModel.phase,
                action: viewModel.toggleTimer
            )

            SecondaryControlButton(
                systemName: "forward.fill",
                accessibilityLabel: "Skip to next phase",
                action: viewModel.skipPhase
            )
        }
    }
}

private struct PrimaryControlButton: View {
    let isRunning: Bool
    let phase: TimerPhase
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: FocusPalette.accentGradient(for: phase),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .shadow(color: FocusPalette.accent(for: phase).opacity(0.45), radius: 12, x: 0, y: 6)

                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: isRunning ? 0 : 2)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(isRunning ? "Pause" : "Start")
    }
}

private struct SecondaryControlButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FocusPalette.textPrimary)
                .frame(width: 48, height: 48)
                .background(Circle().fill(FocusPalette.surface))
                .overlay(Circle().stroke(FocusPalette.surfaceStroke, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
