//
//  SwitchCell.swift
//  BKD Scanner
//
//  Created on 16/03/21.
//

import UIKit

public protocol SliderCellDelegate: AnyObject {
    func sliderCell(_ cell: SliderCell, didChangeValue: Float)
}

public class SliderCell: UITableViewCell {
    
    static let IDENTIFIER = "SliderCell"
    open weak var delegate: SliderCellDelegate?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    public override func awakeFromNib() {
        setUpAppearance()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpAppearance()
    }
    
    private func setUpAppearance() {
        slider?.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: [.touchUpInside, .touchUpOutside])
        slider?.addTarget(self, action: #selector(sliderValueDidChangeContinuous(_:)), for: .valueChanged)

        label?.numberOfLines = 0
        valueLabel?.numberOfLines = 0
        selectionStyle = .none
    }
    
    @objc
    private func sliderValueDidChange(_ sender: UISlider) {
        let value = Int(slider.value)
        valueLabel.text = value > 0 ? value.description : "∞"
        delegate?.sliderCell(self, didChangeValue: sender.value)
    }
    
    @objc
    private func sliderValueDidChangeContinuous(_ sender: UISlider) {
        let value = Int(slider.value)
        valueLabel.text = value > 0 ? value.description : "∞"
    }

}
