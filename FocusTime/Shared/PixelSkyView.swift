import SwiftUI

/// A fully code-drawn pixel-art sky scene shared by the app window and the widget.
/// Focus phases read as daytime, breaks as night. Everything is rendered with
/// solid blocks on a Canvas, so it is original, license-free, and crisp at any size.
struct PixelSkyView: View {
    var phase: TimerPhase
    var style: FocusBackgroundStyle
    var animated: Bool = true
    var date: Date = .now

    private var isNight: Bool { phase == .break || style == .moonNight }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 8.0, paused: false)) { context in
                    scene(at: context.date)
                }
            } else {
                scene(at: date)
            }
        }
    }

    private func scene(at date: Date) -> some View {
        Canvas { context, size in
            drawSky(context, size: size)
            if isNight { drawStars(context, size: size, date: date) }
            drawCelestialBody(context, size: size, date: date)
            drawClouds(context, size: size, date: date)
            drawHills(context, size: size)
            drawVignette(context, size: size)
        }
    }

    // MARK: - Sky

    private func drawSky(_ context: GraphicsContext, size: CGSize) {
        let colors = FocusPalette.skyGradient(for: date, phase: phase, style: style)
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: colors),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    // MARK: - Stars

    private func drawStars(_ context: GraphicsContext, size: CGSize, date: Date) {
        let block = max(2, size.width / 110)
        let twinkle = Int(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 4))
        // Deterministic scatter so stars hold position across frames.
        let seeds: [(x: CGFloat, y: CGFloat, phase: Int)] = [
            (0.08, 0.12, 0), (0.18, 0.30, 1), (0.27, 0.08, 2), (0.34, 0.22, 3),
            (0.46, 0.14, 0), (0.55, 0.28, 1), (0.63, 0.10, 2), (0.72, 0.24, 3),
            (0.81, 0.16, 0), (0.90, 0.30, 1), (0.13, 0.42, 2), (0.40, 0.40, 3),
            (0.68, 0.40, 0), (0.86, 0.44, 1), (0.50, 0.06, 2), (0.22, 0.50, 3)
        ]
        for star in seeds {
            let lit = (star.phase + twinkle) % 4 != 0
            let alpha = lit ? 0.95 : 0.35
            let rect = CGRect(x: size.width * star.x, y: size.height * star.y, width: block, height: block)
            context.fill(Path(rect), with: .color(.white.opacity(alpha)))
        }
    }

    // MARK: - Sun / Moon

    private func drawCelestialBody(_ context: GraphicsContext, size: CGSize, date: Date) {
        let block = max(3, size.width / 46)
        let center = CGPoint(x: size.width * 0.76, y: size.height * 0.20)
        let radius = block * 2.4

        if isNight {
            // Moon: soft disc with a crescent bite.
            fillDisc(context, center: center, radius: radius, block: block, color: .white.opacity(0.95))
            fillDisc(
                context,
                center: CGPoint(x: center.x + block * 1.1, y: center.y - block * 0.4),
                radius: radius * 0.92,
                block: block,
                color: FocusPalette.skyGradient(for: date, phase: phase, style: style)[0]
            )
        } else {
            // Sun: disc plus four pixel rays.
            let rayColor = Color(red: 1.0, green: 0.93, blue: 0.6).opacity(0.9)
            let rayLen = block * 1.4
            for (dx, dy) in [(0.0, -1.0), (0.0, 1.0), (-1.0, 0.0), (1.0, 0.0)] {
                let rect = CGRect(
                    x: center.x - block * 0.5 + CGFloat(dx) * (radius + block * 0.6),
                    y: center.y - block * 0.5 + CGFloat(dy) * (radius + block * 0.6),
                    width: block, height: block
                )
                let stretched = CGRect(
                    x: rect.minX - (dx == 0 ? 0 : (dx < 0 ? rayLen : 0)),
                    y: rect.minY - (dy == 0 ? 0 : (dy < 0 ? rayLen : 0)),
                    width: rect.width + (dx == 0 ? 0 : rayLen),
                    height: rect.height + (dy == 0 ? 0 : rayLen)
                )
                context.fill(Path(stretched), with: .color(rayColor))
            }
            fillDisc(context, center: center, radius: radius * 1.18, block: block, color: .white.opacity(0.12))
            fillDisc(context, center: center, radius: radius, block: block, color: Color(red: 1.0, green: 0.86, blue: 0.45))
            fillDisc(context, center: center, radius: radius * 0.6, block: block, color: Color(red: 1.0, green: 0.95, blue: 0.7))
        }
    }

    /// Draws a pixel-snapped filled circle out of `block`-sized squares.
    private func fillDisc(_ context: GraphicsContext, center: CGPoint, radius: CGFloat, block: CGFloat, color: Color) {
        let steps = Int((radius / block).rounded(.up)) + 1
        for gy in -steps...steps {
            for gx in -steps...steps {
                let px = CGFloat(gx) * block
                let py = CGFloat(gy) * block
                if px * px + py * py <= radius * radius {
                    let rect = CGRect(x: center.x + px - block * 0.5, y: center.y + py - block * 0.5, width: block, height: block)
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }

    // MARK: - Clouds

    private func drawClouds(_ context: GraphicsContext, size: CGSize, date: Date) {
        let cloudColor = FocusPalette.cloudFill(for: style, phase: phase)
        let shadowColor = FocusPalette.cloudShadow(for: style, phase: phase)
        let block = max(3, size.width / 40)
        let drift = animated ? CGFloat(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)) / 60 : 0

        // pattern grid columns (relative pixel positions)
        let patterns: [[CGPoint]] = [
            [.init(x: 1, y: 1), .init(x: 2, y: 1), .init(x: 3, y: 1), .init(x: 2, y: 0)],
            [.init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 2, y: 1), .init(x: 3, y: 1), .init(x: 1, y: 0), .init(x: 2, y: 0)]
        ]
        let placements: [(pattern: Int, x: CGFloat, y: CGFloat, opacity: CGFloat)] = [
            (1, 0.10, 0.30, 0.85),
            (0, 0.52, 0.18, 0.7),
            (0, 0.30, 0.46, 0.6)
        ]

        for placement in placements {
            let baseX = (placement.x - drift).truncatingRemainder(dividingBy: 1.2)
            let wrappedX = baseX < -0.2 ? baseX + 1.2 : baseX
            let originX = wrappedX * size.width
            let originY = placement.y * size.height
            for point in patterns[placement.pattern] {
                let rect = CGRect(
                    x: originX + point.x * block,
                    y: originY + point.y * block,
                    width: block,
                    height: block
                )
                context.fill(Path(rect.offsetBy(dx: 0, dy: block * 0.5)), with: .color(shadowColor.opacity(placement.opacity)))
                context.fill(Path(rect), with: .color(cloudColor.opacity(placement.opacity)))
            }
        }
    }

    // MARK: - Hills

    private func drawHills(_ context: GraphicsContext, size: CGSize) {
        let colors = FocusPalette.hillColors(for: style, phase: phase)
        drawHillLayer(context, size: size, color: colors.far, baseline: 0.80, amplitude: 0.05, frequency: 2.2, offset: 0)
        drawHillLayer(context, size: size, color: colors.near, baseline: 0.90, amplitude: 0.06, frequency: 1.4, offset: 1.4)
    }

    private func drawHillLayer(
        _ context: GraphicsContext,
        size: CGSize,
        color: Color,
        baseline: CGFloat,
        amplitude: CGFloat,
        frequency: CGFloat,
        offset: CGFloat
    ) {
        let block = max(4, size.width / 28)
        var x: CGFloat = 0
        while x < size.width {
            let t = x / size.width
            let wave = sin(Double(t * frequency * .pi * 2 + offset))
            let topY = (baseline - amplitude * CGFloat(wave)) * size.height
            let snappedTop = (topY / block).rounded() * block
            let rect = CGRect(x: x, y: snappedTop, width: block, height: size.height - snappedTop)
            context.fill(Path(rect), with: .color(color))
            x += block
        }
    }

    // MARK: - Vignette

    private func drawVignette(_ context: GraphicsContext, size: CGSize) {
        // Subtle darkening toward the center keeps the timer readable on bright skies.
        let dim = isNight ? 0.16 : 0.10
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [.clear, .black.opacity(dim)]),
                center: CGPoint(x: size.width / 2, y: size.height / 2),
                startRadius: size.width * 0.18,
                endRadius: size.width * 0.72
            )
        )
    }
}
