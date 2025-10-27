//
//  ActivityPageView.swift
//  P1
//
//  Created by Norah Abdulkairm on 30/04/1447 AH.
//


import SwiftUI

// MARK: - Main View

struct ActivityPageView: View {
    @State private var selectedDate: Date = Date() // اليوم المختار في التقويم
    @State private var daysInMonth: [Date] = [] // أيام الشهر لعرضها في التقويم
    
    // دالة لحساب الأيام في الشهر الحالي
    private func setupCalendarDates() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components) else { return }
        
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        daysInMonth = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
            
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // خلفية سوداء
            
            VStack(spacing: 0) {
                // Header
                HeaderView()
                    .padding(.bottom, 20)
                
                // Calendar View
                CalendarView(selectedDate: $selectedDate, daysInMonth: daysInMonth)
                    .padding(.bottom, 30)
                
                // Stats Cards
                HStack(spacing: 15) {
                    StatCardView(title: "Days Learned", value: "3", icon: "cube.fill", color: .teal)
                    StatCardView(title: "Day Freezed", value: "1", icon: "snowflake", color: .blue)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                // Main Action Button (Log as Learned)
                MainActionButton()
                    .padding(.bottom, 20)
                
                // Secondary Action Button (Log as Freezed)
                SecondaryActionButton()
                    .padding(.bottom, 20) // مسافة عن الجزء السفلي
                
                Spacer() // يدفع المحتوى للأعلى
                
                // Footer text
                Text("1 out of 2 freezes used")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            setupCalendarDates() // تهيئة الأيام عند ظهور الصفحة
        }
    }
}

// MARK: - Header Component

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "square.grid.2x2.fill")
                .foregroundColor(.gray)
            Image(systemName: "bell.fill")
                .foregroundColor(.gray)
                .padding(.leading, 10)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Calendar Component

struct CalendarView: View {
    @Binding var selectedDate: Date
    let daysInMonth: [Date] // الأيام الفعلية للشهر
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 15) {
            // Month Navigation (October 2025)
            HStack {
                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
            }
            .padding(.horizontal)
            
            // Weekday Headers (SUN, MON, TUE...)
            HStack {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Days Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // عرض الأيام قبل الشهر الحالي (للمحاكاة)
                    ForEach(0..<20, id: \.self) { i in
                        DayCell(day: (10 + i) % 30 + 1, isSelected: false, isCurrentMonth: false)
                    }
                    
                    // الأيام الفعلية في الشهر
                    ForEach(daysInMonth, id: \.self) { date in
                        DayCell(
                            day: calendar.component(.day, from: date),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: true
                        )
                    }
                    
                    // عرض الأيام بعد الشهر الحالي (للمحاكاة)
                    ForEach(0..<7, id: \.self) { i in
                        DayCell(day: (25 + i) % 30 + 1, isSelected: false, isCurrentMonth: false)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // تنسيق عرض الشهر والسنة
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Day Cell Component (for Calendar)

struct DayCell: View {
    let day: Int
    let isSelected: Bool
    let isCurrentMonth: Bool
    
    var body: some View {
        Text("\(day)")
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(isSelected ? .black : (isCurrentMonth ? .white : .gray.opacity(0.6)))
            .frame(width: 35, height: 35)
            .background(
                Circle()
                    .fill(isSelected ? Color.orange : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isCurrentMonth ? Color.gray.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Stat Card Component

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.15))
        .cornerRadius(15)
    }
}

// MARK: - Main Action Button (Circle)

struct MainActionButton: View {
    var body: some View {
        Button(action: {
            // قم بتنفيذ الإجراء عند الضغط على الزر (مثلاً تسجيل التعلم)
            print("Log as Learned Tapped!")
        }) {
            ZStack {
                Circle()
                    .fill(Color.orange) // لون الخلفية البرتقالي للدائرة
                    .frame(width: 180, height: 180)
                    // اللمعة على حدود الدائرة (كما في التصميم الأصلي)
                    .overlay(
                        Circle()
                            .stroke(Color.clear, lineWidth: 0)
                            .shadow(color: Color.white.opacity(0.8), radius: 15)
                            .shadow(color: Color.yellow.opacity(0.7), radius: 10)
                    )
                
                Text("Log as\nLearned")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Secondary Action Button

struct SecondaryActionButton: View {
    var body: some View {
        Button(action: {
            // قم بتنفيذ الإجراء عند الضغط على الزر
            print("Log as Freezed Tapped!")
        }) {
            Text("Log as Freezed")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.teal) // اللون التركوازي
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.teal, lineWidth: 2) // حدود تركوازية
                )
        }
        .padding(.horizontal, 40) // مسافة جانبية للزر
    }
}


// MARK: - Preview Provider

struct ActivityPageView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPageView()
            .preferredColorScheme(.dark) // لضمان الخلفية الداكنة في المعاينة
    }
}
