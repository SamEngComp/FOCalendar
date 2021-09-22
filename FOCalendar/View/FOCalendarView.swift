import Foundation
import UIKit
public protocol FOCalendarDelegate: AnyObject {
    func captureCell(date: Date?)
}

public enum ModeCalendarView {
    case compact
    case expand
}

public class FOCalendarView: UIView {
    private var calendarDelegate: FOCalendarDelegate?
    private var presenter: CalendarPresenter?
    private let headerView = CalendarHeaderView()
    
    private var days: [Day]?
    private var daysCheckAll: Set<Date>?
    private var daysCheckDisplay = [Int]()
    private var cellFont: UIFont?
    private var cellTextColor: UIColor?
    private var selectionCellTextColor: UIColor?
    private var selectionBackgroundColor: UIColor?
    private var selectionRangeBackgroundColor: UIColor?
    private var selectionRangeBorderColor: UIColor?
    private var selectionRangeTextColor: UIColor?
    private var modeType: ModeCalendarView?
    
    private var indexHelper = 0
    private var initialElement = false
    private let calendar = Calendar(identifier: .gregorian)

    private var baseDate: Date! {
        didSet {
            presenter?.generateDaysInMonth(for: baseDate)
            headerView.baseDate = baseDate
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
        collectionView.dataSource   = self
        collectionView.delegate     = self
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        hierarchyView()
        setupConstraints()
        self.presenter = CalendarPresenter(remoteGeneratorDate: RemoteGeneratorDate())
        self.baseDate = Date()
        self.headerView.setDelegate(delegate: self)
        self.presenter?.setViewDelegate(viewDelegate: self)
        self.presenter?.generateDaysInMonth(for: baseDate)
        //self.collectionView.reloadData()
        self.modeType = .compact
        setupCalendarView(modeCalendar: .compact)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var numberOfWeeksInBaseDate: Int {
      calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }

    func hierarchyView() {
        addSubview(headerView)
        addSubview(collectionView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension FOCalendarView: CalendarViewDelegate {
    func generateDaysInWeek(days: [Day]) {
        self.days = days
        collectionView.reloadData()
    }
    
    func generateDaysInMonth(days: [Day]) {
        self.days = days
        collectionView.reloadData()
    }
    
    func alertPresent(error: Error) {
        
    }
}

extension FOCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier, for: indexPath) as? CalendarCollectionViewCell else { fatalError() }
        let calendar = Calendar.current
        
        var day = days?[indexPath.row]
        var type: SelectionViewType = .normal
        let comp = calendar.component(.day, from: day?.date ?? Date())
       
        cell.setSelectionCellTextColor(color: selectionCellTextColor)
        cell.setSelectionBackgroundColor(color: selectionBackgroundColor)
        cell.setCellTextColor(color: cellTextColor)
        if indexHelper < daysCheckDisplay.count {
            if daysCheckDisplay[indexHelper] == comp {
                cell.setSelectionCellTextColor(color: selectionRangeTextColor)
                cell.setSelectionBorderColor(color: selectionRangeBorderColor)
                cell.setSelectionBackgroundColor(color: selectionRangeBackgroundColor)
                cell.setIsRange(for: true)
                //print(daysCheckDisplay[indexHelper], comp)
                if indexHelper < daysCheckDisplay.count-1 {
                    if daysCheckDisplay[indexHelper] == daysCheckDisplay[indexHelper+1] - 1 {
                        if initialElement == false {
                            type = .begin
                            initialElement = true
                        } else if initialElement == true {
                            type = .medium
                            let dayTest = calendar.component(.day, from: Date())
                            if dayTest == daysCheckDisplay[indexHelper+1] {
                                type = .last
                            }
                        }
                    } else {
                        let dayTest = calendar.component(.day, from: Date())
                        type = .last
                        if dayTest == daysCheckDisplay[indexHelper] {
                            cell.setSelectionBackgroundColor(color: selectionBackgroundColor)
                            cell.setSelectionCellTextColor(color: selectionCellTextColor)
                        }
                        initialElement = false
                    }
                } else {
                    let dayTest = calendar.component(.day, from: Date())
                    type = .last
                    if dayTest == daysCheckDisplay[indexHelper] {
                        type = .normal
                        cell.setSelectionBackgroundColor(color: selectionBackgroundColor)
                        cell.setSelectionCellTextColor(color: selectionCellTextColor)
                    }
                    initialElement = false
                }
                day?.isSelected = true
                indexHelper += 1
            }
            
        }

        cell.setCellFont(font: cellFont)
        cell.setupSelectionBackgroundView(for: type)
        cell.day = day
        cell.startCell()
        return cell
    }
}

extension FOCalendarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell else { return }
        calendarDelegate?.captureCell(date: cell.day?.date)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
      }
}

extension FOCalendarView: CalendarHeaderViewDelegate {
    func didTapPreviousMonthButton(sender: UIButton) {
        let date = self.calendar.date(
            byAdding: .month,
            value: -1,
            to: self.baseDate
        ) ?? self.baseDate
        
        setupDaysCheckAll(date: date ?? Date())
        self.baseDate = date
        self.indexHelper = 0
        self.collectionView.reloadData()
    }
    
    func didTapNextMonthButton(sender: UIButton) {
        let date = self.calendar.date(
            byAdding: .month,
            value: 1,
            to: self.baseDate
        ) ?? self.baseDate
        
        setupDaysCheckAll(date: date ?? Date())
        self.baseDate = date
        self.indexHelper = 0
        self.collectionView.reloadData()
    }
}

extension FOCalendarView {
    private func setupDaysCheckAll(date: Date) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        if let daysCheckAll: Set<Date> = daysCheckAll {
            daysCheckDisplay.removeAll()
            daysCheckAll.forEach { date in
                let monthDate = calendar.component(.month, from: date)
                if month == monthDate {
                    let day = calendar.component(.day, from: date)
                    daysCheckDisplay.append(day)
                }
            }
        }
        daysCheckDisplay.sort()
    }
    
    public func setCalendarDelegate(_ delegate: FOCalendarDelegate) {
        self.calendarDelegate = delegate
    }
    
    public func getModeCalendarView() -> ModeCalendarView {
        return modeType ?? .compact
    }
    
    public func setModeCalendarView(for mode: ModeCalendarView) {
        switch mode {
        case .compact:
            headerView.titleMonthLabel.isHidden = true
            headerView.nextMonthButton.isHidden = true
            headerView.previousMonthButton.isHidden = true
            
            let dateIntial = Date().previous(.monday)
            
            modeType = .compact
            baseDate = Date()
            setupDaysCheckAll(date: Date())
            let dayInitialWeek = calendar.component(.day, from: dateIntial)
            indexHelper = 0
            daysCheckDisplay.forEach { dayDisplay in
                if dayInitialWeek > dayDisplay {
                    indexHelper += 1
                }
            }
            indexHelper = indexHelper == 0 ? 0 : indexHelper - 1
            initialElement = false
            presenter?.generateDaysInWeek(for: dateIntial, calendar: calendar)
        case .expand:
            headerView.titleMonthLabel.isHidden = false
            headerView.nextMonthButton.isHidden = false
            headerView.previousMonthButton.isHidden = false
            modeType = .expand
            baseDate = Date()
            
            setupDaysCheckAll(date:  Date())
            indexHelper = 0
            initialElement = false
            presenter?.generateDaysInMonth(for: baseDate)
        }
    }
    
    public func setTypeCalendar(_ type: ModeCalendarView) {
        setModeCalendarView(for: type)
    }
    
    public func setDays(_ days: Set<Date>) {
        daysCheckAll = days
        setupDaysCheckAll(date: Date())
    }
    
    public func setTitleStyle(titleFont: UIFont, titleColor: UIColor) {
        headerView.titleMonthLabel.font = titleFont
        headerView.titleMonthLabel.textColor = titleColor
        
    }
    
    public func setWeekStyle(weekStackFont: UIFont, weekStackColor: UIColor) {
        headerView.dayOfWeekLetterLabels.forEach { label in
            label.font = weekStackFont
            label.textColor = weekStackColor
        }
    }
    
    public func setCellStyle(cellFont: UIFont, cellColor: UIColor) {
        self.cellFont = cellFont
        self.cellTextColor = cellColor
    }
    
    public func setNextAndPreviousMonthColor(_ color: UIColor) {
        headerView.nextMonthButton.tintColor = color
        headerView.previousMonthButton.tintColor = color
    }
    
    public func setSelectionRangeStyle(selectionRangeBackgroundColor: UIColor,selectionRangeBorderColor: UIColor, selectionRangeTextColor: UIColor) {
        self.selectionRangeBackgroundColor = selectionRangeBackgroundColor
        self.selectionRangeBorderColor = selectionRangeBorderColor
        self.selectionRangeTextColor = selectionRangeTextColor
    }
    
    public func setSelectionCellStyle(selectionCellBackgroundColor: UIColor, selectionCellTextColor: UIColor) {
        self.selectionBackgroundColor = selectionCellBackgroundColor
        self.selectionCellTextColor = selectionCellTextColor
    }
    
    private func setupCalendarView( modeCalendar: ModeCalendarView,
                    days: Set<Date> = Set([]),
                    titleFont: UIFont = .systemFont(ofSize: 20),
                    titleColor: UIColor = .white,
                    weekStackFont: UIFont = .boldSystemFont(ofSize: 24),
                    weekStackColor: UIColor = .white,
                    nextAndPreviousMonthColor: UIColor = .white,
                    cellFont: UIFont = .systemFont(ofSize: 24),
                    cellTextColor: UIColor = .white,
                    selectionCellBackgroundColor: UIColor = .white,
                    selectionCellTextColor: UIColor = .secondaryLabel,
                    selectionRangeBackgroundColor: UIColor = .clear,
                    selectionRangeBorderColor: UIColor = .green,
                    selectionRangeTextColor: UIColor = .white) {
        daysCheckAll = days
        setupDaysCheckAll(date: Date())
        setModeCalendarView(for: modeCalendar)
        headerView.titleMonthLabel.font = titleFont
        headerView.titleMonthLabel.textColor = titleColor
        headerView.nextMonthButton.tintColor = nextAndPreviousMonthColor
        headerView.previousMonthButton.tintColor = nextAndPreviousMonthColor
        headerView.dayOfWeekLetterLabels.forEach { label in
            label.font = weekStackFont
            label.textColor = weekStackColor
        }
        self.cellFont = cellFont
        self.cellTextColor = cellTextColor
        self.selectionBackgroundColor = selectionCellBackgroundColor
        self.selectionCellTextColor = selectionCellTextColor
        self.selectionRangeBackgroundColor = selectionRangeBackgroundColor
        self.selectionRangeBorderColor = selectionRangeBorderColor
        self.selectionRangeTextColor = selectionRangeTextColor
        var str = self.headerView.dateFormatter.string(from: baseDate)
        guard let firstLetter = self.headerView.dateFormatter.string(from: baseDate).first?.uppercased() else { return }
        str.removeFirst()
        self.headerView.titleMonthLabel.text = firstLetter+str
        self.collectionView.reloadData()
    }
}
