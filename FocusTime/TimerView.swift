import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            timerCluster
            Spacer(minLength: 0)
            controls
            footer
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("FOCUSTIME")
                .font(FocusTypography.label(size: 10, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(FocusPalette.textSecondary)

            Spacer()

            SettingsLink {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(FocusPalette.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(FocusPalette.surface))
                    .overlay(Circle().strokeBorder(FocusPalette.surfaceStroke, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Open settings")
        }
    }

    // MARK: - Timer

    private var timerCluster: some View {
        ZStack {
            RingView(
                progress: viewModel.progress,
                phase: viewModel.phase,
                lineWidth: 9,
                animated: !viewModel.settings.reduceMotion
            )
            .frame(width: 188, height: 188)

            VStack(spacing: 7) {
                Text(viewModel.phase.title.uppercased())
                    .font(FocusTypography.label(size: 11))
                    .tracking(3.0)
                    .foregroundStyle(FocusPalette.accent(for: viewModel.phase))

                Text(viewModel.timeLabel)
                    .font(FocusTypography.timer(size: 46))
                    .monospacedDigit()
                    .foregroundStyle(FocusPalette.textPrimary)
                    .contentTransition(.numericText())

                sessionDots
            }
        }
        .frame(width: 188, height: 188)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue(viewModel.timerAccessibilityValue)
    }

    private var sessionDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<FocusKeys.sessionsPerCycle, id: \.self) { index in
                Circle()
                    .fill(index < viewModel.filledSessionDots
                          ? FocusPalette.accent(for: viewModel.phase)
                          : FocusPalette.textSecondary.opacity(0.28))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.top, 1)
        .accessibilityHidden(true)
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 24) {
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

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 14) {
            footerStat(icon: "clock", text: "\(viewModel.todayFocusLabel) today")
            Circle().fill(FocusPalette.textSecondary.opacity(0.3)).frame(width: 3, height: 3)
            footerStat(icon: "flame.fill", text: "\(viewModel.streak) day streak")
        }
        .padding(.top, 16)
    }

    private func footerStat(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(FocusTypography.body(size: 11, weight: .medium))
        }
        .foregroundStyle(FocusPalette.textSecondary)
    }
}

// MARK: - Buttons

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
                    .frame(width: 62, height: 62)
                    .shadow(color: FocusPalette.accent(for: phase).opacity(0.28), radius: 8, x: 0, y: 4)

                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 21, weight: .bold))
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(FocusPalette.textPrimary.opacity(0.85))
                .frame(width: 46, height: 46)
                .background(Circle().fill(FocusPalette.surface))
                .overlay(Circle().strokeBorder(FocusPalette.surfaceStroke, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
