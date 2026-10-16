import SwiftUI
import AppKit

struct MainContentView: View {
    @ObservedObject var manager: CaffeineManager
    var isStandaloneWindow: Bool = false
    @Environment(\.openWindow) private var openWindow
    
    @State private var isDetachHovered: Bool = false
    @State private var isQuitHovered: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Top App Bar
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, Color(red: 1.0, green: 0.4, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("Caffeine")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Standalone Window / Detach Button
                    if !isStandaloneWindow {
                        Button(action: {
                            openWindow(id: "main-window")
                            NSApp.activate(ignoringOtherApps: true)
                        }) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isDetachHovered ? .primary : .secondary)
                                .frame(width: 24, height: 24)
                                .background(Color.primary.opacity(isDetachHovered ? 0.08 : 0.0))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .onHover { isDetachHovered = $0 }
                        .help("Ayrı pencerede aç")
                    }
                    
                    // Quit Button
                    Button(action: {
                        manager.stop()
                        NSApp.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isQuitHovered ? .red : .red.opacity(0.85))
                            .frame(width: 24, height: 24)
                            .background(Color.red.opacity(isQuitHovered ? 0.12 : 0.0))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .onHover { isQuitHovered = $0 }
                    .help("Caffeine'den çıkış yap")
                }
                .padding(.horizontal, 4)
                
                // Hero Status Card with Coffee Cup & Timer
                StatusHeroView(manager: manager)
                
                // Presets Grid (30dk, 1sa, 2sa, 5sa, 8sa, Süresiz)
                PresetGridView(manager: manager)
                
                // Custom Duration (Hours, Minutes, Quick chips, Start)
                CustomDurationView(manager: manager)
                
                // Settings & Preferences (Display sleep, notifications, etc.)
                SettingsView(manager: manager)
                
                // Minimal Footer with Caffeine & Version
                VStack(spacing: 8) {
                    Divider()
                        .opacity(0.3)
                        .padding(.horizontal, 2)
                    
                    HStack(alignment: .center) {
                        HStack(spacing: 5) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 9.5))
                                .foregroundColor(.secondary.opacity(0.7))
                            
                            Text("macOS IOKit ile yerel güç yönetimi")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.75))
                        }
                        
                        Spacer()
                        
                        Text("Caffeine v1.0")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                }
            }
            .padding(16)
        }
        .frame(minWidth: 350, idealWidth: 360, maxWidth: 420)
        .frame(minHeight: 520, idealHeight: 580)
        .background(
            Color(nsColor: .windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
        )
    }
}
