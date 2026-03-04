import SwiftUI

// Menu content shown inside MenuBarExtra.
struct ContentView: View {
    let currentProjectName: String
    let onOpenDashboard: () -> Void
    let onOpenSettings: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Project: \(currentProjectName)")
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Button("Dashboard 열기", action: onOpenDashboard)
            Divider()
            Button("설정", action: onOpenSettings)
            Button("종료", action: onQuit)
        }
        .frame(minWidth: 220)
    }
}
