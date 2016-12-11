//
//  MICountryPicker.swift
//  MICountryPicker
//
//  Created by Ibrahim, Mustafa on 1/24/16.
//  Copyright © 2016 Mustafa Ibrahim. All rights reserved.
//

import UIKit
import CoreData
import EasyPeasy
import UIColor_Hex_Swift


@objc public protocol MICountryPickerDelegate: class {
    @objc optional func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String)
    @objc optional func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, id: Int, dialCode: String)
}

open class MICountryPicker: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    let countryPickerCell = "countryTableViewCell"
    var lastSearch = ""
    var fetchedResultsController: NSFetchedResultsController<CountryMO>!
    
    fileprivate var searchController: UISearchController!
    fileprivate let collation = UILocalizedIndexedCollation.current()
        as UILocalizedIndexedCollation
    open weak var delegate: MICountryPickerDelegate?
    open var didSelectCountryClosure: ((String, String) -> ())?
    open var didSelectCountryWithCallingCodeClosure: ((String, String, String) -> ())?
    open var showCallingCodes = true
    
    var fetchedCountries = [[CountryMO]]()
    
    convenience public init(completionHandler: @escaping ((String, String) -> ())) {
        self.init()
        self.didSelectCountryClosure = completionHandler
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ttroColors.white.color
        
        performFetch()
    }
    
    // MARK : navigation bar
    override open func viewWillAppear(_ animated: Bool) {
        tableView.register(countryTableViewCell.self, forCellReuseIdentifier: countryPickerCell)
        createSearchBar()
        definesPresentationContext = true
        self.navigationController?.navigationBar.barTintColor = UIColor.ttroColors.white.color
        //        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MICountryPicker.cancel))
        self.navigationController?.view.backgroundColor = UIColor.orange
        self.title = "Select Country"
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    fileprivate func createSearchBar() {
        if self.tableView.tableHeaderView == nil {
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.scopeButtonTitles = ["Name", "Phone code"]
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.barTintColor = UIColor.ttroColors.white.color
            tableView.tableHeaderView = searchController.searchBar
        }
    }
}

// MARK: - Table view data source

extension MICountryPicker {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        //        guard let sectionCount = fetchedResultsController.sections?.count else {
        //            return 0
        //        }
        //        return sectionCount
        return fetchedCountries.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //let sections = self.fetchedResultsController.sections!
        //let sectionInfo = sections[section]
        //return sectionInfo.numberOfObjects
        
        return fetchedCountries[section].count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: countryPickerCell, for: indexPath) as! countryTableViewCell
        
        let country = fetchedCountries[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        let bundle = "flags.bundle/"
        
        if let filePath = Bundle.main.path(forResource: bundle + country.code.lowercased(), ofType: "png"){
            cell.flagImageView.image = UIImage(contentsOfFile: filePath)
        }
        
        cell.nameLabel.text = country.name
        cell.codeLabel.text = "+" + country.phoneCode
        return cell
    }
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.fetchedResultsController.sectionIndexTitles
    }
    
    override open func tableView(_ tableView: UITableView,
                                 sectionForSectionIndexTitle title: String,
                                 at index: Int)
        -> Int {
            return self.fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return countryTableViewCell.cellHeight
    }
}

// MARK: - Table view delegate

extension MICountryPicker {
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = fetchedResultsController.object(at: indexPath)
        searchController.view.endEditing(false)
        
        //delegate?.countryPicker(self, didSelectCountryWithName: country.name!, code: country.code)
        delegate?.countryPicker?(self, didSelectCountryWithName: country.name!, id: country.id.intValue, dialCode: country.phoneCode)
        //didSelectCountryClosure?(country.name!, country.code)
        //didSelectCountryWithCallingCodeClosure?(country.name!, country.code, country.phoneCode)
    }
}

// MARK: - UISearchDisplayDelegate

extension MICountryPicker: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text != lastSearch){
            lastSearch = searchController.searchBar.text!
            if (searchController.searchBar.selectedScopeButtonIndex == 1 && Int(searchController.searchBar.text!) != nil) {
                self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "phoneCode beginswith %@", searchController.searchBar.text!)
            } else if (searchController.searchBar.selectedScopeButtonIndex == 0 && searchController.searchBar.text != ""){
                self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", searchController.searchBar.text!)
            } else {
                self.fetchedResultsController.fetchRequest.predicate = nil
                
            }
            performFetch()
        }
    }
}

// MARK : - UISearchBarDelegate

extension MICountryPicker {
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = ""
        if (selectedScope == 0){
            searchBar.keyboardType = .default
        } else {
            searchBar.keyboardType = .namePhonePad
        }
    }
    
}

// MARK: - NSFetchedResultsController

extension MICountryPicker {
    
    func performFetch() {
        if (fetchedResultsController == nil){
            let fetchRequest = CountryMO.fetchRequest()
            // Add Sort Descriptors
            let sortDescriptor = NSSortDescriptor(key: "code", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Initialize Fetched Results Controller
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest as! NSFetchRequest<CountryMO>, managedObjectContext: DataController.sharedInstance.managedObjectContext, sectionNameKeyPath: "firstLetter", cacheName: nil)
            
            // Configure Fetched Results Controller
            fetchedResultsController.delegate = self
        }
        do {
            try fetchedResultsController.performFetch()
            fetchedCountries.removeAll()
            guard let sectionCount = fetchedResultsController.sections?.count else {
                return
            }
            for i in 0 ..< sectionCount {
                let sections = self.fetchedResultsController.sections!
                let sectionInfo = sections[i]
                
                fetchedCountries.append(sectionInfo.objects as! [CountryMO])
            }
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}

class countryTableViewCell: UITableViewCell {
    var flagImageView : UIImageView!
    var nameLabel : UILabel!
    var codeLabel : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initElements()
    }
    
    static let cellHeight : CGFloat = 75
    static let elementHeight : CGFloat = 50
    
    func initElements(){
        backgroundColor = UIColor.ttroColors.white.color
        
        flagImageView = UIImageView()
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(flagImageView)
        flagImageView <- [
            Height(countryTableViewCell.elementHeight),
            Width(countryTableViewCell.elementHeight),
            Left(10).to(contentView, .left),
            CenterY().to(contentView, .centerY)
        ]
        
        flagImageView.layer.masksToBounds = true
        flagImageView.layer.cornerRadius = countryTableViewCell.elementHeight/2
        flagImageView.contentMode = .scaleAspectFit
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        nameLabel <- [
            Height(countryTableViewCell.elementHeight),
            Width(*0.6).like(contentView),
            Left(10).to(flagImageView, .right),
            CenterY().to(contentView, .centerY)
        ]
        
        codeLabel = UILabel()
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeLabel)
        codeLabel <- [
            Height(countryTableViewCell.elementHeight),
            Right(10).to(contentView, .right),
            CenterY().to(contentView, .centerY)
        ]
    }
}

protocol ttroColorProtocol {
    var color : UIColor { get }
}

extension UIColor {
    enum ttroColors : ttroColorProtocol {
        case white
        case darkBlue
        case lightBlue
        case cyan
        case green
        case orange
        case red
        
        var color: UIColor {
            switch self {
            case .white:
                return UIColor("#f0f0f0")
            case .cyan:
                return UIColor("#50e6b4")
            case .darkBlue:
                return UIColor("#2d3c50")
            case .lightBlue:
                return UIColor("#3296dc")
            case .green:
                return UIColor("#2ecc71")
            case .red:
                return UIColor("#ba293f")
            case .orange:
                return UIColor("#ffa800")
            }
        }
    }
}
