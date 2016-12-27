//
//  DataController.swift
//  TtroCurrencyCalculator
//
//  Created by Farid on 12/11/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import Foundation
import CoreData
import PayWandModelProtocols
import TtroCountryPicker

class DataController {
    static let sharedInstance = DataController()
    
    var managedObjectContext: NSManagedObjectContext
    
    var countries : [CountryMO]!
    var countryCodes = [String : String]()
    
    let countryEntityName = "Country"
    
    
    //var verificationCode = ""
    
    init() {
        
        // This resource is the same name as your xcdatamodeld contained in your project.
        
        guard let modelURL = Bundle(for: DataController.self).url(forResource: "CurrencyCalculator", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                                                                                  NSInferMappingModelAutomaticallyOption: true])
            DispatchQueue.global(qos: .background).async {
//                self.initCurrencyList()
//                self.initTransactionTypeList()
//                self.initAccountTypeList()
            }
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func addCountry (_ id : Int, name : String, phoneCode : String, code : String, currency : String = "USD", saveNow : Bool = true){
        let country = NSEntityDescription.insertNewObject(forEntityName: countryEntityName, into: self.managedObjectContext) as! CountryMO
        country.name = name
        country.id = NSNumber(value: id)
        country.phoneCode = phoneCode
        country.code = code
        country.currency = currency
//        country.countryStates = Set<StateMO>(states)
        if (saveNow){
            saveData()
        }
    }
    
    func fetchCountry(_ name : String? = nil, id : Int = -1, code : String? = nil) -> [CountryMO]{
        let moc = managedObjectContext
        
        let fetchRequest = CountryMO.fetchRequest()
        if (name != nil){
            fetchRequest.predicate = NSPredicate(format: "name == %@", name!)
        }
        if (code != nil){
            fetchRequest.predicate = NSPredicate(format: "code == %@", code!)
        }
        if (id != -1){
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
        }
        do {
            let countries = try moc.fetch(fetchRequest) as! [CountryMO]
            return countries
        } catch {
            fatalError("Failed to fetch city: \(error)")
        }
    }
    
    func loadCountries(names : [String : String], currencies : [String : String], phoneCodes : [String:String]){
        
        for key in names.keys {
            if (fetchCountry(names[key]).count == 0){
                
            }
        }
    }
    
    func saveData(){
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}

class CountryMO: NSManagedObject {
    
    @NSManaged var name: String?
    @NSManaged var id: NSNumber
    @NSManaged var phoneCode: String
    @NSManaged var code : String
    @NSManaged var currency : String
    var firstLetter : String {
        return (self.code as NSString).substring(to: 1)
    }
}

extension DataController : MICountryPickerDataSource, TtroCurrencyCalculatorVCDataSource {
    func setFRCPredicate(countryFRC fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, countryInfo: CountryProtocol) {
        if (countryInfo.name != nil){
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", countryInfo.name)
        } else if (countryInfo.phoneCode != nil) {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "phoneCode beginswith %@", countryInfo.phoneCode)
        }
    }

    func country(_ country : CountryProtocol, result : NSFetchRequestResult) {
        if let countryMO = result as? CountryMO {
            country.code = countryMO.code
            country.currency = countryMO.currency
            country.id = countryMO.id
            country.name = countryMO.name ?? ""
            country.phoneCode = countryMO.phoneCode
        }
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CountryMO.fetchRequest()
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "code", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "firstLetter", cacheName: nil)
    }
//    
//    func countryPicker(addCountries countryNames: [String : String], countryCurrencies: [String : String]) {
//        for key in countryNames.keys {
//            DataController.sharedInstance.addCountry(0, name: countryNames[key] ?? "", phoneCode: "", code: key, currency: countryCurrencies[key] ?? "USD", saveNow: false)
//        }
//        saveData()
//    }
    
    func countryPicker(refreshCountries picker : MICountryPicker) {
        guard DataController.sharedInstance.fetchCountry().count == 0 else { //no refresh is needed
            return
        }
        ServerConnection.sharedInstance.getCountryNames { (data, connectionState, type) in
            if let countries = data as? GenericResponse {
                let countryNames = countries.dict
                ServerConnection.sharedInstance.getCountryCurrencies(callback: { (data, connectionState, type) in
                    if let countryCurrencies = (data as? GenericResponse)?.dict {
                        for key in countryNames.keys {
                            self.addCountry(0, name: countryNames[key] ?? "", phoneCode: "", code: key, currency: countryCurrencies[key] ?? "USD", saveNow: false)
                        }
                        self.saveData()
                    }
                })
            }
        }
    }
    
//    func countryPicker(numberOfCountries picker: MICountryPicker) -> Int {
//        return DataController.sharedInstance.fetchCountry().count
//    }
}
