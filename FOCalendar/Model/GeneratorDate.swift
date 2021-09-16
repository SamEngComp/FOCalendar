import Foundation

protocol GeneratorDate {
    func generateMonthData(baseDate: Date, completion: (Result<MonthData, ModelError>) -> Void)
    func generateDay(dayOffset: Int, baseDate: Date, isWithinDisplayedMonth: Bool) -> Day
    func generateStartOfNextMonth(firstDayOfDisplayedMonth: Date) -> [Day]
}
