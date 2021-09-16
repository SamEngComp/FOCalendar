import Foundation

class RemoteGeneratorDate: GeneratorDate {
    private let calendar = Calendar(identifier: .gregorian)
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    
    func generateMonthData(baseDate: Date, completion: (Result<MonthData, ModelError>) -> Void) {
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: baseDate)?.count,
              let firstDayOfMonth = calendar.date (
                from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            completion(.failure(.monthGeneration))
            return
        }

        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let monthData = MonthData(numberOfDays: numberOfDaysInMonth,
                                 firstDay: firstDayOfMonth,
                                 firstDayWeekday: firstDayWeekday)

        completion(.success(monthData))
    }
    
    func generateDay(dayOffset: Int, baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        return Day(date: date,
                   number: dateFormatter.string(from: date),
                   isSelected: calendar.isDate(date, inSameDayAs: Date()),
                   isWithinDisplayedMonth: isWithinDisplayedMonth)
    }
    
    func generateStartOfNextMonth(firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                 to: firstDayOfDisplayedMonth) else {
            return []
        }

        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }

        let days: [Day] = (1...additionalDays).map {
                generateDay(dayOffset: $0,
                            baseDate: lastDayInMonth,
                            isWithinDisplayedMonth: false)
        }

        return days
    }
}
