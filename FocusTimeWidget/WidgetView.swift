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
        HStack(spacing: 20) {
            ring(size: 104)

            VStack(alignment: .leading, spacing: 10) {
                Text("FocusTime")
                    .font(FocusTypography.label(size: 16, weight: .bold))
                    .foregroundStyle(FocusPalette.textPrimary)

                statRow(label: "Today", value: FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                statRow(label: "Sessions", value: "\(entry.snapshot.todaySessions)")
                statRow(label: "Streak", value: "\(entry.snapshot.streak)")
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("FocusTime")
                .font(FocusTypography.label(size: 12, weight: .bold))
                .foregroundStyle(FocusPalette.textPrimary)

            Spacer(minLength: 8)

            ring(size: 96)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 4)
        }
        .padding(16)
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

    private func ring(size: CGFloat) -> some View {
        ZStack {
            RingView(
                progress: entry.snapshot.ringProgress,
                phase: entry.snapshot.phase,
                lineWidth: size * 0.085,
                animated: false
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
