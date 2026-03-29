import SwiftUI

// MARK: - App Colors Base
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Sovereign Analyst Palette
struct Theme {
    static let primary = Color(hex: "4edea3") // Emerald Profit
    static let primaryContainer = Color(hex: "005236")
    
    static let secondary = Color(hex: "ff716a") // Crimson Loss
    static let secondaryVariant = Color(hex: "ee7d77")
    
    static let tertiary = Color(hex: "699cff") // Intelligence Layer
    static let onTertiaryFixedVariant = Color(hex: "699cff").opacity(0.8) // Used for shadows
    
    static let background = Color(hex: "060e20")
    static let onBackground = Color(hex: "dee5ff")
    
    // Tonal Layering
    static let surface = Color(hex: "0a1429")
    static let surfaceContainerLowest = Color(hex: "0d1830")
    static let surfaceContainerLow = Color(hex: "101d38")
    static let surfaceContainer = Color(hex: "132242")
    static let surfaceContainerHigh = Color(hex: "17284b")
    static let surfaceContainerHighest = Color(hex: "1c2f57")
    
    static let surfaceBright = Color(hex: "243a6b")
    
    static let onSurfaceVariant = Color(hex: "91aaeb")
    static let outlineVariant = Color(hex: "2b4680")
}

// MARK: - Typography
extension Font {
    // Space Grotesk (Using rounded/monospaced for that terminal feel)
    static func displayLg() -> Font { .system(size: 34, weight: .bold, design: .rounded).monospacedDigit() }
    static func displaySm() -> Font { .system(size: 28, weight: .bold, design: .rounded).monospacedDigit() }
    static func headlineLg() -> Font { .system(size: 24, weight: .semibold, design: .rounded).monospacedDigit() }
    static func headlineMd() -> Font { .system(size: 20, weight: .semibold, design: .rounded).monospacedDigit() }
    static func headlineSm() -> Font { .system(size: 18, weight: .semibold, design: .rounded).monospacedDigit() }
    
    // Inter (Using system for great x-height and legibility)
    static func bodyMd() -> Font { .system(size: 14, weight: .regular, design: .default).monospacedDigit() }
    static func labelMd() -> Font { .system(size: 12, weight: .medium, design: .default).monospacedDigit() }
    static func labelSm() -> Font { .system(size: 11, weight: .medium, design: .default).monospacedDigit() }
}

// MARK: - Components (View Modifiers)

struct SurfaceContainerModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 6 // .md in tailwind
    func body(content: Content) -> some View {
        content
            .background(color)
            .cornerRadius(radius)
    }
}

extension View {
    func surface(color: Color = Theme.surfaceContainer, radius: CGFloat = 6) -> some View {
        self.modifier(SurfaceContainerModifier(color: color, radius: radius))
    }
    
    // Glassmorphism rule: 70% opacity surface container, back-drop blur 20px
    func glassSurface() -> some View {
        self
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark) // Enforce dark material
            .cornerRadius(6)
    }
    
    func ghostBorder() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.outlineVariant.opacity(0.2), lineWidth: 1)
            )
    }
    
    func ambientShadow() -> some View {
        self
            .shadow(color: Theme.onTertiaryFixedVariant.opacity(0.06), radius: 40, x: 0, y: 0)
    }
}
