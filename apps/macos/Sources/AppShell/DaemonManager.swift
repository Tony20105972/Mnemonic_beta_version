import Foundation
import OSLog

// Manages the Rust daemon (mnmd) lifecycle for the macOS AppShell.
final class DaemonManager: ObservableObject {
    private let logger = Logger(subsystem: "com.mnemonic.appshell", category: "daemon")
    private var daemonProcess: Process?

    func startDaemonIfNeeded() {
        guard daemonProcess == nil else {
            logger.debug("Daemon already running")
            return
        }

        let daemonURL = resolveDaemonURL()
        guard FileManager.default.isExecutableFile(atPath: daemonURL.path) else {
            logger.error("mnmd is not executable: \(daemonURL.path, privacy: .public)")
            return
        }

        let process = Process()
        process.executableURL = daemonURL
        process.arguments = []

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        process.terminationHandler = { [weak self] proc in
            self?.logger.error("mnmd terminated with status \(proc.terminationStatus)")
            DispatchQueue.main.async {
                self?.daemonProcess = nil
            }
        }

        do {
            try process.run()
            daemonProcess = process
            logger.info("Started mnmd from \(daemonURL.path, privacy: .public)")
        } catch {
            logger.error("Failed to start mnmd: \(error.localizedDescription, privacy: .public)")
        }
    }

    func stopDaemon() {
        guard let process = daemonProcess else { return }

        if process.isRunning {
            process.terminate()
            logger.info("Sent terminate signal to mnmd")
        }

        daemonProcess = nil
    }

    private func resolveDaemonURL() -> URL {
        if let bundled = Bundle.main.url(forResource: "mnmd", withExtension: nil) {
            return bundled
        }
        return URL(fileURLWithPath: "/usr/local/bin/mnmd")
    }
}
