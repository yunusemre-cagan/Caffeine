import Foundation
import AppIntents

@available(macOS 13.0, *)
public struct ToggleCaffeineIntent: AppIntent {
    public static var title: LocalizedStringResource = "Caffeine: Uyanık Tutmayı Başlat / Durdur"
    public static var description = IntentDescription("Mac'inizin uyku modunu tek tıkla açar veya kapatır.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        CaffeineManager.shared.toggle()
        return .result()
    }
}

@available(macOS 13.0, *)
public struct StartCaffeineIntent: AppIntent {
    public static var title: LocalizedStringResource = "Caffeine: Sistemi Uyanık Tut"
    public static var description = IntentDescription("Mac'inizi varsayılan süre boyunca uyanık tutar.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        CaffeineManager.shared.start(duration: 3600, presetId: "1h")
        return .result()
    }
}

@available(macOS 13.0, *)
public struct StopCaffeineIntent: AppIntent {
    public static var title: LocalizedStringResource = "Caffeine: Uyanık Tutmayı Durdur"
    public static var description = IntentDescription("Mac'inizin uyanık kalma modunu durdurur ve normal uyku moduna döndürür.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        CaffeineManager.shared.stop()
        return .result()
    }
}
