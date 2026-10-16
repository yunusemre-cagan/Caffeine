import SwiftUI

struct CustomDurationView: View {
    @ObservedObject var manager: CaffeineManager
    @State private var isExpanded: Bool = true
    @State private var isHeaderHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.orange)
                    
                    Text("Özel Süre Belirle")
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
                VStack(spacing: 12) {
                    // Hour & Minute Stepper Cards
                    HStack(spacing: 10) {
                        // Hour Stepper
                        TimeStepperCard(
                            title: "Saat",
                            value: $manager.customHours,
                            range: 0...48,
                            step: 1,
                            unit: "saat"
                        )
                        
                        // Minute Stepper
                        TimeStepperCard(
                            title: "Dakika",
                            value: $manager.customMinutes,
                            range: 0...59,
                            step: 5,
                            unit: "dk"
                        )
                    }
                    
                    // Quick duration pill buttons
                    HStack(spacing: 6) {
                        QuickDurationChip(title: "+15 dk", action: { addMinutes(15) })
                        QuickDurationChip(title: "+30 dk", action: { addMinutes(30) })
                        QuickDurationChip(title: "+1 sa", action: { addHours(1) })
                        QuickDurationChip(title: "+2 sa", action: { addHours(2) })
                        
                        Spacer()
                        
                        Button(action: resetCustom) {
                            Text("Sıfırla")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Custom Start Button
                    let totalMinutes = (manager.customHours * 60) + manager.customMinutes
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            manager.startCustom()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 11))
                            Text(totalMinutes > 0 
                                 ? "Özel Süreyi Başlat (\(formatSummary(hours: manager.customHours, minutes: manager.customMinutes)))" 
                                 : "Bir Süre Belirleyin")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .foregroundColor(totalMinutes > 0 ? .white : .secondary)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    totalMinutes > 0 
                                        ? Color.orange 
                                        : Color.primary.opacity(0.08)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(totalMinutes <= 0)
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
    
    private func addMinutes(_ mins: Int) {
        let total = manager.customMinutes + mins
        if total >= 60 {
            manager.customHours = min(48, manager.customHours + (total / 60))
            manager.customMinutes = total % 60
        } else {
            manager.customMinutes = total
        }
    }
    
    private func addHours(_ hrs: Int) {
        manager.customHours = min(48, manager.customHours + hrs)
    }
    
    private func resetCustom() {
        manager.customHours = 0
        manager.customMinutes = 30
    }
    
    private func formatSummary(hours: Int, minutes: Int) -> String {
        if hours > 0 && minutes > 0 {
            return "\(hours) saat \(minutes) dk"
        } else if hours > 0 {
            return "\(hours) saat"
        } else {
            return "\(minutes) dk"
        }
    }
}

private struct TimeStepperCard: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Minus button
                Button(action: {
                    if value - step >= range.lowerBound {
                        value -= step
                    } else {
                        value = range.lowerBound
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.primary.opacity(0.07))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(value <= range.lowerBound)
                
                // Display Value
                Text("\(value) \(unit)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .frame(minWidth: 54)
                
                // Plus button
                Button(action: {
                    if value + step <= range.upperBound {
                        value += step
                    } else {
                        value = range.upperBound
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.primary.opacity(0.07))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(value >= range.upperBound)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        )
    }
}

private struct QuickDurationChip: View {
    let title: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isHovered ? Color.orange.opacity(0.18) : Color.primary.opacity(0.05))
                )
                .foregroundColor(isHovered ? .orange : .primary)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
