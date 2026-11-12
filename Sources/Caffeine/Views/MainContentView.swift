import SwiftUI
import AppKit

private enum Tab: String, CaseIterable, Identifiable {
    case durations = "Süreler"
    case settings = "Ayarlar"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .durations: return "timer"
        case .settings: return "slider.horizontal.3"
        }
    }
}

struct MainContentView: View {
    @ObservedObject var manager: CaffeineManager
    var isStandaloneWindow: Bool = false
    @Environment(\.openWindow) private var openWindow

    @State private var tab: Tab = .durations
    @Namespace private var tabNamespace

    var body: some View {
        ZStack {
            AmbientBackground(isActive: manager.isActive)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, isStandaloneWindow ? 12 : 14)
                    .padding(.bottom, 10)

                HStack(alignment: .top, spacing: 16) {
                    StatusHeroView(manager: manager)
                        .frame(width: 290)

                    VStack(spacing: 14) {
                        tabBar

                        ZStack {
                            if tab == .durations {
                                VStack(spacing: 14) {
                                    PresetGridView(manager: manager)
                                    CustomDurationView(manager: manager)
                                }
                                .transition(.opacity.combined(with: .offset(x: -12)))
                            } else {
                                SettingsView(manager: manager)
                                    .transition(.opacity.combined(with: .offset(x: 12)))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            if isStandaloneWindow {
                WindowConfigurator().frame(width: 0, height: 0)
            }
        }
        .frame(width: Theme.size.width, height: Theme.size.height)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            // Başlık çubuğu gizli olduğundan trafik ışıkları için boşluk bırak
            if isStandaloneWindow {
                Spacer().frame(width: 62)
            }

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.accentGradient)

            Text("Caffeine")
                .font(.system(size: 15, weight: .bold, design: .rounded))

            Text("v1.1")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.primary.opacity(0.06)))

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 10))
                Text("IOKit güç yönetimi")
                    .font(.system(size: 10.5, weight: .medium))
            }
            .foregroundStyle(.tertiary)
            .padding(.trailing, 6)

            if !isStandaloneWindow {
                IconButton(systemName: "arrow.up.right.square", help: "Ayrı pencerede aç") {
                    openWindow(id: "main-window")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }

            IconButton(systemName: "power", tint: .red.opacity(0.8), hoverTint: .red, help: "Caffeine'den çıkış yap") {
                manager.stop()
                NSApp.terminate(nil)
            }
        }
    }

    // MARK: Tab Bar

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases) { item in
                Button {
                    withAnimation(Theme.spring) { tab = item }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(item.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(tab == item ? Color.primary : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background {
                        if tab == item {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                                .matchedGeometryEffect(id: "tab", in: tabNamespace)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle(scale: 0.98))
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
    }
}

// MARK: - Background

private struct AmbientBackground: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            RadialGradient(
                colors: [Theme.amber.opacity(isActive ? 0.20 : 0.05), .clear],
                center: .init(x: 0.14, y: 0.35),
                startRadius: 0,
                endRadius: 380
            )

            RadialGradient(
                colors: [Theme.ember.opacity(isActive ? 0.10 : 0.02), .clear],
                center: .init(x: 0.95, y: 1.0),
                startRadius: 0,
                endRadius: 320
            )
        }
        .animation(.easeInOut(duration: 0.8), value: isActive)
        .ignoresSafeArea()
    }
}
