import SwiftUI

/// A circular progress ring with a fine minute-tick ruler and a clean progress arc.
struct RingView: View {
    var progress: Double
    var phase: TimerPhase
    var lineWidth: CGFloat = 10
    var animated: Bool = true
    var showTicks: Bool = true

    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let arcRadius = side / 2 - (showTicks ? side * 0.085 : lineWidth / 2)
            let angle = Angle.degrees(clamped * 360 - 90)
            let headX = center.x + arcRadius * cos(CGFloat(angle.radians))
            let headY = center.y + arcRadius * sin(CGFloat(angle.radians))

            ZStack {
                if showTicks {
                    ticks(side: side, center: center)
                }

                // Track
                Circle()
                    .stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: arcRadius * 2, height: arcRadius * 2)
                    .position(center)

                // Progress arc
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
                    .frame(width: arcRadius * 2, height: arcRadius * 2)
                    .position(center)
                    .shadow(color: FocusPalette.accent(for: phase).opacity(0.30), radius: 4, x: 0, y: 0)

                if clamped > 0.001 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: lineWidth * 0.62, height: lineWidth * 0.62)
                        .position(x: headX, y: headY)
                }
            }
            .animation(animated ? .easeInOut(duration: 0.4) : nil, value: clamped)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func ticks(side: CGFloat, center: CGPoint) -> some View {
        Canvas { context, _ in
            let outer = side / 2 - side * 0.012
            for index in 0..<60 {
                let major = index % 5 == 0
                let theta = Double(index) / 60 * 2 * .pi - .pi / 2
                let length = major ? side * 0.05 : side * 0.025
                let inner = outer - length
                let cosT = CGFloat(cos(theta))
                let sinT = CGFloat(sin(theta))

                var path = Path()
                path.move(to: CGPoint(x: center.x + outer * cosT, y: center.y + outer * sinT))
                path.addLine(to: CGPoint(x: center.x + inner * cosT, y: center.y + inner * sinT))

                context.stroke(
                    path,
                    with: .color(.white.opacity(major ? 0.20 : 0.08)),
                    lineWidth: major ? 1.5 : 1
                )
            }
        }
    }
}
