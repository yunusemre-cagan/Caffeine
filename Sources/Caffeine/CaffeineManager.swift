import Foundation
import Combine
import AppKit
import IOKit.pwr_mgt
import UserNotifications
import ServiceManagement

public struct PresetOption: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String
    public let duration: TimeInterval // 0 for indefinite
    
    public init(id: String, title: String, subtitle: String, icon: String, duration: TimeInterval) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.duration = duration
    }
}

@MainActor
public final class CaffeineManager: ObservableObject {
    public static let shared = CaffeineManager()
    
    // Available Presets
    public static let defaultPresets: [PresetOption] = [
        PresetOption(id: "30m", title: "30 Dakika", subtitle: "Kısa çalışma", icon: "timer", duration: 30 * 60),
        PresetOption(id: "1h", title: "1 Saat", subtitle: "Odaklanma", icon: "hourglass", duration: 60 * 60),
        PresetOption(id: "2h", title: "2 Saat", subtitle: "Toplantı / Kodlama", icon: "clock.badge.checkmark", duration: 2 * 60 * 60),
        PresetOption(id: "5h", title: "5 Saat", subtitle: "Uzun görevler", icon: "flame.fill", duration: 5 * 60 * 60),
        PresetOption(id: "8h", title: "8 Saat", subtitle: "Tam mesai", icon: "briefcase.fill", duration: 8 * 60 * 60),
        PresetOption(id: "inf", title: "Süresiz", subtitle: "Durdurana kadar", icon: "infinity", duration: 0)
    ]
    
    // Reactive States
    @Published public private(set) var isActive: Bool = false
    @Published public private(set) var isIndefinite: Bool = false
    @Published public private(set) var remainingSeconds: TimeInterval = 0
    @Published public private(set) var totalSeconds: TimeInterval = 0
    @Published public private(set) var targetDate: Date? = nil
    @Published public private(set) var activePresetId: String? = nil
    
    // Custom Time Selection
    @Published public var customHours: Int = 1
    @Published public var customMinutes: Int = 30
    
    // User Settings (Stored in UserDefaults)
    @Published public var preventDisplaySleep: Bool {
        didSet {
            UserDefaults.standard.set(preventDisplaySleep, forKey: "caffeine_preventDisplaySleep")
            if isActive {
                recreateAssertion()
            }
        }
    }
    
    @Published public var showTimeInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showTimeInMenuBar, forKey: "caffeine_showTimeInMenuBar")
        }
    }
    
    @Published public var playSoundOnFinish: Bool {
        didSet {
            UserDefaults.standard.set(playSoundOnFinish, forKey: "caffeine_playSoundOnFinish")
        }
    }
    
    @Published public var sendNotificationOnFinish: Bool {
        didSet {
            UserDefaults.standard.set(sendNotificationOnFinish, forKey: "caffeine_sendNotificationOnFinish")
        }
    }
    
    @Published public var showInDock: Bool {
        didSet {
            UserDefaults.standard.set(showInDock, forKey: "caffeine_showInDock")
            updateDockPolicy()
        }
    }
    
    @Published public var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "caffeine_launchAtLogin")
            updateLaunchAtLogin()
        }
    }
    
    // Internal Power Assertion
    private var assertionID: IOPMAssertionID = 0
    private var timerCancellable: AnyCancellable?
    
    public init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "caffeine_preventDisplaySleep") == nil {
            defaults.set(true, forKey: "caffeine_preventDisplaySleep")
        }
        if defaults.object(forKey: "caffeine_showTimeInMenuBar") == nil {
            defaults.set(true, forKey: "caffeine_showTimeInMenuBar")
        }
        if defaults.object(forKey: "caffeine_playSoundOnFinish") == nil {
            defaults.set(true, forKey: "caffeine_playSoundOnFinish")
        }
        if defaults.object(forKey: "caffeine_sendNotificationOnFinish") == nil {
            defaults.set(true, forKey: "caffeine_sendNotificationOnFinish")
        }
        if defaults.object(forKey: "caffeine_showInDock") == nil {
            defaults.set(true, forKey: "caffeine_showInDock")
        }
        if defaults.object(forKey: "caffeine_launchAtLogin") == nil {
            defaults.set(true, forKey: "caffeine_launchAtLogin")
        }
        
        self.preventDisplaySleep = defaults.bool(forKey: "caffeine_preventDisplaySleep")
        self.showTimeInMenuBar = defaults.bool(forKey: "caffeine_showTimeInMenuBar")
        self.playSoundOnFinish = defaults.bool(forKey: "caffeine_playSoundOnFinish")
        self.sendNotificationOnFinish = defaults.bool(forKey: "caffeine_sendNotificationOnFinish")
        self.showInDock = defaults.bool(forKey: "caffeine_showInDock")
        self.launchAtLogin = defaults.bool(forKey: "caffeine_launchAtLogin")
        
        requestNotificationPermission()
        updateLaunchAtLogin()
        updateDockPolicy()
    }
    
    deinit {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
        }
    }
    
    // MARK: - Actions
    
    public func startPreset(_ preset: PresetOption) {
        if preset.duration == 0 {
            startIndefinite(presetId: preset.id)
        } else {
            start(duration: preset.duration, presetId: preset.id)
        }
    }
    
    public func startCustom() {
        let total = TimeInterval((customHours * 3600) + (customMinutes * 60))
        guard total > 0 else { return }
        start(duration: total, presetId: "custom")
    }
    
    public func startIndefinite(presetId: String? = "inf") {
        createAssertion()
        isActive = true
        isIndefinite = true
        activePresetId = presetId
        totalSeconds = 0
        remainingSeconds = 0
        targetDate = nil
        timerCancellable?.cancel()
        timerCancellable = nil
        updateDockPolicy()
    }
    
    public func start(duration: TimeInterval, presetId: String? = nil) {
        guard duration > 0 else { return }
        createAssertion()
        
        isActive = true
        isIndefinite = false
        activePresetId = presetId
        totalSeconds = duration
        remainingSeconds = duration
        targetDate = Date().addingTimeInterval(duration)
        
        startTimer()
        updateDockPolicy()
    }
    
    public func stop() {
        releaseAssertion()
        timerCancellable?.cancel()
        timerCancellable = nil
        
        isActive = false
        isIndefinite = false
        remainingSeconds = 0
        totalSeconds = 0
        targetDate = nil
        activePresetId = nil
        updateDockPolicy()
    }
    
    public func toggle() {
        if isActive {
            stop()
        } else {
            // Default to 1 hour if nothing selected, or last active preset
            start(duration: 3600, presetId: "1h")
        }
    }
    
    public func addExtraTime(seconds: TimeInterval) {
        guard isActive, !isIndefinite else { return }
        if let currentTarget = targetDate {
            targetDate = currentTarget.addingTimeInterval(seconds)
            totalSeconds += seconds
            remainingSeconds += seconds
        }
    }
    
    // MARK: - Power Assertion Management
    
    private func createAssertion() {
        releaseAssertion()
        
        let type: CFString = preventDisplaySleep
            ? (kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString)
            : (kIOPMAssertionTypePreventUserIdleSystemSleep as CFString)
            
        let reason = "Caffeine: Arka plan işlemi için sistem açık tutuluyor" as CFString
        let result = IOPMAssertionCreateWithName(
            type,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        if result != kIOReturnSuccess {
            print("Caffeine: Güç bildirimi oluşturulamadı (Hata kodu: \(result))")
        }
    }
    
    private func recreateAssertion() {
        if isActive {
            createAssertion()
        }
    }
    
    private func releaseAssertion() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
    }
    
    // MARK: - Timer & Events
    
    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTick()
            }
    }
    
    private func handleTick() {
        guard isActive, !isIndefinite else { return }
        
        guard let target = targetDate else {
            stop()
            return
        }
        
        let left = target.timeIntervalSinceNow
        if left <= 0 {
            finishSession()
        } else {
            remainingSeconds = left
        }
    }
    
    private func finishSession() {
        stop()
        
        if playSoundOnFinish {
            NSSound(named: "Glass")?.play()
        }
        
        if sendNotificationOnFinish {
            deliverFinishedNotification()
        }
    }
    
    // MARK: - Formatting Helpers
    
    public var formattedRemainingTime: String {
        if !isActive {
            return "00:00:00"
        }
        if isIndefinite {
            return "Süresiz"
        }
        return Self.formatTime(remainingSeconds)
    }
    
    public var menuBarDisplayString: String {
        if !isActive {
            return ""
        }
        if isIndefinite {
            return "∞"
        }
        let totalSecs = Int(ceil(remainingSeconds))
        let hours = totalSecs / 3600
        let minutes = (totalSecs % 3600) / 60
        let seconds = totalSecs % 60
        
        if hours > 0 {
            return String(format: "%dsa %02ddk", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%ddk %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    public var formattedTargetTime: String {
        if !isActive {
            return "Pasif"
        }
        if isIndefinite {
            return "Manuel durdurulana kadar aktif"
        }
        guard let target = targetDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "Bitiş: " + formatter.string(from: target)
    }
    
    public var progress: Double {
        guard isActive else { return 0.0 }
        if isIndefinite { return 1.0 }
        guard totalSeconds > 0 else { return 0.0 }
        return max(0.0, min(1.0, remainingSeconds / totalSeconds))
    }
    
    public static func formatTime(_ time: TimeInterval) -> String {
        let total = max(0, Int(ceil(time)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - System Integration
    
    public func updateDockPolicy() {
        if showInDock && isActive {
            if NSApplication.shared.activationPolicy() != .regular {
                NSApplication.shared.setActivationPolicy(.regular)
            }
        } else {
            if NSApplication.shared.activationPolicy() != .accessory {
                NSApplication.shared.setActivationPolicy(.accessory)
            }
        }
    }
    
    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("Caffeine: Launch at login failed: \(error)")
        }
    }
    
    private func requestNotificationPermission() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func deliverFinishedNotification() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = "Caffeine Süresi Doldu"
        content.body = "Belirlenen çalışma süresi tamamlandı. Sistem normal güç ve ekran uyku moduna döndü."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
