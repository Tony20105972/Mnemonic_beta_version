import SwiftUI
import KeyboardShortcuts
import OSLog

// Defines app-level keyboard shortcut names used by KeyboardShortcuts.
extension KeyboardShortcuts.Name {
    static let openDashboard = Self("openDashboard")
}

// Handles app lifecycle callbacks required for clean daemon shutdown.
final class AppDelegate: NSObject, NSApplicationDelegate {
    var daemonManager: DaemonManager?

    func applicationWillTerminate(_ notification: Notification) {
        daemonManager?.stopDaemon()
    }
}

// Entry point for the menu bar-only Mnemonic V1 macOS AppShell.
@main
struct MnemonicApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var daemonManager = DaemonManager()

    private let logger = Logger(subsystem: "com.mnemonic.appshell", category: "app")

    init() {
        // Register Cmd+K handler. Users can remap this in settings UI later.
        KeyboardShortcuts.onKeyUp(for: .openDashboard) {
            Logger(subsystem: "com.mnemonic.appshell", category: "hotkey")
                .info("Dashboard Opening...")
            print("Dashboard Opening...")
        }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(
                currentProjectName: "Mnemonic V1",
                onOpenDashboard: openDashboard,
                onOpenSettings: openSettings,
                onQuit: quitApp
            )
            .onAppear {
                appDelegate.daemonManager = daemonManager
                daemonManager.startDaemonIfNeeded()
                registerDefaultShortcutIfNeeded()
            }
        } label: {
            Image(systemName: "brain.head.profile")
        }

        Settings {
            ShortcutSettingsView()
                .padding(16)
                .frame(width: 320, height: 180)
        }
    }

    private func registerDefaultShortcutIfNeeded() {
        if KeyboardShortcuts.getShortcut(for: .openDashboard) == nil {
            KeyboardShortcuts.setShortcut(.init(.k, modifiers: [.command]), for: .openDashboard)
        }
    }

    private func openDashboard() {
        logger.info("Dashboard Opening...")
        print("Dashboard Opening...")
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    private func quitApp() {
        daemonManager.stopDaemon()
        NSApp.terminate(nil)
    }
}

// Basic settings panel for shortcut customization.
private struct ShortcutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mnemonic Settings")
                .font(.headline)
            Text("Open Dashboard Shortcut")
                .font(.subheadline)
            KeyboardShortcuts.Recorder(for: .openDashboard)
        }
    }
}
