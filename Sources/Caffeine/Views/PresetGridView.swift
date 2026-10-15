import SwiftUI

struct PresetGridView: View {
    @ObservedObject var manager: CaffeineManager
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Hazır Süreler")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Hızlı Başlat")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(CaffeineManager.defaultPresets) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: manager.isActive && manager.activePresetId == preset.id,
                        onSelect: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                manager.startPreset(preset)
                            }
                        }
                    )
                }
            }
        }
    }
}

private struct PresetCard: View {
    let preset: PresetOption
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: preset.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? .orange : (isHovered ? .primary : .secondary))
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
                
                Text(preset.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .orange : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                
                Text(preset.subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        isSelected 
                            ? Color.orange.opacity(0.12)
                            : (isHovered ? Color.primary.opacity(0.06) : Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                isSelected 
                                    ? Color.orange.opacity(0.8) 
                                    : (isHovered ? Color.primary.opacity(0.15) : Color.primary.opacity(0.06)),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovered)
    }
}
