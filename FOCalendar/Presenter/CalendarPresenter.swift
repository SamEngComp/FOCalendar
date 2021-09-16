import Foundation

protocol CalendarViewDelegate: NSObjectProtocol {
    func generateDaysInMonth(days: [Day])
    func generateDaysInWeek(days: [Day])

    func alertPresent(error: Error)
}

class CalendarPresenter {
    
    private let remoteGeneratorDate: GeneratorDate
    private weak var viewDelegate: CalendarViewDelegate?
    private let calendar = Calendar(identifier: .gregorian)
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    init(remoteGeneratorDate: GeneratorDate) {
        self.remoteGeneratorDate = remoteGeneratorDate
    }
    
    func setViewDelegate(viewDelegate: CalendarViewDelegate) {
        self.viewDelegate = viewDelegate
    }
    
    func generateDaysInMonth(for baseDate: Date) {
        remoteGeneratorDate.generateMonthData(baseDate: baseDate) { result in
            switch result {
            case .success(let monthData):
                let numberOfDaysInMonth = monthData.numberOfDays
                let offsetInInitialRow = monthData.firstDayWeekday
                let firstDayOfMonth = monthData.firstDay

                var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow)).map { day in
                        let isWithinDisplayedMonth = day >= offsetInInitialRow
                        let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)

                    return self.remoteGeneratorDate.generateDay(dayOffset: dayOffset,
                                                          baseDate: firstDayOfMonth,
                                                          isWithinDisplayedMonth: isWithinDisplayedMonth)
                }
                
                days += self.remoteGeneratorDate.generateStartOfNextMonth(firstDayOfDisplayedMonth: firstDayOfMonth)
                viewDelegate?.generateDaysInMonth(days: days)
            case .failure( let error):
                viewDelegate?.alertPresent(error: error)
            }
        }
    }
    
    func generateDaysInWeek(for firstDayWeek: Date, calendar: Calendar) {
        let firstDayWeekValue = calendar.component(.weekday, from: firstDayWeek)

        let days: [Day] = (1..<8).map { day in
                let isWithinDisplayedMonth = day >= firstDayWeekValue
                let dayOffset = isWithinDisplayedMonth ? day - firstDayWeekValue : -(firstDayWeekValue - day)

            return self.remoteGeneratorDate.generateDay(dayOffset: dayOffset,
                                                  baseDate: firstDayWeek,
                                                  isWithinDisplayedMonth: true)
        }
        viewDelegate?.generateDaysInWeek(days: days)
    }

}
