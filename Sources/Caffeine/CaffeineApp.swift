import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Pencere kapatılsa bile menü çubuğunda arka planda çalışmaya devam et
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                if window.title == "Caffeine" {
                    window.makeKeyAndOrderFront(nil)
                    sender.activate(ignoringOtherApps: true)
                    return true
                }
            }
        }
        return true
    }
}

@main
struct CaffeineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var manager = CaffeineManager.shared
    
    var body: some Scene {
        // Ana Bağımsız Pencere
        Window("Caffeine", id: "main-window") {
            MainContentView(manager: manager, isStandaloneWindow: true)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        // macOS Menü Çubuğu Öğesi (Status Item & Popover)
        MenuBarExtra {
            MainContentView(manager: manager, isStandaloneWindow: false)
                .onOpenURL { url in
                    handleURL(url)
                }
        } label: {
            HStack(spacing: 5) {
                if manager.isActive && manager.showTimeInMenuBar {
                    let display = manager.menuBarDisplayString
                    if !display.isEmpty {
                        Text(display)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                }
                
                Image(systemName: manager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private func handleURL(_ url: URL) {
        let action = url.host ?? url.pathComponents.dropFirst().first ?? ""
        switch action {
        case "toggle":
            manager.toggle()
        case "start":
            manager.start(duration: 3600, presetId: "1h")
        case "stop":
            manager.stop()
        default:
            break
        }
    }
}
