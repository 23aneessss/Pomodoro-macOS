import AppKit
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
            WidgetBackdropView(snapshot: entry.snapshot, family: family)
        }
    }

    private var mediumWidget: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FocusTime")
                        .font(FocusTypography.pixel(size: 17))
                        .foregroundStyle(FocusPalette.textPrimary)

                    Text(entry.snapshot.phase.title.uppercased())
                        .font(FocusTypography.pixel(size: 12))
                        .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))
                        .tracking(1.6)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 12)

            HStack(spacing: 18) {
                widgetRing(size: 110, timeFontSize: 17, phaseFontSize: 8)

                VStack(alignment: .leading, spacing: 12) {
                    statRow(label: "Today", value: FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                    statRow(label: "Sessions", value: "\(entry.snapshot.todaySessions)")
                    statRow(label: "Streak", value: "\(entry.snapshot.streak)")
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var smallWidget: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FocusTime")
                        .font(FocusTypography.pixel(size: 12))
                        .foregroundStyle(FocusPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(entry.snapshot.phase.title.uppercased())
                        .font(FocusTypography.pixel(size: 9))
                        .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))
                        .tracking(1.0)
                }

                Spacer(minLength: 0)
            }

            Spacer(minLength: 10)

            widgetRing(size: 104, timeFontSize: 15, phaseFontSize: 7)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(FocusTypography.pixel(size: 11))
                .foregroundStyle(FocusPalette.textPrimary.opacity(0.76))

            Spacer(minLength: 12)

            Text(value)
                .font(FocusTypography.timer(size: 16))
                .monospacedDigit()
                .foregroundStyle(FocusPalette.textPrimary)
        }
    }

    private func widgetRing(size: CGFloat, timeFontSize: CGFloat, phaseFontSize: CGFloat) -> some View {
        ZStack {
            PixelRingView(
                progress: entry.snapshot.ringProgress,
                phase: entry.snapshot.phase,
                segments: 36,
                segmentLength: 10,
                segmentThickness: 4
            )
            .frame(width: size, height: size)

            VStack(spacing: 4) {
                Text(FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                    .font(FocusTypography.timer(size: timeFontSize))
                    .monospacedDigit()
                    .foregroundStyle(FocusPalette.timerText)

                Text(entry.snapshot.phase.title.uppercased())
                    .font(FocusTypography.pixel(size: phaseFontSize))
                    .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))
                    .tracking(1.0)
            }
        }
    }
}

private struct WidgetBackdropView: View {
    let snapshot: FocusWidgetSnapshot
    let family: WidgetFamily

    var body: some View {
        ZStack {
            Rectangle()
                .fill(FocusPalette.widgetBackground)

            PixelSkyView(
                phase: snapshot.phase,
                style: snapshot.backgroundStyle,
                animated: false,
                date: snapshot.capturedAt
            )

            Rectangle()
                .fill(Color.black.opacity(0.28))

            Rectangle()
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        }
    }
}
