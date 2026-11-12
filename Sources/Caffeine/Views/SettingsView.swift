import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: CaffeineManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            SettingTile(
                icon: "display",
                title: "Ekranı Açık Tut",
                subtitle: "Ekran kararmaz, sistem uykuya geçmez",
                isOn: $manager.preventDisplaySleep
            )
            SettingTile(
                icon: "menubar.arrow.up.rectangle",
                title: "Menüde Süreyi Göster",
                subtitle: "Kalan süre menü simgesinin yanında",
                isOn: $manager.showTimeInMenuBar
            )
            SettingTile(
                icon: "speaker.wave.2",
                title: "Bitişte Ses Çal",
                subtitle: "Süre dolunca kısa bir uyarı sesi",
                isOn: $manager.playSoundOnFinish
            )
            SettingTile(
                icon: "bell.badge",
                title: "Bildirim Gönder",
                subtitle: "Süre bitiminde sistem bildirimi",
                isOn: $manager.sendNotificationOnFinish
            )
            SettingTile(
                icon: "rays",
                title: "Girişte Başlat",
                subtitle: "Mac açılınca menü çubuğunda hazır",
                isOn: $manager.launchAtLogin
            )
            SettingTile(
                icon: "dock.rectangle",
                title: "Yalnız Açıkken Dock'ta",
                subtitle: "Pasifken Dock'tan gizlenir",
                isOn: $manager.showInDock
            )
        }
    }
}

private struct SettingTile: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @State private var hovered = false

    var body: some View {
        Button {
            withAnimation(Theme.spring) { isOn.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isOn ? AnyShapeStyle(.white) : AnyShapeStyle(Color.secondary))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(isOn ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.primary.opacity(0.07)))
                        )

                    Spacer()

                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(Theme.amber)
                        .controlSize(.small)
                        .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .surface(
                radius: 16,
                fill: isOn ? Theme.amber.opacity(0.09) : Color.primary.opacity(hovered ? 0.075 : 0.04),
                stroke: isOn ? Theme.amber.opacity(0.35) : Color.primary.opacity(hovered ? 0.13 : 0.07)
            )
        }
        .buttonStyle(PressableStyle(scale: 0.985))
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
    }
}
