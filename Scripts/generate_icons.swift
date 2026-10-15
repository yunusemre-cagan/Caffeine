import AppKit

func renderIcon(size: CGFloat) -> NSImage {
    let imgSize = NSSize(width: size, height: size)
    let image = NSImage(size: imgSize)
    
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }
    
    // Draw rounded squircle
    let padding = size * 0.08
    let rect = CGRect(x: padding, y: padding, width: size - (2 * padding), height: size - (2 * padding))
    let corner = size * 0.22
    let path = CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    
    // Warm Amber / Espresso Gradient
    let colors = [
        NSColor(red: 1.0, green: 0.62, blue: 0.22, alpha: 1.0).cgColor,
        NSColor(red: 0.88, green: 0.35, blue: 0.12, alpha: 1.0).cgColor
    ] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: size / 2, y: size - padding), end: CGPoint(x: size / 2, y: padding), options: [])
    
    // Inner border highlight
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.25).cgColor)
    ctx.setLineWidth(size * 0.02)
    ctx.addPath(path)
    ctx.strokePath()
    ctx.restoreGState()
    
    // Draw Coffee Cup SF Symbol
    let pointSize = size * 0.44
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
    if let symbol = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        let tinted = NSImage(size: symbol.size)
        tinted.lockFocus()
        NSColor.white.set()
        let sRect = NSRect(origin: .zero, size: symbol.size)
        sRect.fill()
        symbol.draw(in: sRect, from: .zero, operation: .destinationIn, fraction: 1.0)
        tinted.unlockFocus()
        
        let drawX = (size - symbol.size.width) / 2
        let drawY = (size - symbol.size.height) / 2 - (size * 0.02)
        tinted.draw(in: NSRect(x: drawX, y: drawY, width: symbol.size.width, height: symbol.size.height))
    }
    
    image.unlockFocus()
    return image
}

let fileManager = FileManager.default
let iconsetDir = "AppIcon.iconset"
try? fileManager.removeItem(atPath: iconsetDir)
try? fileManager.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let targets: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in targets {
    let img = renderIcon(size: size)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let path = "\(iconsetDir)/\(filename)"
        try? png.write(to: URL(fileURLWithPath: path))
    }
}

print("Iconset created successfully.")
