import SwiftUI

struct DonutClockView: View {
    let events: [CalendarEvent]
    let clockOffset: Int // 0-23: What hour is at the top (12 o'clock position)
    let nextEvent: CalendarEvent?

    private let outerRadius: CGFloat = 160
    private let innerRadius: CGFloat = 100  // Smaller center circle for wider donut
    private let clockRadius: CGFloat = 150  // Between inner and outer radius

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: outerRadius * 2, height: outerRadius * 2)

            // Event segments
            ForEach(events.filter { !$0.isPast }) { event in
                EventSegment(
                    event: event,
                    clockOffset: clockOffset,
                    innerRadius: innerRadius,
                    outerRadius: outerRadius
                )
            }

            // Center circle
            Circle()
                .fill(Color.white)
                .frame(width: innerRadius * 2, height: innerRadius * 2)

            // Center time display - time until next event
            VStack(spacing: 2) {
                Text("次の予定まで")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)

                Text(timeUntilNextEventString())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
            }
            .padding(8)
            .background(Color.white.opacity(0.01))

            // Hour markers (24-hour) - drawn last to be on top
            ForEach(0..<24, id: \.self) { hour in
                HourMarker(
                    hour: hour,
                    clockOffset: clockOffset,
                    radius: clockRadius,
                    centerOffset: outerRadius + 10
                )
            }

            // Current time indicator - drawn last to be on top
            CurrentTimeIndicator(
                clockOffset: clockOffset,
                radius: (innerRadius + outerRadius) / 2,  // Middle of donut area
                centerOffset: outerRadius + 10,
                outerRadius: outerRadius
            )
        }
        .frame(width: outerRadius * 2 + 20, height: outerRadius * 2 + 20)
    }

    private func timeUntilNextEventString() -> String {
        // Find the next upcoming event (not currently ongoing)
        let upcomingEvent = events
            .filter { !$0.isPast && !$0.isOngoing }
            .sorted { $0.startTime < $1.startTime }
            .first

        guard let event = upcomingEvent else {
            return "--:--"
        }

        // Calculate time until event starts
        guard let timeInterval = event.timeUntilStart else {
            return "--:--"
        }

        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        return String(format: "%02d:%02d", hours, minutes)
    }
}

// MARK: - Hour Marker
struct HourMarker: View {
    let hour: Int
    let clockOffset: Int
    let radius: CGFloat
    let centerOffset: CGFloat

    var body: some View {
        let angle = angleForHour(hour)
        let x = CoreGraphics.cos(angle) * radius
        let y = CoreGraphics.sin(angle) * radius

        Text("\(hour)")
            .font(.system(size: 12, weight: .medium))
            .offset(x: x, y: y)
    }

    private func angleForHour(_ hour: Int) -> CGFloat {
        // Adjust hour based on clock offset
        let adjustedHour = (hour - clockOffset + 24) % 24
        // Convert to radians, starting from top (12 o'clock = -90 degrees)
        return CGFloat(adjustedHour) * (2 * .pi / 24) - .pi / 2
    }
}

// MARK: - Event Segment
struct EventSegment: View {
    let event: CalendarEvent
    let clockOffset: Int
    let innerRadius: CGFloat
    let outerRadius: CGFloat

    var body: some View {
        if let startAngle = angleForTime(event.startTime),
           let endAngle = angleForTime(event.endTime) {
            DonutSegment(
                startAngle: startAngle,
                endAngle: endAngle,
                innerRadius: innerRadius,
                outerRadius: outerRadius
            )
            .fill(event.color)
            .opacity(0.7)
        }
    }

    private func angleForTime(_ date: Date) -> Angle? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }

        // Calculate the fractional hour (e.g., 13:30 = 13.5)
        let fractionalHour = Double(hour) + Double(minute) / 60.0

        // Adjust for clock offset
        let adjustedHour = (fractionalHour - Double(clockOffset) + 24).truncatingRemainder(dividingBy: 24)

        // Convert to angle (0 = top of circle)
        let degrees = (adjustedHour * 360.0 / 24.0) - 90.0
        return Angle(degrees: degrees)
    }
}

// MARK: - Donut Segment Shape
struct DonutSegment: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Outer arc
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        // Line to inner arc
        let innerStart = CGPoint(
            x: center.x + innerRadius * CoreGraphics.cos(endAngle.radians),
            y: center.y + innerRadius * CoreGraphics.sin(endAngle.radians)
        )
        path.addLine(to: innerStart)

        // Inner arc (reverse direction)
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Current Time Indicator
struct CurrentTimeIndicator: View {
    let clockOffset: Int
    let radius: CGFloat
    let centerOffset: CGFloat
    let outerRadius: CGFloat

    var body: some View {
        let angle = currentTimeAngle()
        let x = CoreGraphics.cos(angle) * radius
        let y = CoreGraphics.sin(angle) * radius
        let center = outerRadius + 10

        ZStack {
            // Hand (needle) from center to current time
            Path { path in
                path.move(to: CGPoint(x: center, y: center))
                path.addLine(to: CGPoint(x: center + x, y: center + y))
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round))

            // Dot at the end of the hand
            Circle()
                .fill(Color.black)
                .frame(width: 8, height: 8)
                .offset(x: x, y: y)
        }
    }

    private func currentTimeAngle() -> CGFloat {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)

        let fractionalHour = hour + minute / 60.0
        let adjustedHour = (fractionalHour - Double(clockOffset) + 24).truncatingRemainder(dividingBy: 24)

        // Convert to radians (starting from top)
        return CGFloat(adjustedHour) * (2 * .pi / 24) - .pi / 2
    }
}
