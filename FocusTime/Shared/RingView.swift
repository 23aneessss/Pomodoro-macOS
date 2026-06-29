import SwiftUI

/// A smooth circular progress ring with a soft glow and a rounded progress head.
struct RingView: View {
    var progress: Double
    var phase: TimerPhase
    var lineWidth: CGFloat = 14
    var animated: Bool = true

    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let radius = (side - lineWidth) / 2
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let angle = Angle.degrees(clamped * 360 - 90)
            let headX = center.x + radius * cos(CGFloat(angle.radians))
            let headY = center.y + radius * sin(CGFloat(angle.radians))

            ZStack {
                Circle()
                    .stroke(FocusPalette.ringTrack, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(
                        AngularGradient(
                            colors: FocusPalette.accentGradient(for: phase),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: FocusPalette.accent(for: phase).opacity(0.45), radius: 8, x: 0, y: 0)

                if clamped > 0.001 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: lineWidth * 0.5, height: lineWidth * 0.5)
                        .position(x: headX, y: headY)
                        .shadow(color: FocusPalette.accent(for: phase).opacity(0.6), radius: 4)
                }
            }
            .animation(animated ? .easeInOut(duration: 0.45) : nil, value: clamped)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
