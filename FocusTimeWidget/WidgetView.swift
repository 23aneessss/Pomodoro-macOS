import SwiftUI
import WidgetKit

struct WidgetView: View {
    @Environment(\.widgetFamily) private var family

    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget
            default:
                mediumWidget
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [FocusPalette.backgroundTop, FocusPalette.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var mediumWidget: some View {
        HStack(spacing: 22) {
            ring(size: 108, showTicks: true)

            VStack(alignment: .leading, spacing: 0) {
                Text("FocusTime")
                    .font(FocusTypography.label(size: 15, weight: .bold))
                    .foregroundStyle(FocusPalette.textPrimary)
                    .padding(.bottom, 12)

                statRow(label: "Today", value: FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                divider
                statRow(label: "Sessions", value: "\(entry.snapshot.todaySessions)")
                divider
                statRow(label: "Streak", value: "\(entry.snapshot.streak)")
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private var smallWidget: some View {
        ring(size: 110, showTicks: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(14)
    }

    private var divider: some View {
        Rectangle()
            .fill(FocusPalette.surfaceStroke)
            .frame(height: 1)
            .padding(.vertical, 7)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(FocusTypography.body(size: 12, weight: .medium))
                .foregroundStyle(FocusPalette.textSecondary)

            Spacer(minLength: 10)

            Text(value)
                .font(FocusTypography.label(size: 14, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(FocusPalette.textPrimary)
        }
    }

    private func ring(size: CGFloat, showTicks: Bool) -> some View {
        ZStack {
            RingView(
                progress: entry.snapshot.ringProgress,
                phase: entry.snapshot.phase,
                lineWidth: size * 0.08,
                animated: false,
                showTicks: showTicks
            )
            .frame(width: size, height: size)

            VStack(spacing: 2) {
                Text(FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                    .font(FocusTypography.timer(size: size * 0.2))
                    .monospacedDigit()
                    .foregroundStyle(FocusPalette.textPrimary)

                Text(entry.snapshot.phase.title.uppercased())
                    .font(FocusTypography.label(size: size * 0.085))
                    .tracking(1.4)
                    .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))
            }
        }
    }
}
