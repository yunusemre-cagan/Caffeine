import SwiftUI
import AppKit

// MARK: - Design Tokens

enum Theme {
    /// 16:9 içerik boyutu
    static let size = CGSize(width: 800, height: 450)

    static let amber = Color(red: 1.00, green: 0.62, blue: 0.20)
    static let ember = Color(red: 0.98, green: 0.38, blue: 0.14)
    static let mint = Color(red: 0.25, green: 0.80, blue: 0.55)

    static var accentGradient: LinearGradient {
        LinearGradient(colors: [amber, ember], startPoint: .top, endPoint: .bottom)
    }

    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let quick = Animation.easeOut(duration: 0.16)
}

// MARK: - Surfaces

extension View {
    /// Yumuşak, ince çerçeveli kart yüzeyi.
    func surface(radius: CGFloat = 14, fill: Color = Color.primary.opacity(0.045), stroke: Color = Color.primary.opacity(0.07)) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(stroke, lineWidth: 1)
                )
        )
    }
}

/// Basılınca hafifçe küçülen, hover'da parlayan buton stili.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Başlık çubuğunu gizlenmiş pencerede arka plandan sürüklemeyi açar.
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.standardWindowButton(.zoomButton)?.isEnabled = false
        }
    }
}

/// Küçük, ikonlu yuvarlak köşeli ikon butonu (başlık çubuğu için).
struct IconButton: View {
    let systemName: String
    var tint: Color = .secondary
    var hoverTint: Color = .primary
    let help: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hovered ? hoverTint : tint)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hoverTint.opacity(hovered ? 0.12 : 0))
                )
        }
        .buttonStyle(PressableStyle(scale: 0.92))
        .onHover { hovered = $0 }
        .animation(Theme.quick, value: hovered)
        .help(help)
    }
}
