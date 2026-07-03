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

// TODO: implemented by later tasks (menu bar rendering, app lifecycle).
