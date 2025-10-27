//
//  P2.swift
//  P1
//
//  Created by Norah Abdulkairm on 30/04/1447 AH.
//

import SwiftUI

// MARK: - Layout constants (tweak to match the mock precisely)
private enum ActivityLayout {
    static let screenHorizontalPadding: CGFloat = 16
    static let topBarTopPadding: CGFloat = 4
    static let cardCornerRadius: CGFloat = 18
    static let cardInnerPadding: CGFloat = 14
    static let headerBottomSpacing: CGFloat = 8
    static let weekHeaderBottomSpacing: CGFloat = 8
    static let dividerTopSpacing: CGFloat = 10
    static let statsTopSpacing: CGFloat = 12
    static let footerTopSpacing: CGFloat = 8

    // Outside the card
    static let cardBottomToButtonsSpacing: CGFloat = 20
    static let bigButtonSize: CGFloat = 240
    static let outsideButtonsVerticalSpacing: CGFloat = 16
}

// MARK: - Reusable Glass Effect

private struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = ActivityLayout.cardCornerRadius
    var strokeOpacity: Double = 0.25
    var shadowOpacity: Double = 0.35

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.50),
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(shadowOpacity), radius: 14, x: 0, y: 8)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = ActivityLayout.cardCornerRadius) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Shared helpers

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension Calendar {
    func startOfDay(for date: Date, timeZone: TimeZone? = nil) -> Date {
        var cal = self
        if let tz = timeZone { cal.timeZone = tz }
        return cal.startOfDay(for: date)
    }
}

// MARK: - Day status model

enum DayStatus: String, Codable, Equatable {
    case none
    case learned
    case freezed
}

// MARK: - Activity Top Bar

struct ActivityTopBar: View {
    var title: String = "Activity"
    var onCalendarTap: (() -> Void)?
    var onEditGoalTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            CircleIconButton(systemName: "calendar", action: { onCalendarTap?() })
            CircleIconButton(systemName: "slash.circle", action: { onEditGoalTap?() })
        }
        .padding(.horizontal, ActivityLayout.screenHorizontalPadding)
        .padding(.top, ActivityLayout.topBarTopPadding)
    }

    private struct CircleIconButton: View {
        let systemName: String
        var action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Month/Year Wheel Popover (used by the header)

private struct MonthYearWheelPopover: View {
    @Binding var date: Date

    let calendar = Calendar.current
    let monthSymbols = Calendar.current.monthSymbols
    let years: [Int]

    var selectedMonthIndex: Int { calendar.component(.month, from: date) - 1 }
    var selectedYear: Int { calendar.component(.year, from: date) }

    init(date: Binding<Date>) {
        self._date = date
        let current = Calendar.current.component(.year, from: Date())
        self.years = Array((current - 50)...(current + 50))
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Picker("Month", selection: Binding(
                    get: { selectedMonthIndex },
                    set: { newIndex in
                        updateDate(monthIndex: newIndex, year: selectedYear)
                    }
                )) {
                    ForEach(monthSymbols.indices, id: \.self) { idx in
                        Text(monthSymbols[idx]).tag(idx)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Year", selection: Binding(
                    get: { selectedYear },
                    set: { newYear in
                        updateDate(monthIndex: selectedMonthIndex, year: newYear)
                    }
                )) {
                    ForEach(years, id: \.self) { yr in
                        Text("\(yr)").tag(yr)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
        )
    }

    private func updateDate(monthIndex: Int, year: Int) {
        var comps = calendar.dateComponents([.day, .month, .year], from: date)
        comps.month = monthIndex + 1
        comps.year = year

        if let m = comps.month, let y = comps.year,
           let range = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: y, month: m)) ?? Date()) {
            comps.day = min(comps.day ?? 1, range.count)
        }
        if let newDate = calendar.date(from: comps) {
            date = newDate
        }
    }
}

// MARK: - Weekly Calendar (days row + week navigation + status coloring)

struct WeeklyCalendarCard: View {
    @Binding var selectedDate: Date
    @Binding var statuses: [Date: DayStatus]

    @State private var referenceDate: Date = Date()

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 1
        return cal
    }()

    private var weekDates: [Date] {
        guard let start = startOfWeek(for: referenceDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ActivityLayout.weekHeaderBottomSpacing) {
            weekdaysHeader
            daysRow
            Divider().background(Color.white.opacity(0.18))
                .padding(.top, ActivityLayout.dividerTopSpacing)
        }
        .onAppear { referenceDate = selectedDate }
    }

    private var weekdaysHeader: some View {
        HStack {
            ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var daysRow: some View {
        HStack(spacing: 10) {
            ForEach(weekDates, id: \.self) { date in
                dayPill(for: date)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func status(for date: Date) -> DayStatus {
        let key = calendar.startOfDay(for: date)
        return statuses[key] ?? .none
    }

    private func dayPill(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayNumber = calendar.component(.day, from: date)
        let st = status(for: date)

        let fillColor: Color = {
            switch st {
            case .learned: return .orange
            case .freezed: return Color.teal.opacity(0.25)
            case .none:     return isSelected ? .orange : (isToday ? Color.teal.opacity(0.35) : .clear)
            }
        }()

        let strokeOpacity: Double = (st == .learned || isSelected) ? 0.0 : 0.25
        let textColor: Color = (st == .learned || isSelected) ? .black : .white

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedDate = date
                referenceDate = date
            }
        } label: {
            ZStack {
                Circle().fill(fillColor)
                Circle().stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .shadow(color: (st == .learned || isSelected) ? Color.orange.opacity(0.5) : Color.clear,
                    radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    func moveWeek(by offset: Int) {
        if let newDate = calendar.date(byAdding: .day, value: 7 * offset, to: referenceDate) {
            withAnimation(.easeInOut(duration: 0.25)) {
                referenceDate = newDate
                selectedDate = newDate
            }
        }
    }

    private func startOfWeek(for date: Date) -> Date? {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps)
    }
}

// MARK: - Stat Chip

private struct StatChip: View {
    let value: Int
    let title: String
    let color: Color
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(9)
                .background(color.opacity(0.9), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text("\(value)")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(color.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Glass Card content (no action buttons inside)

struct WeeklyCalendarCardContainer: View {
    @Binding var selectedDate: Date
    @Binding var statuses: [Date: DayStatus]
    @Binding var isPickerOpen: Bool
    var goal: String // NEW: show goal in footer

    private let calendar = Calendar.current
    private var monthSymbols: [String] { calendar.monthSymbols }

    private var headerTitle: String {
        let month = monthSymbols[safe: calendar.component(.month, from: selectedDate) - 1] ?? ""
        let year = calendar.component(.year, from: selectedDate)
        return "\(month) \(year)"
    }

    private var learnedCount: Int { statuses.values.filter { $0 == .learned }.count }
    private var freezedCount: Int { statuses.values.filter { $0 == .freezed }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Button { isPickerOpen.toggle() } label: {
                    HStack(spacing: 8) {
                        Text(headerTitle)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: isPickerOpen ? "chevron.up" : "chevron.down")
                            .foregroundColor(.orange)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, ActivityLayout.cardInnerPadding)
            .padding(.top, ActivityLayout.cardInnerPadding)
            .padding(.bottom, ActivityLayout.headerBottomSpacing)
            .overlay(alignment: .bottomLeading) {
                if isPickerOpen {
                    MonthYearWheelPopover(date: $selectedDate)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isPickerOpen)

            // Week + divider
            WeeklyCalendarCard(selectedDate: $selectedDate, statuses: $statuses)
                .padding(.horizontal, ActivityLayout.cardInnerPadding)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 10) {
                        Button { weekNav(-1) } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(6)
                        }
                        Button { weekNav(1) } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(6)
                        }
                    }
                    .padding(.trailing, ActivityLayout.cardInnerPadding - 4)
                    .offset(y: -38)
                }

            // Stats row
            HStack(spacing: 10) {
                StatChip(value: learnedCount, title: "Days Learned", color: Color.orange, systemImage: "flame.fill")
                StatChip(value: freezedCount, title: "Day Freezed", color: Color.teal, systemImage: "cube.fill")
            }
            .padding(.horizontal, ActivityLayout.cardInnerPadding)
            .padding(.top, ActivityLayout.statsTopSpacing)

            // Footer: show goal here
            Text(goal.isEmpty ? "Your goal" : goal)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, ActivityLayout.cardInnerPadding)
                .padding(.top, ActivityLayout.footerTopSpacing)
                .padding(.bottom, ActivityLayout.cardInnerPadding)
        }
        .glassCard(cornerRadius: ActivityLayout.cardCornerRadius)
    }

    private func weekNav(_ offset: Int) {
        if let newDate = calendar.date(byAdding: .day, value: offset * 7, to: selectedDate) {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedDate = newDate
            }
        }
    }
}

// MARK: - Activity Screen (Top bar + glass card + buttons outside card)

struct ActivityScreen: View {
    // Lifted state so both the card and buttons share the same data
    @State private var selectedDate: Date = Date()
    @State private var statuses: [Date: DayStatus] = [:]
    @State private var isPickerOpen: Bool = false
    @State private var freezesUsed: Int = 0
    private let maxFreezes = 2

    // NEW: goal text that appears in the card footer
    @State private var goal: String = "Learning Swift"

    @State private var showEditGoal: Bool = false
    @State private var showCalendarShortcut: Bool = false

    private let calendar = Calendar.current

    private var selectedKey: Date { calendar.startOfDay(for: selectedDate) }
    private var selectedStatus: DayStatus { statuses[selectedKey] ?? .none }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                ActivityTopBar(
                    onCalendarTap: { showCalendarShortcut.toggle() },
                    onEditGoalTap: { showEditGoal.toggle() }
                )

                // Glass card with goal footer
                WeeklyCalendarCardContainer(
                    selectedDate: $selectedDate,
                    statuses: $statuses,
                    isPickerOpen: $isPickerOpen,
                    goal: goal
                )
                .padding(.horizontal, ActivityLayout.screenHorizontalPadding)

                // Buttons OUTSIDE the glass card
                VStack(spacing: ActivityLayout.outsideButtonsVerticalSpacing) {
                    Button {
                        logLearned()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(selectedStatus == .learned ? Color.orange : Color.orange.opacity(0.25))
                                .frame(width: ActivityLayout.bigButtonSize, height: ActivityLayout.bigButtonSize)
                                .overlay(
                                    Circle().stroke(Color.orange.opacity(0.4), lineWidth: 1)
                                        .shadow(color: Color.white.opacity(0.6), radius: 10)
                                        .shadow(color: Color.orange.opacity(0.45), radius: 12)
                                )
                            Text(selectedStatus == .learned ? "Learned\nToday" : "Log as\nLearned")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, ActivityLayout.cardBottomToButtonsSpacing)

                    Button {
                        logFreezed()
                    } label: {
                        Text("Log as Freezed")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.teal)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.teal, lineWidth: 2)
                            )
                    }
                    .disabled(selectedStatus == .learned || freezesUsed >= maxFreezes)
                    .opacity((selectedStatus == .learned || freezesUsed >= maxFreezes) ? 0.6 : 1.0)
                    .padding(.horizontal, ActivityLayout.screenHorizontalPadding)

                    Text("\(freezesUsed) out of \(maxFreezes) freezes used")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer(minLength: 10)
            }
        }
        .sheet(isPresented: $showEditGoal) {
            // Pass the goal binding and reset callback into the sheet
            EditGoalSheet(goal: $goal, onSave: {
                // Reset learned/freezed days when goal changes
                statuses.removeAll()
                freezesUsed = 0
            })
        }
        .sheet(isPresented: $showCalendarShortcut) {
            CalendarShortcutSheet()
        }
    }

    // Actions
    private func logLearned() {
        let key = selectedKey
        if statuses[key] != .learned {
            statuses[key] = .learned
        }
    }

    private func logFreezed() {
        let key = selectedKey
        if statuses[key] != .learned, freezesUsed < maxFreezes {
            if statuses[key] != .freezed {
                freezesUsed += 1
            }
            statuses[key] = .freezed
        }
    }
}

// Edit Goal Sheet now edits a binding goal, and notifies parent on save
private struct EditGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goal: String
    var onSave: () -> Void = {}

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Your goal", text: $goal)
                }
                Button("Save") {
                    onSave()
                    dismiss()
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CalendarShortcutSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "calendar")
                    .font(.system(size: 40))
                    .padding(.top, 24)
                Text("Calendar Shortcut")
                    .font(.headline)
                Text("This could open a full-screen calendar or jump to today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview {
    ActivityScreen()
}
