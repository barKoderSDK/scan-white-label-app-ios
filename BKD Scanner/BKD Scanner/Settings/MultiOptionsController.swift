//
//  MultiOptionsController.swift
//  BKD Scanner
//
//  Created on 18/03/21.
//

import UIKit

class MultiOptionsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var navigationRow: NavigationRow?
    var type: MultiOptionsType = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = navigationRow?.title
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if (navigationRow?.additionalOptions.count ?? 0) > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return navigationRow?.options.count ?? 0
        } else if section == 1 {
            return navigationRow?.additionalOptions.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiOptionsCell", for: indexPath)
        
        if indexPath.section == 0 {
            if let option = navigationRow?.options[indexPath.row] {
                cell.textLabel?.text = option
                cell.accessoryType = navigationRow?.selectedOptionIndex == indexPath.row ? .checkmark : .none
            }
        } else if indexPath.section == 1 {
            if let option = navigationRow?.additionalOptions[indexPath.row] {
                cell.textLabel?.text = option
                cell.accessoryType = .none
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            navigationRow?.selectedOptionIndex = indexPath.row
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch type {
        case .continuesScanningExplanation:
            if section == 0 {
                return "Duplicate Delay: The amount of time the decoder should pause before recognizing a distinct barcode sample as a separate item.\n\nUnlimited - Once a barcode is recognized, the decoder will never try to decode the same barcode again"
            }
        case .other:
            break
        }
        
        return nil
    }

}

enum MultiOptionsType {
    case continuesScanningExplanation
    case other
}
