import AppKit

let width = 1290
let height = 2796
let output = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("app-store/screenshots/en-US")

try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

struct ScreenSpec {
    let filename: String
    let background: NSColor
    let profile: String
    let timer: String
    let round: String
    let primaryButton: String
    let secondaryButton: String?
    let overlay: Overlay?
}

enum Overlay {
    case profileEditor
    case settings
}

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
    NSColor(calibratedRed: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
}

let specs: [ScreenSpec] = [
    ScreenSpec(
        filename: "01-main-idle.png",
        background: color(4, 5, 5),
        profile: "Standard Boxing",
        timer: "03:00",
        round: "Round 1 of 12",
        primaryButton: "Start",
        secondaryButton: "Reset",
        overlay: nil
    ),
    ScreenSpec(
        filename: "02-active-round.png",
        background: color(34, 197, 94),
        profile: "Standard Boxing",
        timer: "02:41",
        round: "Round 1 of 12",
        primaryButton: "Pause",
        secondaryButton: "Reset",
        overlay: nil
    ),
    ScreenSpec(
        filename: "03-break.png",
        background: color(220, 38, 38),
        profile: "Standard Boxing",
        timer: "00:44",
        round: "Round 2 of 12",
        primaryButton: "Pause",
        secondaryButton: "Reset",
        overlay: nil
    ),
    ScreenSpec(
        filename: "04-profile-editor.png",
        background: color(4, 5, 5),
        profile: "Custom HIIT",
        timer: "01:00",
        round: "Round 1 of 20",
        primaryButton: "Start",
        secondaryButton: "Reset",
        overlay: .profileEditor
    ),
    ScreenSpec(
        filename: "05-settings.png",
        background: color(4, 5, 5),
        profile: "Standard Boxing",
        timer: "03:00",
        round: "Round 1 of 12",
        primaryButton: "Start",
        secondaryButton: "Reset",
        overlay: .settings
    )
]

func paragraph(_ alignment: NSTextAlignment = .center, lineHeight: CGFloat? = nil) -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    if let lineHeight {
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
    }
    return style
}

func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: NSFont.Weight, color: NSColor = .white, alignment: NSTextAlignment = .center) {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph(alignment)
    ]
    NSString(string: text).draw(in: rect, withAttributes: attrs)
}

func drawRoundedRect(_ rect: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

func drawButton(_ title: String, rect: CGRect, filled: Bool = false) {
    let fill = filled ? NSColor.white : NSColor.white.withAlphaComponent(0.18)
    let textColor = filled ? NSColor.black : NSColor.white
    drawRoundedRect(rect, radius: 44, fill: fill)
    drawText(title, in: rect.insetBy(dx: 12, dy: 24), size: 42, weight: .semibold, color: textColor)
}

func drawGear(in rect: CGRect) {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let color = NSColor.white.withAlphaComponent(0.72)
    color.setStroke()
    color.setFill()

    let outer = NSBezierPath(ovalIn: rect.insetBy(dx: 15, dy: 15))
    outer.lineWidth = 8
    outer.stroke()

    NSBezierPath(ovalIn: rect.insetBy(dx: 31, dy: 31)).fill()

    for index in 0..<8 {
        let angle = (CGFloat(index) * CGFloat.pi / 4)
        let start = CGPoint(x: center.x + cos(angle) * 32, y: center.y + sin(angle) * 32)
        let end = CGPoint(x: center.x + cos(angle) * 43, y: center.y + sin(angle) * 43)
        let tick = NSBezierPath()
        tick.move(to: start)
        tick.line(to: end)
        tick.lineWidth = 7
        tick.stroke()
    }
}

func drawBase(_ spec: ScreenSpec) {
    spec.background.setFill()
    CGRect(x: 0, y: 0, width: width, height: height).fill()

    let gearRect = CGRect(x: width - 136, y: height - 188, width: 58, height: 58)
    drawGear(in: gearRect)

    let pill = CGRect(x: 365, y: height - 498, width: 560, height: 86)
    drawRoundedRect(pill, radius: 43, fill: NSColor.white.withAlphaComponent(0.20))
    drawText(spec.profile + "  v", in: pill.insetBy(dx: 22, dy: 22), size: 34, weight: .semibold)

    drawText(spec.timer, in: CGRect(x: 60, y: height - 1455, width: width - 120, height: 230), size: 166, weight: .bold)
    drawText(spec.round, in: CGRect(x: 60, y: height - 1588, width: width - 120, height: 70), size: 42, weight: .medium, color: .white.withAlphaComponent(0.92))

    drawButton(spec.primaryButton, rect: CGRect(x: 155, y: 395, width: 420, height: 116), filled: false)
    if let secondary = spec.secondaryButton {
        drawButton(secondary, rect: CGRect(x: 715, y: 395, width: 420, height: 116), filled: false)
    }
}

func drawCard(_ title: String, height cardHeight: CGFloat) -> CGRect {
    let rect = CGRect(x: 72, y: 126, width: CGFloat(width - 144), height: cardHeight)
    drawRoundedRect(rect, radius: 34, fill: color(246, 247, 249), stroke: NSColor.black.withAlphaComponent(0.08), lineWidth: 2)
    drawText(title, in: CGRect(x: rect.minX + 30, y: rect.maxY - 106, width: rect.width - 60, height: 62), size: 38, weight: .bold, color: .black)
    return rect
}

func drawRow(_ label: String, value: String, y: CGFloat, icon: NSColor = color(0, 122, 255)) {
    drawRoundedRect(CGRect(x: 126, y: y + 17, width: 34, height: 34), radius: 17, fill: icon)
    drawText(label, in: CGRect(x: 184, y: y, width: 560, height: 70), size: 30, weight: .medium, color: .black, alignment: .left)
    drawText(value, in: CGRect(x: 780, y: y, width: 360, height: 70), size: 30, weight: .regular, color: NSColor.darkGray, alignment: .right)
}

func drawProfileEditor() {
    let card = drawCard("Edit Profile", height: 950)
    drawText("Custom HIIT", in: CGRect(x: 126, y: card.maxY - 188, width: CGFloat(width - 252), height: 76), size: 40, weight: .semibold, color: .black, alignment: .left)
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 224, width: CGFloat(width - 252), height: 2), radius: 1, fill: NSColor.black.withAlphaComponent(0.08))

    drawRow("Round Duration", value: "01:00", y: card.maxY - 340)
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 408, width: CGFloat(width - 252), height: 14), radius: 7, fill: color(218, 224, 232))
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 408, width: 510, height: 14), radius: 7, fill: color(0, 122, 255))

    drawRow("Break Duration", value: "00:15", y: card.maxY - 520, icon: color(220, 38, 38))
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 588, width: CGFloat(width - 252), height: 14), radius: 7, fill: color(218, 224, 232))
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 588, width: 250, height: 14), radius: 7, fill: color(220, 38, 38))

    drawRow("Rounds", value: "20", y: card.maxY - 700, icon: color(34, 197, 94))
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 768, width: CGFloat(width - 252), height: 14), radius: 7, fill: color(218, 224, 232))
    drawRoundedRect(CGRect(x: 126, y: card.maxY - 768, width: 650, height: 14), radius: 7, fill: color(34, 197, 94))

    drawText("Total Workout Time", in: CGRect(x: 126, y: card.minY + 108, width: 500, height: 54), size: 30, weight: .semibold, color: .black, alignment: .left)
    drawText("24m 45s", in: CGRect(x: 720, y: card.minY + 108, width: 420, height: 54), size: 34, weight: .bold, color: color(0, 122, 255), alignment: .right)
}

func drawSettings() {
    let card = drawCard("Settings", height: 1000)
    drawRow("Sound Effects", value: "On", y: card.maxY - 214)
    drawRow("Voice Announcements", value: "On", y: card.maxY - 326)
    drawRow("Haptic Feedback", value: "On", y: card.maxY - 438)
    drawRow("Version", value: "1.0.0", y: card.maxY - 596, icon: color(120, 120, 128))
    drawRow("App", value: "Absolute Timer", y: card.maxY - 708, icon: color(120, 120, 128))
    drawText("Training timer only. Not medical, safety, or coaching advice.", in: CGRect(x: 126, y: card.maxY - 838, width: CGFloat(width - 252), height: 74), size: 24, weight: .regular, color: NSColor.darkGray, alignment: .left)
    drawRow("Support", value: "Open", y: card.minY + 106, icon: color(0, 122, 255))
}

for spec in specs {
    let image = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high

    drawBase(spec)

    switch spec.overlay {
    case .profileEditor:
        drawProfileEditor()
    case .settings:
        drawSettings()
    case nil:
        break
    }

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not render \(spec.filename)")
    }

    try png.write(to: output.appendingPathComponent(spec.filename))
}

print("Generated \(specs.count) screenshots in \(output.path)")
