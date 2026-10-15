import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: CaffeineManager
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("Ayarlar ve Tercihler")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 12) {
                    // Prevent Display Sleep Toggle
                    ToggleRow(
                        icon: "display",
                        title: "Ekranı da Açık Tut",
                        subtitle: manager.preventDisplaySleep 
                            ? "Ekran kararmayacak ve kapanmayacak" 
                            : "Sadece CPU uyanık tutulur, ekran kararabilir",
                        isOn: $manager.preventDisplaySleep
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                    
                    // Show Time in Menu Bar Toggle
                    ToggleRow(
                        icon: "menubar.arrow.up.rectangle",
                        title: "Menü Çubuğunda Süreyi Göster",
                        subtitle: "Kalan süreyi menü simgesinin yanında gösterir",
                        isOn: $manager.showTimeInMenuBar
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                    
                    // Sound on Finish Toggle
                    ToggleRow(
                        icon: "speaker.wave.2",
                        title: "Süre Dolduğunda Ses Çal",
                        subtitle: "Zamanlayıcı bittiğinde hoş bir ses uyarısı verir",
                        isOn: $manager.playSoundOnFinish
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                    
                    // Notification on Finish Toggle
                    ToggleRow(
                        icon: "bell.badge",
                        title: "Bildirim Gönder",
                        subtitle: "Süre bitiminde sistem bildirimi ile haber verir",
                        isOn: $manager.sendNotificationOnFinish
                    )
                    
                    Divider()
                        .padding(.horizontal, 4)
                    
                    // Show in Dock Toggle
                    ToggleRow(
                        icon: "dock.rectangle",
                        title: "Dock'ta Göster",
                        subtitle: "Uygulama simgesini macOS Dock alanında gösterir",
                        isOn: $manager.showInDock
                    )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 18)
                .padding(.top, 2)
            
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
                .controlSize(.small)
        }
    }
}
