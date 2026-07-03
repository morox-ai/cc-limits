import AppKit

struct WindowUsage {
    var utilization: Double
    var resetsAt: Date
}

final class AppState {
    var fiveHour: WindowUsage?
    var sevenDay: WindowUsage?
    var hasLoaded = false
}

func readToken() -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = ["find-generic-password", "-s", "Claude Code-credentials", "-w"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()

    do {
        try process.run()
    } catch {
        return nil
    }
    process.waitUntilExit()

    guard process.terminationStatus == 0 else { return nil }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard !data.isEmpty else { return nil }

    guard
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let oauth = json["claudeAiOauth"] as? [String: Any],
        let token = oauth["accessToken"] as? String,
        !token.isEmpty
    else {
        return nil
    }

    return token
}

private let resetsAtFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

private func parseResetsAt(_ string: String) -> Date? {
    if let date = resetsAtFormatter.date(from: string) {
        return date
    }
    let fallback = ISO8601DateFormatter()
    fallback.formatOptions = [.withInternetDateTime]
    return fallback.date(from: string)
}

private func parseWindow(_ dict: [String: Any]?) -> WindowUsage? {
    guard
        let dict = dict,
        let utilization = dict["utilization"] as? Double,
        let resetsAtString = dict["resets_at"] as? String,
        let resetsAt = parseResetsAt(resetsAtString)
    else {
        return nil
    }
    return WindowUsage(utilization: utilization, resetsAt: resetsAt)
}

func fetchUsage(completion: @escaping ((fiveHour: WindowUsage, sevenDay: WindowUsage)?) -> Void) {
    func finish(_ result: (fiveHour: WindowUsage, sevenDay: WindowUsage)?) {
        DispatchQueue.main.async { completion(result) }
    }

    DispatchQueue.global(qos: .utility).async {
        guard let token = readToken() else {
            finish(nil)
            return
        }

        guard let url = URL(string: "https://api.anthropic.com/api/oauth/usage") else {
            finish(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                json["error"] == nil,
                let fiveHour = parseWindow(json["five_hour"] as? [String: Any]),
                let sevenDay = parseWindow(json["seven_day"] as? [String: Any])
            else {
                finish(nil)
                return
            }
            finish((fiveHour: fiveHour, sevenDay: sevenDay))
        }
        task.resume()
    }
}

func remaining(until date: Date) -> TimeInterval {
    date.timeIntervalSinceNow
}

func formatFiveHour(_ remaining: TimeInterval) -> String {
    let clamped = max(0, remaining)
    let totalMinutes = Int(clamped) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return String(format: "%d:%02d", hours, minutes)
}

func formatSevenDay(_ remaining: TimeInterval) -> String {
    let clamped = max(0, remaining)
    let totalSeconds = Int(clamped)
    let days = totalSeconds / 86_400
    let hours = (totalSeconds % 86_400) / 3_600
    let minutes = (totalSeconds % 3_600) / 60
    if days >= 1 {
        return "\(days)d \(hours)h"
    }
    if hours >= 1 {
        return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
}

func formatFiveHour(resetsAt: Date) -> String {
    formatFiveHour(remaining(until: resetsAt))
}

func formatSevenDay(resetsAt: Date) -> String {
    formatSevenDay(remaining(until: resetsAt))
}

private let menuBarFont = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
private let barWidth: CGFloat = 22
private let barHeight: CGFloat = 5
private let elementGap: CGFloat = 4
private let groupGap: CGFloat = 6
private let imageHeight: CGFloat = 18
private let horizontalPadding: CGFloat = 2

private let amberColor = NSColor(red: 0.85, green: 0.60, blue: 0.0, alpha: 1.0)
private let redColor = NSColor(red: 0.86, green: 0.22, blue: 0.20, alpha: 1.0)

func warningColor(for utilization: Double) -> NSColor? {
    if utilization > 80 { return redColor }
    if utilization > 60 { return amberColor }
    return nil
}

private func percentString(_ utilization: Double) -> String {
    String(format: "%d%%", Int(utilization.rounded()))
}

private enum RenderSegment {
    case text(String, NSColor)
    case bar(Double, NSColor)
    case separator(NSColor)
}

private func textAttributes(_ color: NSColor) -> [NSAttributedString.Key: Any] {
    [.font: menuBarFont, .foregroundColor: color]
}

private func segmentWidth(_ segment: RenderSegment) -> CGFloat {
    switch segment {
    case let .text(string, color):
        return (string as NSString).size(withAttributes: textAttributes(color)).width
    case .bar:
        return barWidth
    case let .separator(color):
        return ("│" as NSString).size(withAttributes: textAttributes(color)).width
    }
}

private func gapBetween(_ a: RenderSegment, _ b: RenderSegment) -> CGFloat {
    if case .separator = a { return groupGap }
    if case .separator = b { return groupGap }
    return elementGap
}

private func drawText(_ string: String, color: NSColor, x: CGFloat) {
    let attrs = textAttributes(color)
    let size = (string as NSString).size(withAttributes: attrs)
    let y = (imageHeight - size.height) / 2
    (string as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
}

private func drawBar(utilization: Double, color: NSColor, x: CGFloat) {
    let y = (imageHeight - barHeight) / 2
    let radius = barHeight / 2

    let trackRect = NSRect(x: x, y: y, width: barWidth, height: barHeight)
    let track = NSBezierPath(roundedRect: trackRect, xRadius: radius, yRadius: radius)
    color.withAlphaComponent(0.25).setFill()
    track.fill()

    let fraction = max(0, min(1, utilization / 100))
    if fraction > 0 {
        let fillWidth = min(barWidth, max(barHeight, barWidth * CGFloat(fraction)))
        let fillRect = NSRect(x: x, y: y, width: fillWidth, height: barHeight)
        let fill = NSBezierPath(roundedRect: fillRect, xRadius: radius, yRadius: radius)
        color.setFill()
        fill.fill()
    }
}

private func drawSegment(_ segment: RenderSegment, x: CGFloat) {
    switch segment {
    case let .text(string, color):
        drawText(string, color: color, x: x)
    case let .bar(utilization, color):
        drawBar(utilization: utilization, color: color, x: x)
    case let .separator(color):
        drawText("│", color: color.withAlphaComponent(0.5), x: x)
    }
}

private func renderPlaceholderImage() -> NSImage {
    let color = NSColor.labelColor.withAlphaComponent(0.4)
    let attrs = textAttributes(color)
    let size = ("∞" as NSString).size(withAttributes: attrs)
    let width = ceil(size.width) + horizontalPadding * 2
    let image = NSImage(size: NSSize(width: width, height: imageHeight))
    image.lockFocus()
    ("∞" as NSString).draw(
        at: NSPoint(x: (width - size.width) / 2, y: (imageHeight - size.height) / 2),
        withAttributes: attrs
    )
    image.unlockFocus()
    image.isTemplate = true
    return image
}

func renderStatusImage(state: AppState) -> NSImage {
    guard state.hasLoaded, let five = state.fiveHour, let seven = state.sevenDay else {
        return renderPlaceholderImage()
    }

    let baseColor = NSColor.labelColor
    let fiveWarning = warningColor(for: five.utilization)
    let sevenWarning = warningColor(for: seven.utilization)
    let fiveTint = fiveWarning ?? baseColor
    let sevenTint = sevenWarning ?? baseColor
    let hasWarning = fiveWarning != nil || sevenWarning != nil

    let segments: [RenderSegment] = [
        .text(formatFiveHour(resetsAt: five.resetsAt), baseColor),
        .bar(five.utilization, fiveTint),
        .text(percentString(five.utilization), fiveTint),
        .separator(baseColor),
        .text(formatSevenDay(resetsAt: seven.resetsAt), baseColor),
        .bar(seven.utilization, sevenTint),
        .text(percentString(seven.utilization), sevenTint),
    ]

    var totalWidth: CGFloat = 0
    for (index, segment) in segments.enumerated() {
        totalWidth += segmentWidth(segment)
        if index < segments.count - 1 {
            totalWidth += gapBetween(segment, segments[index + 1])
        }
    }

    let width = ceil(totalWidth) + horizontalPadding * 2
    let image = NSImage(size: NSSize(width: width, height: imageHeight))
    image.lockFocus()
    var x = horizontalPadding
    for (index, segment) in segments.enumerated() {
        drawSegment(segment, x: x)
        x += segmentWidth(segment)
        if index < segments.count - 1 {
            x += gapBetween(segment, segments[index + 1])
        }
    }
    image.unlockFocus()
    image.isTemplate = !hasWarning
    return image
}

// TODO: implemented by later tasks (app lifecycle, status item, timers, menu).
