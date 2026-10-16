import SwiftUI

struct StatusHeroView: View {
    @ObservedObject var manager: CaffeineManager
    @State private var isPulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Animated Icon + Ring
            ZStack {
                // Background Glow when active
                if manager.isActive {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.35),
                                    Color.orange.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 75
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(isPulsing ? 1.12 : 0.95)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isPulsing)
                }
                
                // Progress Circle
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 6)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: 0, to: manager.progress)
                    .stroke(
                        LinearGradient(
                            colors: manager.isActive 
                                ? [Color.orange, Color.yellow] 
                                : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 110, height: 110)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.progress)
                
                // Center Icon with Coffee Steam Effect
                VStack(spacing: 2) {
                    if manager.isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.orange.opacity(0.8))
                                .frame(width: 4, height: 4)
                                .offset(y: isPulsing ? -6 : -2)
                            Circle()
                                .fill(Color.orange.opacity(0.9))
                                .frame(width: 5, height: 5)
                                .offset(y: isPulsing ? -8 : -3)
                            Circle()
                                .fill(Color.orange.opacity(0.7))
                                .frame(width: 4, height: 4)
                                .offset(y: isPulsing ? -5 : -1)
                        }
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
                    }
                    
                    Image(systemName: manager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(
                            manager.isActive 
                                ? LinearGradient(colors: [.orange, Color(red: 1.0, green: 0.4, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [.secondary, .secondary.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: manager.isActive ? Color.orange.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 3)
                }
            }
            .padding(.top, 4)
            .onAppear {
                isPulsing = true
            }
            
            // Status Badge & Timer Text
            VStack(spacing: 6) {
                // Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(manager.isActive ? Color.green : Color.gray.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(manager.isActive && isPulsing ? 1.25 : 1.0)
                        .animation(manager.isActive ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isPulsing)
                    
                    Text(manager.isActive ? (manager.isIndefinite ? "SÜRESİZ AKTİF" : "SİSTEM UYANIK") : "UYKU MODU (PASİF)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(manager.isActive ? .green : .secondary)
                        .tracking(1.0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(manager.isActive ? Color.green.opacity(0.12) : Color.primary.opacity(0.05))
                )
                
                // Big Countdown Digits
                Text(manager.formattedRemainingTime)
                    .font(.system(size: 36, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: manager.remainingSeconds)
                
                // Subtitle / Target finish time
                Text(manager.formattedTargetTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Main Action Button (Start / Stop)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    manager.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: manager.isActive ? "stop.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(manager.isActive ? "Uyanık Tutmayı Durdur" : "Sistemi Uyanık Tut")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            manager.isActive
                                ? LinearGradient(colors: [Color.red.opacity(0.9), Color.red], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.orange, Color(red: 0.95, green: 0.45, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .shadow(
                    color: manager.isActive ? Color.red.opacity(0.3) : Color.orange.opacity(0.35),
                    radius: 5,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(.plain)
            
            // Quick Add Pills (+15dk, +30dk, +1sa) when active
            if manager.isActive && !manager.isIndefinite {
                HStack(spacing: 8) {
                    Text("+ Süre Ekle:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    QuickAddButton(title: "+15 dk", seconds: 15 * 60, manager: manager)
                    QuickAddButton(title: "+30 dk", seconds: 30 * 60, manager: manager)
                    QuickAddButton(title: "+1 sa", seconds: 60 * 60, manager: manager)
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    )
                )
            }
        }
        .clipped()
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            manager.isActive 
                                ? Color.orange.opacity(0.3) 
                                : Color.primary.opacity(0.08), 
                            lineWidth: 1
                        )
                )
        )
    }
}

private struct QuickAddButton: View {
    let title: String
    let seconds: TimeInterval
    @ObservedObject var manager: CaffeineManager
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                manager.addExtraTime(seconds: seconds)
            }
        }) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isHovered ? Color.orange.opacity(0.2) : Color.primary.opacity(0.06))
                )
                .foregroundColor(isHovered ? .orange : .primary)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
