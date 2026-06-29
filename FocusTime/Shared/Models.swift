import Foundation

enum FocusCorner: String, CaseIterable, Codable, Identifiable {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topRight:
            return "Top Right"
        case .topLeft:
            return "Top Left"
        case .bottomRight:
            return "Bottom Right"
        case .bottomLeft:
            return "Bottom Left"
        }
    }
}

enum TimerPhase: String, CaseIterable, Codable, Identifiable {
    case focus
    case `break`

    var id: String { rawValue }

    var next: TimerPhase {
        self == .focus ? .break : .focus
    }

    var title: String {
        switch self {
        case .focus:
            return "Focus"
        case .break:
            return "Break"
        }
    }

    func duration(using settings: FocusSettings) -> Int {
        switch self {
        case .focus:
            return settings.focusDuration
        case .break:
            return settings.breakDuration
        }
    }
}

struct DailyStats: Codable, Hashable {
    var seconds: Int = 0
    var sessions: Int = 0
}

struct FocusSettings: Codable, Hashable {
    var focusDuration: Int
    var breakDuration: Int
    var soundEnabled: Bool
    var reduceMotion: Bool
    var preferredCorner: FocusCorner

    private enum CodingKeys: String, CodingKey {
        case focusDuration
        case breakDuration
        case soundEnabled
        case reduceMotion
        case preferredCorner
    }

    static let `default` = FocusSettings(
        focusDuration: FocusKeys.defaultFocusMinutes * 60,
        breakDuration: FocusKeys.defaultBreakMinutes * 60,
        soundEnabled: true,
        reduceMotion: false,
        preferredCorner: .topRight
    )

    init(
        focusDuration: Int,
        breakDuration: Int,
        soundEnabled: Bool,
        reduceMotion: Bool,
        preferredCorner: FocusCorner
    ) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.soundEnabled = soundEnabled
        self.reduceMotion = reduceMotion
        self.preferredCorner = preferredCorner
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        focusDuration = try container.decodeIfPresent(Int.self, forKey: .focusDuration) ?? FocusSettings.default.focusDuration
        breakDuration = try container.decodeIfPresent(Int.self, forKey: .breakDuration) ?? FocusSettings.default.breakDuration
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? FocusSettings.default.soundEnabled
        reduceMotion = try container.decodeIfPresent(Bool.self, forKey: .reduceMotion) ?? FocusSettings.default.reduceMotion
        preferredCorner = try container.decodeIfPresent(FocusCorner.self, forKey: .preferredCorner) ?? FocusSettings.default.preferredCorner
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(focusDuration, forKey: .focusDuration)
        try container.encode(breakDuration, forKey: .breakDuration)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(reduceMotion, forKey: .reduceMotion)
        try container.encode(preferredCorner, forKey: .preferredCorner)
    }

    var focusMinutes: Int {
        focusDuration / 60
    }

    var breakMinutes: Int {
        breakDuration / 60
    }
}

struct FocusWidgetSnapshot: Codable, Hashable {
    var capturedAt: Date
    var todaySeconds: Int
    var todaySessions: Int
    var streak: Int
    var focusDuration: Int
    var phase: TimerPhase

    var ringProgress: Double {
        guard focusDuration > 0 else { return 0 }
        return min(max(Double(todaySeconds) / Double(focusDuration), 0), 1)
    }

    static let placeholder = FocusWidgetSnapshot(
        capturedAt: .now,
        todaySeconds: 4_800,
        todaySessions: 3,
        streak: 6,
        focusDuration: FocusKeys.defaultFocusMinutes * 60,
        phase: .focus
    )
}
