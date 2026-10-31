import AppKit

struct WindowUsage {
    var utilization: Double
    var resetsAt: Date

    func isActive(at date: Date = Date()) -> Bool {
        resetsAt > date
    }
}

typealias UsageSnapshot = (fiveHour: WindowUsage?, sevenDay: WindowUsage?)
typealias UsageFetcher = (@escaping (UsageSnapshot?) -> Void) -> Void

final class ProviderState {
    let name: String
    let fetch: UsageFetcher
    var fiveHour: WindowUsage?
    var sevenDay: WindowUsage?
    var hasLoaded = false

    init(name: String, fetch: @escaping UsageFetcher) {
        self.name = name
        self.fetch = fetch
    }
}

final class AppState {
    let providers = [
        ProviderState(name: "Claude Code", fetch: fetchClaudeUsage),
        ProviderState(name: "Codex", fetch: fetchCodexUsage),
    ]
}

func readClaudeToken() -> String? {
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
    let normalized = string.replacingOccurrences(
        of: #"\.(\d{3})\d+"#,
        with: ".$1",
        options: .regularExpression
    )
    if let date = resetsAtFormatter.date(from: normalized) {
        return date
    }
    let fallback = ISO8601DateFormatter()
    fallback.formatOptions = [.withInternetDateTime]
    let noFraction = string.replacingOccurrences(
        of: #"\.\d+"#,
        with: "",
        options: .regularExpression
    )
    return fallback.date(from: noFraction)
}

private func parseDouble(_ value: Any?) -> Double? {
    if let double = value as? Double { return double }
    if let number = value as? NSNumber { return number.doubleValue }
    return nil
}

private func parseWindow(_ dict: [String: Any]?) -> WindowUsage? {
    guard
        let dict = dict,
        let utilization = parseDouble(dict["utilization"]),
        let resetsAtString = dict["resets_at"] as? String,
        let resetsAt = parseResetsAt(resetsAtString)
    else {
        return nil
    }
    return WindowUsage(utilization: utilization, resetsAt: resetsAt)
}

func fetchClaudeUsage(completion: @escaping (UsageSnapshot?) -> Void) {
    func finish(_ result: UsageSnapshot?) {
        DispatchQueue.main.async { completion(result) }
    }

    DispatchQueue.global(qos: .utility).async {
        guard let token = readClaudeToken() else {
            finish(nil)
            return
        }

        guard let url = URL(string: "https://api.anthropic.com/api/oauth/usage") else {
            finish(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                json["error"] == nil
            else {
                finish(nil)
                return
            }

            let fiveHour = parseWindow(json["five_hour"] as? [String: Any])
            let sevenDay = parseWindow(json["seven_day"] as? [String: Any])
            finish((fiveHour: fiveHour, sevenDay: sevenDay))
        }
        task.resume()
    }
}

func readCodexCredentials() -> (accessToken: String, accountID: String)? {
    let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".codex/auth.json")
    guard
        let data = try? Data(contentsOf: url),
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let tokens = json["tokens"] as? [String: Any],
        let accessToken = tokens["access_token"] as? String,
        !accessToken.isEmpty,
        let accountID = tokens["account_id"] as? String,
        !accountID.isEmpty
    else {
        return nil
    }
    return (accessToken: accessToken, accountID: accountID)
}

private func parseCodexWindow(_ dict: [String: Any]?) -> (seconds: Double, usage: WindowUsage)? {
    guard
        let dict = dict,
        let utilization = parseDouble(dict["used_percent"]),
        let seconds = parseDouble(dict["limit_window_seconds"]),
        let resetAt = parseDouble(dict["reset_at"])
    else {
        return nil
    }
    let usage = WindowUsage(utilization: utilization, resetsAt: Date(timeIntervalSince1970: resetAt))
    return (seconds: seconds, usage: usage)
}

func fetchCodexUsage(completion: @escaping (UsageSnapshot?) -> Void) {
    func finish(_ result: UsageSnapshot?) {
        DispatchQueue.main.async { completion(result) }
    }

    DispatchQueue.global(qos: .utility).async {
        guard let credentials = readCodexCredentials() else {
            finish(nil)
            return
        }

        guard let url = URL(string: "https://chatgpt.com/backend-api/wham/usage") else {
            finish(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(credentials.accountID, forHTTPHeaderField: "ChatGPT-Account-Id")
        request.setValue("codex-cli", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let rateLimit = json["rate_limit"] as? [String: Any]
            else {
                finish(nil)
                return
            }

            let windows = ["primary_window", "secondary_window"].compactMap {
                parseCodexWindow(rateLimit[$0] as? [String: Any])
            }
            let fiveHour = windows.first { $0.seconds < 86_400 }?.usage
            let sevenDay = windows.first { $0.seconds >= 86_400 }?.usage
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

private let statusResetTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

private func activeWindow(_ window: WindowUsage?, at date: Date = Date()) -> WindowUsage? {
    guard let window = window, window.isActive(at: date) else { return nil }
    return window
}

private func statusSegments(for provider: ProviderState, at now: Date) -> [RenderSegment] {
    let baseColor = NSColor.labelColor
    guard provider.hasLoaded else {
        return [.text("∞", baseColor.withAlphaComponent(0.4))]
    }

    let five = activeWindow(provider.fiveHour, at: now)
    let utilization = five?.utilization ?? 0
    let tint = warningColor(for: utilization) ?? baseColor

    var segments: [RenderSegment] = [
        .bar(utilization, tint),
        .text(percentString(utilization), tint),
    ]
    if let five {
        segments.append(.text(statusResetTimeFormatter.string(from: five.resetsAt), baseColor))
    }
    return segments
}

func renderStatusImage(state: AppState) -> NSImage {
    let now = Date()
    let hasWarning = state.providers.contains {
        warningColor(for: activeWindow($0.fiveHour, at: now)?.utilization ?? 0) != nil
    }
    let segments = Array(
        state.providers
            .map { statusSegments(for: $0, at: now) }
            .joined(separator: [RenderSegment.separator(NSColor.labelColor)])
    )

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

private let fiveHourResetFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

private let sevenDayResetFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE h:mm a"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

private func usageRowTitle(
    _ label: String,
    window: WindowUsage?,
    hasLoaded: Bool,
    resetsIn: (Date) -> String,
    resetFormatter: DateFormatter
) -> String {
    if let window {
        return "\(label): \(percentString(window.utilization)) used • resets in \(resetsIn(window.resetsAt)) • at \(resetFormatter.string(from: window.resetsAt))"
    }
    return hasLoaded ? "\(label): 0% used" : "\(label): loading…"
}

private struct ProviderMenuRows {
    let provider: ProviderState
    let header: NSMenuItem
    let fiveHour = NSMenuItem(title: "5h limit: loading…", action: nil, keyEquivalent: "")
    let sevenDay = NSMenuItem(title: "Weekly limit: loading…", action: nil, keyEquivalent: "")

    init(provider: ProviderState) {
        self.provider = provider
        header = NSMenuItem(title: provider.name, action: nil, keyEquivalent: "")
    }

    func update(at now: Date) {
        fiveHour.title = usageRowTitle(
            "5h limit",
            window: activeWindow(provider.fiveHour, at: now),
            hasLoaded: provider.hasLoaded,
            resetsIn: formatFiveHour(resetsAt:),
            resetFormatter: fiveHourResetFormatter
        )
        sevenDay.title = usageRowTitle(
            "Weekly limit",
            window: activeWindow(provider.sevenDay, at: now),
            hasLoaded: provider.hasLoaded,
            resetsIn: formatSevenDay(resetsAt:),
            resetFormatter: sevenDayResetFormatter
        )
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let state = AppState()
    private var statusItem: NSStatusItem!
    private var fetchTimer: Timer?
    private var redrawTimer: Timer?
    private lazy var menuRows = state.providers.map { ProviderMenuRows(provider: $0) }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = buildMenu()
        redraw()

        fetchTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        redrawTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.redraw()
        }
        refresh()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        for rows in menuRows {
            for item in [rows.header, rows.fiveHour, rows.sevenDay] {
                item.isEnabled = false
                menu.addItem(item)
            }
            menu.addItem(NSMenuItem.separator())
        }
        menu.addItem(NSMenuItem(title: "Refresh now", action: #selector(refreshNow), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        for item in menu.items where item.action != nil {
            item.target = self
        }
        return menu
    }

    @objc private func refreshNow() {
        refresh()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func refresh() {
        for provider in state.providers {
            provider.fetch { [weak self] result in
                guard let self = self else { return }
                if let result = result {
                    provider.fiveHour = result.fiveHour
                    provider.sevenDay = result.sevenDay
                    provider.hasLoaded = true
                }
                self.redraw()
            }
        }
    }

    private func redraw() {
        statusItem.button?.image = renderStatusImage(state: state)
        let now = Date()
        for rows in menuRows {
            rows.update(at: now)
        }
    }
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
let delegate = AppDelegate()
application.delegate = delegate
application.run()
