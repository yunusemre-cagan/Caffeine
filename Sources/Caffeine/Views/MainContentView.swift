import SwiftUI
import AppKit

struct MainContentView: View {
    @ObservedObject var manager: CaffeineManager
    var isStandaloneWindow: Bool = false
    @Environment(\.openWindow) private var openWindow
    
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
                        
                        Text("v1.0")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
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
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Ayrı pencerede aç")
                    }
                    
                    // Quit Button
                    Button(action: {
                        manager.stop()
                        NSApp.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
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
                
                // Footer
                HStack {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text("macOS IOKit ile yerel ve güvenli güç yönetimi")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Çıkış Yap") {
                        manager.stop()
                        NSApp.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                .padding(.bottom, 8)
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
