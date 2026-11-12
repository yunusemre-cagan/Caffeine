import SwiftUI

struct CustomDurationView: View {
    @ObservedObject var manager: CaffeineManager

    private var totalMinutes: Int { manager.customHours * 60 + manager.customMinutes }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.amber)
                Text("Özel Süre")
                    .font(.system(size: 12.5, weight: .semibold))
                Spacer()
                Button("Sıfırla", action: resetCustom)
                    .buttonStyle(.plain)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                TimeStepper(title: "Saat", value: $manager.customHours, range: 0...48, step: 1, unit: "sa")
                TimeStepper(title: "Dakika", value: $manager.customMinutes, range: 0...59, step: 5, unit: "dk")
            }

            HStack(spacing: 6) {
                Chip(title: "+15 dk") { addMinutes(15) }
                Chip(title: "+30 dk") { addMinutes(30) }
                Chip(title: "+1 sa") { addHours(1) }
                Chip(title: "+2 sa") { addHours(2) }

                Spacer(minLength: 6)

                startButton
            }
        }
        .padding(14)
        .frame(maxHeight: .infinity, alignment: .top)
        .surface(radius: 16)
    }

    private var startButton: some View {
        let enabled = totalMinutes > 0
        return Button {
            withAnimation(Theme.spring) { manager.startCustom() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill").font(.system(size: 10))
                Text(enabled ? "Başlat · \(summary)" : "Süre seçin")
                    .font(.system(size: 11.5, weight: .semibold))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(enabled ? Color.white : Color.secondary)
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(
                Capsule().fill(enabled ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.primary.opacity(0.08)))
            )
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
        .animation(Theme.quick, value: totalMinutes)
    }

    private var summary: String {
        let h = manager.customHours, m = manager.customMinutes
        if h > 0 && m > 0 { return "\(h)sa \(m)dk" }
        return h > 0 ? "\(h)sa" : "\(m)dk"
    }

    private func addMinutes(_ mins: Int) {
        withAnimation(Theme.quick) {
            let total = manager.customMinutes + mins
            manager.customHours = min(48, manager.customHours + total / 60)
            manager.customMinutes = total % 60
        }
    }

    private func addHours(_ hrs: Int) {
        withAnimation(Theme.quick) { manager.customHours = min(48, manager.customHours + hrs) }
    }

    private func resetCustom() {
        withAnimation(Theme.quick) {
            manager.customHours = 0
            manager.customMinutes = 30
        }
    }
}

private struct TimeStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String

    var body: some View {
        HStack(spacing: 0) {
            StepButton(systemName: "minus", disabled: value <= range.lowerBound) {
                withAnimation(Theme.quick) { value = max(range.lowerBound, value - step) }
            }

            VStack(spacing: 1) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(title)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            StepButton(systemName: "plus", disabled: value >= range.upperBound) {
                withAnimation(Theme.quick) { value = min(range.upperBound, value + step) }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .surface(radius: 12, fill: Color.primary.opacity(0.04), stroke: Color.primary.opacity(0.05))
    }
}

private struct StepButton: View {
    let systemName: String
    let disabled: Bool
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(hovered ? Theme.amber : Color.primary)
                .frame(width: 26, height: 26)
                .background(Circle().fill(hovered ? Theme.amber.opacity(0.16) : Color.primary.opacity(0.07)))
        }
        .buttonStyle(PressableStyle(scale: 0.88))
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
    }
}

private struct Chip: View {
    let title: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                .foregroundStyle(hovered ? Theme.amber : Color.primary)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background(Capsule().fill(hovered ? Theme.amber.opacity(0.16) : Color.primary.opacity(0.06)))
        }
        .buttonStyle(PressableStyle(scale: 0.94))
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
    }
}
