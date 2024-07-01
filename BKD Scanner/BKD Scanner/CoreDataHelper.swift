//
//  CoreDataHelper.swift
//  BKD Scanner
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    private static let ENTITY_NAME = "ScanLog"
    
    static func loadScans() -> [Date: [ScanLog]] {
        guard let managedContext = getManagedContext() else { return [:] }
        let fetchRequest = NSFetchRequest<ScanLog>(entityName: ENTITY_NAME)
        let sortDescriptor = NSSortDescriptor(key: "dateScanned", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try managedContext.fetch(fetchRequest)
            return groupedByDay(fetchResult)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return [:]
        }
    }
    
    static func saveScanLog(value: String, symbology: String) {
        guard let managedContext = getManagedContext() else { return }
        
        let scanLog = NSEntityDescription.insertNewObject(forEntityName: ENTITY_NAME, into: managedContext) as! ScanLog
        scanLog.value = value
        scanLog.symbology = symbology
        scanLog.dateScanned = Date()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func deleteScanLog(scanLog: ScanLog?) {
        guard let managedContext = getManagedContext(), let scanLog = scanLog
        else { return }
    
        managedContext.delete(scanLog)
        saveContext(managedContext: managedContext)
    }
    
    static func deleteAllScanLogs() {
        guard let managedContext = getManagedContext() else { return }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ENTITY_NAME)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try getPersistentContainer()?.persistentStoreCoordinator.execute(deleteRequest, with: managedContext)
        } catch let error as NSError {
            print("Could not delete all scan logs. \(error), \(error.userInfo)")
        }
    }
    
    private static func getPersistentContainer() -> NSPersistentContainer? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer
    }
    
    private static func getManagedContext() -> NSManagedObjectContext? {
        return getPersistentContainer()?.viewContext
    }
    
    private static func groupedByDay(_ scanLogs: [ScanLog]) -> [Date: [ScanLog]] {
        let empty: [Date: [ScanLog]] = [:]
        return scanLogs.reduce(into: empty) { acc, cur in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: cur.dateScanned!)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
    }
    
    private static func saveContext(managedContext: NSManagedObjectContext) {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
