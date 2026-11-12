import SwiftUI

struct StatusHeroView: View {
    @ObservedObject var manager: CaffeineManager
    @State private var breathe = false

    private let ringSize: CGFloat = 188

    var body: some View {
        VStack(spacing: 16) {
            statusPill

            ring

            actionButton

            quickAdd
                .frame(height: 26)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 18)
        .frame(maxHeight: .infinity)
        .surface(
            radius: 20,
            fill: Color.primary.opacity(0.04),
            stroke: manager.isActive ? Theme.amber.opacity(0.35) : Color.primary.opacity(0.07)
        )
        .animation(.easeInOut(duration: 0.5), value: manager.isActive)
        .onAppear { breathe = true }
    }

    // MARK: Status

    private var statusPill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(manager.isActive ? Theme.mint : Color.secondary.opacity(0.5))
                .frame(width: 7, height: 7)
                .overlay(
                    Circle()
                        .stroke(Theme.mint.opacity(0.5), lineWidth: 2)
                        .scaleEffect(manager.isActive && breathe ? 2.0 : 1.0)
                        .opacity(manager.isActive && breathe ? 0 : 0.8)
                        .animation(
                            manager.isActive ? .easeOut(duration: 1.6).repeatForever(autoreverses: false) : .default,
                            value: breathe
                        )
                )

            Text(statusText)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(manager.isActive ? Theme.mint : .secondary)
                .contentTransition(.opacity)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(manager.isActive ? Theme.mint.opacity(0.13) : Color.primary.opacity(0.06))
        )
    }

    private var statusText: String {
        guard manager.isActive else { return "UYKU MODU" }
        return manager.isIndefinite ? "SÜRESİZ AKTİF" : "SİSTEM UYANIK"
    }

    // MARK: Ring

    private var ring: some View {
        ZStack {
            // Yumuşak nefes alan hale
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.amber.opacity(0.30), .clear],
                        center: .center, startRadius: 20, endRadius: ringSize * 0.75
                    )
                )
                .frame(width: ringSize * 1.4, height: ringSize * 1.4)
                .scaleEffect(breathe ? 1.06 : 0.94)
                .opacity(manager.isActive ? 1 : 0)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: breathe)
                .animation(.easeInOut(duration: 0.6), value: manager.isActive)

            Circle()
                .stroke(Color.primary.opacity(0.07), lineWidth: 8)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: manager.progress)
                .stroke(
                    AngularGradient(
                        colors: [Theme.ember, Theme.amber, Theme.amber],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: ringSize, height: ringSize)
                .opacity(manager.isActive ? 1 : 0)
                .animation(.easeInOut(duration: 0.9), value: manager.progress)
                .animation(.easeOut(duration: 0.3), value: manager.isActive)

            VStack(spacing: 6) {
                Image(systemName: manager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(manager.isActive ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.secondary))
                    .offset(y: manager.isActive && breathe ? -1.5 : 1.5)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: breathe)

                if manager.isActive && manager.isIndefinite {
                    Image(systemName: "infinity")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .transition(.opacity)
                } else {
                    Text(manager.formattedRemainingTime)
                        .font(.system(size: 29, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(manager.isActive ? .primary : .tertiary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.snappy, value: manager.remainingSeconds)
                }

                Text(manager.formattedTargetTime)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
            .frame(width: ringSize - 28)
        }
        .frame(height: ringSize + 8)
    }

    // MARK: Action

    private var actionButton: some View {
        Button {
            withAnimation(Theme.spring) { manager.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: manager.isActive ? "stop.fill" : "play.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(manager.isActive ? "Durdur" : "Uyanık Tut")
                    .font(.system(size: 13.5, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        manager.isActive
                            ? LinearGradient(colors: [Color.red.opacity(0.85), Color.red], startPoint: .top, endPoint: .bottom)
                            : Theme.accentGradient
                    )
            )
            .shadow(color: (manager.isActive ? Color.red : Theme.ember).opacity(0.3), radius: 8, y: 3)
        }
        .buttonStyle(PressableStyle())
        .keyboardShortcut(.space, modifiers: [])
    }

    // MARK: Quick add

    @ViewBuilder
    private var quickAdd: some View {
        if manager.isActive && !manager.isIndefinite {
            HStack(spacing: 6) {
                QuickAddButton(title: "+15 dk", seconds: 15 * 60, manager: manager)
                QuickAddButton(title: "+30 dk", seconds: 30 * 60, manager: manager)
                QuickAddButton(title: "+1 sa", seconds: 60 * 60, manager: manager)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            Color.clear
        }
    }
}

private struct QuickAddButton: View {
    let title: String
    let seconds: TimeInterval
    @ObservedObject var manager: CaffeineManager
    @State private var hovered = false

    var body: some View {
        Button {
            withAnimation(Theme.spring) { manager.addExtraTime(seconds: seconds) }
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(hovered ? Theme.amber : Color.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(hovered ? Theme.amber.opacity(0.18) : Color.primary.opacity(0.07)))
        }
        .buttonStyle(PressableStyle(scale: 0.94))
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
    }
}
