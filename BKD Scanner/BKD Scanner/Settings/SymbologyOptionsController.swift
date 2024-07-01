//
//  MultiOptionsController.swift
//  BKD Scanner
//
//  Created on 18/03/21.
//

import UIKit
import Barkoder
import TTRangeSlider

class SymbologyOptionsController: UIViewController, UITableViewDelegate, UITableViewDataSource, TTRangeSliderDelegate {

    var specificConfig: SpecificConfig?
    private var checksumRow: NavigationRow?
    private var expandToRow: SwitchRow?
    
    private let SECTION_HEADER_HEIGHT = CGFloat(40)
    private let SLIDER_CELL_HEIGHT = CGFloat(78)
    private let CHECKSUM_CELL_HEIGHT = CGFloat(44)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = specificConfig?.typeName()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9215686275, blue: 0.9490196078, alpha: 1)
        tableView.register(NavigationCell.self, forCellReuseIdentifier: NavigationCell.IDENTIFIER)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.IDENTIFIER)
        
        initChecksumRow()
        initExpandRow()
    }
    
    private func initChecksumRow() {
        guard let decoderType = specificConfig?.decoderType() else { return }

        if BKDUtils.hasCheckSum(decoderType: decoderType) {
            if let specificConfig = specificConfig as? Code39Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code39Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? Code11Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Single", "Double"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code11Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? MsiConfig {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Mod10", "Mod11", "Mod1010", "Mod1110", "Mod11IBM", "Mod1110IBM"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = MsiChecksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? Code25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? Interleaved25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? IATA25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? Matrix25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? Datalogic25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
            if let specificConfig = specificConfig as? COOP25Config {
                checksumRow = NavigationRow(title: "Type", selectedOptionIndex: Int(specificConfig.checksum.rawValue), options: ["Disabled", "Enabled"], onIndexChange: { (newIndex) in
                    specificConfig.checksum = Code25Checksum(rawValue: UInt32(newIndex))
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    private func initExpandRow() {
        guard let decoderType = specificConfig?.decoderType() else { return }

        if BKDUtils.hasExpandSettings(decoderType: decoderType) {
            if let specificConfig = specificConfig as? UpcEConfig {
                expandToRow = SwitchRow(
                    title: "Expand To UpcA",
                    isOn: specificConfig.expandToUPCA,
                    hasAdditionalSettings: false,
                    onSwitch: { newValue in
                        self.tableView.reloadData()
                    })
            } else if let specificConfig = specificConfig as? UpcE1Config {
                expandToRow = SwitchRow(
                    title: "Expand To UpcA",
                    isOn: specificConfig.expandToUPCA,
                    hasAdditionalSettings: true,
                    onSwitch: { newValue in
                        self.tableView.reloadData()
                    })
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Lenght
        // Checksum
        // Expand
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let decoderType = specificConfig?.decoderType() else { return 0 }
        
        switch section {
        case 0:
            return BKDUtils.hasAdditionalSymbologySettings(decoderType: decoderType) ? 1 : 0
        case 1:
            return BKDUtils.hasCheckSum(decoderType: decoderType) ? 1 : 0
        case 2:
            return BKDUtils.hasExpandSettings(decoderType: decoderType) ? 1 : 0
        default:
            fatalError("Invalid number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: RangeCell.IDENTIFIER, for: indexPath) as! RangeCell
            cell.label.text = "Length"
            let selectedMin = Float(specificConfig?.minimumLength ?? 1)
            let selectedMax = Float(specificConfig?.maximumLength ?? 100)

            cell.rangeSlider.selectedMinimum = (selectedMin != 0) ? selectedMin : 1
            cell.rangeSlider.selectedMaximum = (selectedMax != 0) ? selectedMax : 100
            cell.delegate = self
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: checksumRow!.reuseIdentifier, for: indexPath) as! NavigationCell
            cell.configure(with: checksumRow!)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.IDENTIFIER, for: indexPath) as! SwitchCell
            if let row = expandToRow {
                cell.configure(with: row)
            }
            cell.delegate = self
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let decoderType = specificConfig?.decoderType() else { return 0 }

        switch section {
        case 0:
            return BKDUtils.hasAdditionalSymbologySettings(decoderType: decoderType) ? SECTION_HEADER_HEIGHT : 0
        case 1:
            return BKDUtils.hasCheckSum(decoderType: decoderType) ? SECTION_HEADER_HEIGHT : 0
        case 2:
            return BKDUtils.hasExpandSettings(decoderType: decoderType) ? SECTION_HEADER_HEIGHT : 0
        default:
            fatalError("Invalid number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return SLIDER_CELL_HEIGHT
        case 1:
            return CHECKSUM_CELL_HEIGHT
        case 2:
            return CHECKSUM_CELL_HEIGHT
        default:
            fatalError("Invalid number of sections")
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let decoderType = specificConfig?.decoderType() else { return nil }

        let label = UILabel(frame: CGRect(x: 14, y: 0, width: self.view.frame.width, height: SECTION_HEADER_HEIGHT))
        label.textColor = #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
        
        if section == 0 {
            label.text = "Length"
        } else if section == 1 {
            label.text = "Checksum"
        } else if section == 2 {
            label.text = "Additional Settings"
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SECTION_HEADER_HEIGHT))
        view.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9215686275, blue: 0.9490196078, alpha: 1)
        view.addSubview(label)
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        
        switch section {
        case 0:
            return BKDUtils.hasAdditionalSymbologySettings(decoderType: decoderType) ? view : emptyView
        case 1:
            return BKDUtils.hasCheckSum(decoderType: decoderType) ? view : emptyView
        case 2:
            return BKDUtils.hasExpandSettings(decoderType: decoderType) ? view : emptyView
        default:
            fatalError("Invalid number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MultiOptionsSegue", sender: checksumRow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let navigationRow = sender as? NavigationRow,
            let multiOptionsController = segue.destination as? MultiOptionsController
        else {
            return
        }
        
        multiOptionsController.navigationRow = navigationRow
    }
    
    fileprivate func showToast(message: String) {
        let alertDisapperTimeInSeconds = 2.0
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertDisapperTimeInSeconds) {
            alert.dismiss(animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        clearSelection()
    }

    private func clearSelection() {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

}

// MARK: - TTRangeSliderDelegate
extension SymbologyOptionsController {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        specificConfig?.setLengthRangeWithMinimum(Int32(selectedMinimum), maximum: Int32(selectedMaximum))
    }
}

extension SymbologyOptionsController: SwitchCellDelegate {
    
    func switchCell(_ cell: SwitchCell, didToggleSwitch isOn: Bool) {
        guard let decoderType = specificConfig?.decoderType() else { return }

        if BKDUtils.hasExpandSettings(decoderType: decoderType) {
            if let specificConfig = specificConfig as? UpcEConfig {
                specificConfig.expandToUPCA = isOn
            } else if let specificConfig = specificConfig as? UpcE1Config {
                specificConfig.expandToUPCA = isOn
            }
        }
    }
    
}
