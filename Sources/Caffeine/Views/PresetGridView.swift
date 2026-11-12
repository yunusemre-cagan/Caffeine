import SwiftUI

struct PresetGridView: View {
    @ObservedObject var manager: CaffeineManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(CaffeineManager.defaultPresets) { preset in
                PresetCard(
                    preset: preset,
                    isSelected: manager.isActive && manager.activePresetId == preset.id
                ) {
                    withAnimation(Theme.spring) { manager.startPreset(preset) }
                }
            }
        }
    }
}

private struct PresetCard: View {
    let preset: PresetOption
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(Theme.amber))
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(isSelected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.amber.opacity(0.14)))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.title)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(preset.subtitle)
                        .font(.system(size: 9.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .frame(height: 56)
            .surface(
                radius: 14,
                fill: isSelected ? Theme.amber.opacity(0.14) : Color.primary.opacity(hovered ? 0.085 : 0.045),
                stroke: isSelected ? Theme.amber.opacity(0.7) : Color.primary.opacity(hovered ? 0.14 : 0.07)
            )
            .offset(y: hovered && !isSelected ? -1 : 0)
        }
        .buttonStyle(PressableStyle())
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
        .animation(Theme.spring, value: isSelected)
    }
}
