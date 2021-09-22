import UIKit

protocol CalendarHeaderViewDelegate: AnyObject {
    func didTapPreviousMonthButton(sender: UIButton)
    func didTapNextMonthButton(sender: UIButton)
}

class CalendarHeaderView: UIView {
    
    private let dayOfWeekLetters = "STQQSSD"
    var dayOfWeekLetterLabels = [UILabel]()
    weak var delegate: CalendarHeaderViewDelegate?
    
    lazy var titleMonthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Month"
        //label.accessibilityTraits = .header
        //label.isAccessibilityElement = true
        return label
    }()
    
    lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.titleLabel?.textAlignment = .left

        if let chevronImage = UIImage(systemName: "chevron.left") {
            button.setImage(chevronImage, for: .normal)
        } else {
            button.setTitle("<", for: .normal)
        }

        button.titleLabel?.textColor = .label

        button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        return button
    }()

    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.titleLabel?.textAlignment = .right

        if let chevronImage = UIImage(systemName: "chevron.right") {
            button.setImage(chevronImage, for: .normal)
        } else {
            button.setTitle(">", for: .normal)
        }

        button.titleLabel?.textColor = .label
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var dayOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM Y")
        return dateFormatter
    }()
    
    var baseDate = Date() {
        didSet {
            var str = dateFormatter.string(from: baseDate)
            guard let firstLetter = dateFormatter.string(from: baseDate).first?.uppercased() else { return }
            str.removeFirst()
            titleMonthLabel.text = firstLetter+str
        }
    }
    
    init(){
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        hierarchyView()
        calendarHeaderConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hierarchyView() {
        addSubview(previousMonthButton)
        addSubview(nextMonthButton)
        addSubview(titleMonthLabel)
        addSubview(dayOfWeekStackView)
        
        for dayOfWeekLetter in dayOfWeekLetters {
            let dayLabel = UILabel()
            dayLabel.font = .systemFont(ofSize: 15, weight: .bold)
            dayLabel.textColor = .secondaryLabel
            dayLabel.textAlignment = .center
            dayLabel.text = "\(dayOfWeekLetter)"
            //dayLabel.isAccessibilityElement = false
            dayOfWeekLetterLabels.append(dayLabel)
            dayOfWeekStackView.addArrangedSubview(dayLabel)
        }
    }
    
    func calendarHeaderConstraints() {
        NSLayoutConstraint.activate([
            previousMonthButton.topAnchor.constraint(equalTo: topAnchor),
            previousMonthButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            nextMonthButton.topAnchor.constraint(equalTo: topAnchor),
            nextMonthButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        
            titleMonthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleMonthLabel.topAnchor.constraint(equalTo: topAnchor),
            
            dayOfWeekStackView.topAnchor.constraint(equalTo: titleMonthLabel.bottomAnchor, constant: 10),
            dayOfWeekStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayOfWeekStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setDelegate(delegate: CalendarHeaderViewDelegate) {
        self.delegate = delegate
    }

    @objc func didTapPreviousMonthButton() {
        delegate?.didTapPreviousMonthButton(sender: previousMonthButton)
    }

    @objc func didTapNextMonthButton() {
        delegate?.didTapNextMonthButton(sender: nextMonthButton)
    }

}
