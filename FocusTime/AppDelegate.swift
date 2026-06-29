import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?

    private weak var mainWindow: NSWindow?
    private let dataStore = DataStore.shared

    override init() {
        super.init()
        AppDelegate.shared = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsDidChange),
            name: .focusSettingsDidChange,
            object: nil
        )

        scheduleWidgetRefresh()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        scheduleWidgetRefresh()
    }

    func registerMainWindow(_ window: NSWindow) {
        mainWindow = window
        configure(window: window, animated: false)
    }

    @objc
    private func handleSettingsDidChange() {
        guard let window = mainWindow else { return }
        configure(window: window, animated: true)
        scheduleWidgetRefresh()
    }

    private func scheduleWidgetRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.dataStore.requestWidgetReload()
        }
    }

    private func configure(window: NSWindow, animated: Bool) {
        let settings = dataStore.loadSettings()
        let size = NSSize(width: FocusWindowMetrics.defaultWidth, height: FocusWindowMetrics.defaultHeight)

        // Borderless + locked min/max guarantees a pixel-perfect square with no
        // titlebar strip; the rounded card is drawn entirely in SwiftUI.
        window.styleMask = [.borderless, .fullSizeContentView]
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.contentMinSize = size
        window.contentMaxSize = size
        window.setContentSize(size)

        reposition(window: window, corner: settings.preferredCorner, animated: animated)
    }

    private func reposition(window: NSWindow, corner: FocusCorner, animated: Bool) {
        guard let screen = window.screen ?? NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame
        let size = window.frame.size
        let inset = FocusWindowMetrics.edgeInset

        let origin: CGPoint
        switch corner {
        case .topRight:
            origin = CGPoint(x: visibleFrame.maxX - size.width - inset, y: visibleFrame.maxY - size.height - inset)
        case .topLeft:
            origin = CGPoint(x: visibleFrame.minX + inset, y: visibleFrame.maxY - size.height - inset)
        case .bottomRight:
            origin = CGPoint(x: visibleFrame.maxX - size.width - inset, y: visibleFrame.minY + inset)
        case .bottomLeft:
            origin = CGPoint(x: visibleFrame.minX + inset, y: visibleFrame.minY + inset)
        }

        window.setFrame(NSRect(origin: origin, size: size), display: true, animate: animated)
    }
}
