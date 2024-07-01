//
//  SwitchCell.swift
//  BKD Scanner
//
//  Created on 16/03/21.
//

import UIKit

public protocol SwitchCellDelegate: AnyObject {
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool)
}

public class SwitchCell: UITableViewCell, Configurable {
    
    static let IDENTIFIER = "SwitchCell"
    open weak var delegate: SwitchCellDelegate?
    private var additionalSettingsIndicator: UIImageView?
    
    public private(set) lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(SwitchCell.didToggleSwitch(_:)), for: .valueChanged)
        return control
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpAppearance()
    }
    
    
    private func setUpAppearance() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        accessoryView = switchControl
        selectionStyle = .none
        
        addAdditinalSettingsIndicatorView()
    }
    
    private func addAdditinalSettingsIndicatorView() {
        let indicatorWidth = Int(frame.size.height - 14)
        self.additionalSettingsIndicator = UIImageView(frame: CGRect(x: Int(frame.size.width - 53), y: (Int(frame.size.height) - indicatorWidth) / 2, width: indicatorWidth, height: indicatorWidth))
        self.additionalSettingsIndicator!.isHidden = true
        self.additionalSettingsIndicator!.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        self.additionalSettingsIndicator!.tintColor = UIColor.black
        self.additionalSettingsIndicator!.image = UIImage(named: "ic_additional_settings")
        self.addSubview(self.additionalSettingsIndicator!)
    }
    
    func configure(with row: Row) {
        if let row = row as? SwitchRow {
            switchControl.isOn = row.isOn
            textLabel?.text = row.title
            isUserInteractionEnabled = row.isCellClickable
            contentView.alpha = row.isCellClickable ? 1 : 0.6
            textLabel?.textColor = row.isCellClickable ? .black : .systemGray.withAlphaComponent(0.7)
            switchControl.isEnabled = row.isCellClickable
            updateAdditionalSettingsIndicator(row: row)
        }
    }
    
    @objc
    private func didToggleSwitch(_ sender: UISwitch) {
        delegate?.switchCell(self, didToggleSwitch: sender.isOn)
    }
 
    func updateAdditionalSettingsIndicator(row: SwitchRow) {
        additionalSettingsIndicator?.isHidden = !(row.hasAdditionalSettings && row.isOn)
    }
}
