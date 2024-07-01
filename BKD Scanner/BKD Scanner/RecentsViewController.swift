//
//  TableViewController.swift
//  BKD Scanner
//
//  Created on 08/03/21.
//

import UIKit
import CoreData

class RecentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let SECTION_HEADER_HEIGHT = CGFloat(80)
    private static let twoDSymbologies = ["Aztec", "QR", "PDF", "Datamatrix"]
    
    @IBOutlet weak var tableView: UITableView!
    var scanLogs: [Date: [ScanLog]] = [:]
    private let SETTINGS_SEGUE_IDENTIFIER = "RecentToSettingsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Recent Scans"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        scanLogs = CoreDataHelper.loadScans()
        
        tableView.isHidden = scanLogs.isEmpty
        
        if (scanLogs.isEmpty) {
            self.hideTableAndTrashIcon()
        } else {
            let exportItem = UIAction(
                title: "Export to csv",
                image: nil
            ) { [weak self] (_) in
                self?.exportToCsvAction()
            }
            
            let removeAllLogsItem = UIAction(
                title: "Remove all",
                image: nil,
                attributes: .destructive
            ) { [weak self] (_) in
                self?.removeAllLogsAction()
            }
            
            let menu = UIMenu(
                title: "Menu",
                children: [
                    exportItem,
                    removeAllLogsItem
                ]
            )
            
            let propertiesButton = UIBarButtonItem(
                title: nil,
                image: UIImage(systemName: "gearshape"),
                primaryAction: nil,
                menu: menu
            )
            navigationItem.rightBarButtonItem = propertiesButton
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SETTINGS_SEGUE_IDENTIFIER  {
            guard let settingsViewController = segue.destination as? SettingsViewController
            else { return }
            
            settingsViewController.config = ConfigManager.shared.ffaConfig
        } 
    }

    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        scanLogs.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = self.keyForSection(section: section)
        return scanLogs[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsCell", for: indexPath) as UITableViewCell
        
        let scanLog = scanLogAtIndex(indexPath: indexPath)
        
        cell.textLabel?.text = scanLog?.value
        cell.detailTextLabel?.text = scanLog?.symbology
        
        let imageName = self.isOneD(symbology: scanLog?.symbology) ? "ico-recent-2d" : "ico-recent-1d"
        cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = .white
        cell.imageView?.backgroundColor = AppColor.brand.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        action == #selector(copy(_:))
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let cell = tableView.cellForRow(at: indexPath)
            let pasteboard = UIPasteboard.general
            pasteboard.string = cell?.textLabel?.text
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let date = self.keyForSection(section: section)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        
        let label = UILabel(frame: CGRect(x: 14, y: SECTION_HEADER_HEIGHT - 30, width: self.view.frame.width, height: 20))
        label.text = formatter.string(from: date)
        label.textColor = #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)

        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SECTION_HEADER_HEIGHT))
        view.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9215686275, blue: 0.9490196078, alpha: 1)
        view.addSubview(label)
        
        return view
    }
        
    private func keyForSection(section: Int) -> Date {
        return Array(scanLogs.keys).sorted() { $0 > $1 }[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let scanLog = self.scanLogAtIndex(indexPath: indexPath) else { return }
        
        let vc = ResultDetailsViewController(resultDetailsType: .scanLog(scanLog: scanLog))
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        present(vc, animated: false)
    }
    
    func showResultAlert(symbology: String, value: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let resultAlert = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return }
        resultAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        resultAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        resultAlert.resultText = NSAttributedString(string: value)
        resultAlert.resultTitle = symbology
        resultAlert.isRecentsMode = true
        resultAlert.onOkBlock = {
            self.tableView.clearSelection()
        }
        
        self.present(resultAlert, animated: true, completion: nil)
    }

    private func scanLogAtIndex(indexPath: IndexPath) -> ScanLog? {
        let key = self.keyForSection(section: indexPath.section)
        return scanLogs[key]?[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let scanLog = scanLogAtIndex(indexPath: indexPath)
            CoreDataHelper.deleteScanLog(scanLog: scanLog)
        
            let key = self.keyForSection(section: indexPath.section)
            scanLogs[key]?.remove(at: indexPath.row)
            
            if (scanLogs[key]?.isEmpty ?? false) {
                scanLogs.removeValue(forKey: key)
                //TODO: Test this with multiple sections
                tableView.deleteSections([indexPath.section], with: .fade)
                
                if (scanLogs.isEmpty) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.hideTableAndTrashIcon()
                    }
                }
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    private func exportToCsvAction() {
        BKDUtils.exportToCsvFrom(self)
    }
    
    private func removeAllLogsAction() {
        let alertController = UIAlertController.init(title: nil, message: "This action permanently deletes all recent scans", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction.init(title: "Delete all", style: .destructive, handler: { (UIAlertAction) in
            self.dismiss(animated: true) {
                CoreDataHelper.deleteAllScanLogs()
                self.hideTableAndTrashIcon()
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
        
    private func hideTableAndTrashIcon() {
        self.tableView.isHidden = true
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func isOneD(symbology: String?) -> Bool {
        guard let symbology = symbology else {
            return false
        }

        for twoDSymbology in RecentsViewController.twoDSymbologies {
            if symbology.contains(twoDSymbology) {
                return true
            }
        }
        
        return false
    }
}

extension RecentsViewController: ResultDetailsViewControllerDelegate {
    
    func didRequestOpenSettings() {
        performSegue(withIdentifier: SETTINGS_SEGUE_IDENTIFIER, sender: self)
    }
    
    func didTap(action: ResultDetailsAction) {
        // TODO: - 
    }
    
}
