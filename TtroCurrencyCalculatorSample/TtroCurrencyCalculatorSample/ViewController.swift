//
//  ViewController.swift
//  TtroCurrencyCalculatorSample
//
//  Created by Farid on 12/8/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import UIKit
import TtroCurrencyCalculator
import PayWandModelProtocols
import EasyPeasy
import CoreData
import TtroCountryPicker
import Alamofire
import Gloss

class ViewController: UIViewController {

//    var sourceCountryView : CountryView!
//    
//    var destinationCountryView : CountryView!
//    
//    var isSelectingSource = false
//    
//    var exchangeRate : Double = 0
//    
//    let countryPicker = MICountryPicker { (code, name) in
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        view.addSubview(button)
        button <- Center()
        button.setTitle("test", for: .normal)
        button.addTarget(self, action: #selector(self.onButton), for: .touchUpInside)
    }

    func onButton(){
        let calcVC = TtroCurrencyCalculatorVC()
        calcVC.dataSource = DataController.sharedInstance
        present(calcVC, animated: true, completion: nil)
    }
}


class DataController {
    static let sharedInstance = DataController()

    var managedObjectContext: NSManagedObjectContext

    var countries : [CountryMO]!
    var countryCodes = [String : String]()

    let countryEntityName = "Country"


    //var verificationCode = ""

    init() {

        // This resource is the same name as your xcdatamodeld contained in your project.

        guard let modelURL = Bundle(for: DataController.self).url(forResource: "Model", withExtension:"momd") else {
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

class Country : NSObject, CountryP {
    var name: String?
    var id: Int = 0
    var phoneCode: String?
    var code : String?
    var currency : CurrencyP?

    func updateServer(onFinish : () -> ()){

    }

    func reloadFromServer(onFinish : () -> ()){

    }

    //static func fetch(params : DataProtocol) -> DataProtocol

    func store(){

    }

    override init() {
        //self.init(coreDataObject : nil)
    }

    required init(coreDataObject : NSManagedObject?){
        if let countryMO = coreDataObject as? CountryMO {
            code = countryMO.code
            name = countryMO.name
            phoneCode = countryMO.phoneCode
            //currency = countryMO.currency
            currency = Currency(title: countryMO.currency)
            id = countryMO.id.intValue
        }
    }

    required convenience init(frcResult result : NSFetchRequestResult?){
        self.init(coreDataObject: result as? NSManagedObject)
    }
}

class Currency: NSObject, CurrencyP {
    
    var id : Int = -1
    var title : String?
    var symbol : String?
    
    func updateServer(onFinish : () -> ()) { }
    
    func reloadFromServer(onFinish : () -> ()) { }
    
    func store() { }
    
    required init(coreDataObject : NSManagedObject?) {
        
    }
    
    required init(frcResult result : NSFetchRequestResult?) {
        
    }
    
    convenience init(title : String) {
        self.init(coreDataObject : nil)
        self.title = title
    }
}

class ExchangeModel: ExchangeModelP {
    
    var currentCurrency : CurrencyP?
    var destinationCurrency : CurrencyP?
    var rate : Float = -1
    var transactionFee : Float = -1
    
    func updateServer(onFinish : () -> ()) { }
    
    func reloadFromServer(onFinish : () -> ()) { }
    
    func store() { }
    
    required init(coreDataObject : NSManagedObject?) {
    }
    
    required init(frcResult result : NSFetchRequestResult?) {
    }
    
    convenience init(rate : Float, current : Currency, destination : Currency) {
        self.init(coreDataObject : nil)
        self.currentCurrency = current
        self.destinationCurrency = destination
        self.rate = rate
    }
}

extension DataController : MICountryPickerDataSource, TtroCurrencyCalculatorVCDataSource {

    func country(countryWithNSFRResult result : NSFetchRequestResult) -> CountryP {
        return Country(frcResult: result)
    }

    func setFRCPredicate(countryFRC fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, name: String? ,isoCode : String?, phoneCode : String?, currency : String?){

    }

    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CountryMO.fetchRequest()

        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "code", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Initialize Fetched Results Controller
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "firstLetter", cacheName: nil)
    }

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
    
    func getExchangeRates(callback : @escaping ([ExchangeModelP]) -> ()) {
        ServerConnection.sharedInstance.getExchangeRate(source: "", destination: "", callback: { (data, serverConnection, type) in
            var exchangeModels = [ExchangeModelP]()
            if let exchRate = data as? ExchangeRates {
                for rate in exchRate.rates {
                    exchangeModels.append(ExchangeModel(rate: Float(rate.value), current: Currency(title : "USD"), destination: Currency(title : rate.key)))
                }
            }
            callback(exchangeModels)
        }
        )
    }
}


class ServerConnection {
    init(){

    }

    typealias onReceivingResponse = (_ data: Decodable?, _ serverConnection : Bool, _ messageType : ResponseType) -> ()

    static let sharedInstance = ServerConnection()

    let parser = ParseResponse()

    let serverURL = "http://country.io/"

    var exchangeRatesUSDBased = [String : Double]()

    //let exchangeServerURL = "http://api.fixer.io/latest?base="
    let exchangeServerURL = "https://openexchangerates.org/api/latest.json?app_id=6e461e90b94e4c5b9293643c828b4537"

    func getCountryNames(callback : @escaping onReceivingResponse){
        let actionString = "names.json"
        let messageType = ResponseType.countryNames

        Alamofire.request(
            serverURL + actionString,
            method: .get,
            encoding: JSONEncoding.default)
            .validate()
            .responseJSON { (response) -> Void in
                self.handleResponse(response, responseType: messageType, responseHandler: callback)
        }
    }

    func getCountryCurrencies(callback : @escaping onReceivingResponse){
        let actionString = "currency.json"
        let messageType = ResponseType.countryNames

        Alamofire.request(
            serverURL + actionString,
            method: .get,
            encoding: JSONEncoding.default)
            .validate()
            .responseJSON { (response) -> Void in
                self.handleResponse(response, responseType: messageType, responseHandler: callback)
        }
    }

    func getExchangeRate(source : String, destination: String, callback : @escaping onReceivingResponse){
        let actionString = ""//source + "&symbols=\(destination)"
        let messageType = ResponseType.exchangeRates

        Alamofire.request(
            exchangeServerURL + actionString,
            method: .get,
            encoding: JSONEncoding.default)
            .validate()
            .responseJSON { (response) -> Void in
                self.handleResponse(response, responseType: messageType, responseHandler: callback)
        }
    }

    func handleResponse(_ response : DataResponse<Any>! = nil, responseType messageType : ResponseType, responseHandler callback : onReceivingResponse){
        print("Message Type : \(messageType)")
        let isSuccess = response.result.isSuccess
        guard isSuccess else {
            print("Error : \(response.result.error)")
            //print(HTTPStatusCode(HTTPResponse: response.response) as Any)
            if response.data != nil {
                print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String)
            }
            callback(nil, false, messageType)
            return
        }
        print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String)
        callback(self.parser.parse(response.data, messageType: messageType),true, messageType)
    }
}

extension ServerConnection {
    func getExchangeRates() {
        getExchangeRate(source: "", destination: "", callback: { (data, serverConnection, type) in
            if let exchRate = data as? ExchangeRates {
                if (exchRate.rates.count != 0){
                    self.exchangeRatesUSDBased = exchRate.rates
                }
            }
        }
        )
    }

    func getExchangeRate(source : String, destination : String) -> Double {
        var rateSource : Double = 0
        var rateDestination : Double = 0
        if (source == "USD"){
            rateSource = 1
        } else {
            rateSource = exchangeRatesUSDBased[source] ?? -1
        }
        if (destination == "USD"){
            rateDestination = 1
        } else {
            rateDestination = exchangeRatesUSDBased[destination] ?? -1
        }
        return (rateDestination / rateSource)
    }
}

enum ResponseType {
    case countryNames
    case countryCurrencies
    case exchangeRates
}

class ParseResponse  {
    func parse(_ data : Data?, messageType : ResponseType) -> Decodable?{
        do {
            var jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
            if (jsonResponse == nil){
                let jsonArray = try JSONSerialization.jsonObject(with: data!, options:
                    JSONSerialization.ReadingOptions.mutableContainers)  as? [[String: AnyObject]]
                jsonResponse = jsonArray![0]
            }
            switch messageType {

            case .exchangeRates:
                return ExchangeRates(json: jsonResponse!)
            default:
                return GenericResponse(json: jsonResponse!)
            }

        } catch {
            print(error)
            return nil
        }
    }
}

protocol GenericResponseProtocol : Decodable {
    var dict : [String : String] { get set }
}

class GenericResponse : GenericResponseProtocol {
    var dict = [String : String]()
    required init?(json: JSON) {
        let keys = Array(json.keys)
        for key in keys {
            dict[key] = (json[key] as? String) ?? ""
        }
    }
}

class ExchangeRates : Decodable {
    var rates : [String : Double]!
    required init?(json: JSON) {
        var tmp : JSON!
        tmp = "rates" <~~ json
        print(tmp)
        rates = (tmp as? [String : Double]) ?? ["":-1]
    }
}


