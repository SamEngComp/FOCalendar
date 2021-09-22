import UIKit

enum SelectionViewType {
    case begin
    case medium
    case last
    case normal
}

class CalendarCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CalendarCollectionViewCell.self)
    
    private var selectNumberColor: UIColor?
    private var isRange: Bool?
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = (self.frame.size.height*0.7)/2
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        
        view.backgroundColor = .white
        
        return view
    }()
    
    private lazy var helperViewRight: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = (self.frame.size.height*0.7)/2
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        
        view.backgroundColor = .white
        
        return view
    }()
    
    private lazy var helperViewLeft: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.0
        view.backgroundColor = .white
        
        return view
    }()

    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()

    var day: Day? {
        didSet {
            guard let day = day else { return }

            numberLabel.text = day.number
            //accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        //isAccessibilityElement = true
        //accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hierarchyView() {
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        
        calendarCellConstraints()
    }
    
    func calendarCellConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionBackgroundView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            selectionBackgroundView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}

extension CalendarCollectionViewCell {
    
  func updateSelectionStatus() {
    guard let day = day else { return }

    if day.isSelected {
      applySelectedStyle()
    } else {
      applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
    }
  }
    
  func applySelectedStyle() {
    //accessibilityTraits.insert(.selected)
    //accessibilityHint = nil
    numberLabel.textColor = day?.isSelected ?? false ? selectNumberColor ?? .white : numberLabel.textColor
    selectionBackgroundView.isHidden = day?.isSelected ?? false ? false : true
    numberLabel.textColor = isRange ?? false ? selectNumberColor ?? .white : numberLabel.textColor
  }

  func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
    //accessibilityTraits.remove(.selected)
    //accessibilityHint = "Tap to select"

    numberLabel.textColor = isWithinDisplayedMonth ? numberLabel.textColor : numberLabel.textColor.withAlphaComponent(0.5)
    selectionBackgroundView.isHidden = true
  }
}

extension CalendarCollectionViewCell {
    
    func setupSelectionBackgroundView(for type: SelectionViewType) {
        switch type {
        case .begin:
            selectionBackgroundView.layer.borderWidth = 0
            selectionBackgroundView.layer.masksToBounds = false
        
            selectionBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            selectionBackgroundView.layer.cornerRadius = (self.frame.size.height*0.7)/2
            selectionBackgroundView.layer.isHidden = true
            //selectionBackgroundView.backgroundColor = .clear
        case .medium:
            selectionBackgroundView.layer.borderWidth = 0
            selectionBackgroundView.layer.cornerRadius = 0
            //selectionBackgroundView.backgroundColor = .clear
        case .last:
            selectionBackgroundView.layer.borderWidth = 0
            selectionBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            selectionBackgroundView.layer.cornerRadius = (self.frame.size.height*0.7)/2
            //selectionBackgroundView.backgroundColor = .clear
        case .normal:
            selectionBackgroundView.layer.borderWidth = 0
            selectionBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner,.layerMinXMinYCorner, .layerMinXMaxYCorner]
            selectionBackgroundView.layer.cornerRadius = (self.frame.size.height*0.7)/2
        }
    }
    
    func startCell() {
        hierarchyView()
    }
    
    func setIsRange(for isRange: Bool) {
        self.isRange = isRange
    }
    
    func setCellFont(font: UIFont?) {
        if let font = font {
            numberLabel.font = font
        }
    }
    
    func setCellTextColor(color: UIColor?) {
        if let color = color {
            numberLabel.textColor = color
        }
    }
    
    func setSelectionBackgroundColor(color: UIColor?) {
        if let color = color {
            selectionBackgroundView.backgroundColor = color
        }
    }
    
    func setSelectionBorderColor(color: UIColor?) {
        if let color = color {
            selectionBackgroundView.layer.borderColor = color.cgColor
        }
    }
    
    func setSelectionCellTextColor(color: UIColor?) {
        if let color = color {
            selectNumberColor = color
        }
    }
}
