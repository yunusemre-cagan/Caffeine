import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: CaffeineManager
    @State private var isExpanded: Bool = false
    @State private var isHeaderHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isExpanded ? .orange : .secondary)
                    
                    Text("Ayarlar ve Tercihler")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isHeaderHovered ? Color.primary.opacity(0.04) : Color.clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHeaderHovered = $0 }
            
            if isExpanded {
                VStack(spacing: 8) {
                    // Prevent Display Sleep Toggle
                    ToggleRow(
                        icon: "display",
                        title: "Ekranı da Açık Tut",
                        subtitle: "Ekranın kararmasını ve sistemin uykuya geçmesini engeller",
                        isOn: $manager.preventDisplaySleep
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                        .opacity(0.6)
                    
                    // Show Time in Menu Bar Toggle
                    ToggleRow(
                        icon: "menubar.arrow.up.rectangle",
                        title: "Menü Çubuğunda Süreyi Göster",
                        subtitle: "Kalan süreyi menü simgesinin yanında gösterir",
                        isOn: $manager.showTimeInMenuBar
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                        .opacity(0.6)
                    
                    // Sound on Finish Toggle
                    ToggleRow(
                        icon: "speaker.wave.2",
                        title: "Süre Dolduğunda Ses Çal",
                        subtitle: "Zamanlayıcı bittiğinde hoş bir ses uyarısı verir",
                        isOn: $manager.playSoundOnFinish
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                        .opacity(0.6)
                    
                    // Notification on Finish Toggle
                    ToggleRow(
                        icon: "bell.badge",
                        title: "Bildirim Gönder",
                        subtitle: "Süre bitiminde sistem bildirimi ile haber verir",
                        isOn: $manager.sendNotificationOnFinish
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                        .opacity(0.6)
                    
                    // Show in Dock Toggle
                    ToggleRow(
                        icon: "dock.rectangle",
                        title: "Dock'ta Göster",
                        subtitle: "Uygulama simgesini macOS Dock alanında gösterir",
                        isOn: $manager.showInDock
                    )
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
                .clipped()
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                        removal: .opacity
                    )
                )
            }
        }
        .clipped()
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.snappy(duration: 0.2)) {
                isOn.toggle()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.orange)
                    .controlSize(.small)
                    .allowsHitTesting(false)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.05) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
