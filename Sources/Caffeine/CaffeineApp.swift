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
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        // macOS Menü Çubuğu Öğesi (Status Item & Popover)
        MenuBarExtra {
            MainContentView(manager: manager, isStandaloneWindow: false)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: manager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                
                if manager.isActive && manager.showTimeInMenuBar {
                    let display = manager.menuBarDisplayString
                    if !display.isEmpty {
                        Text(display)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
