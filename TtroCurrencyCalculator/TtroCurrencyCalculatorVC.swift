//
//  Controller.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy
import TtroCountryPicker
import PayWandBasicElements
import PayWandModelProtocols

public protocol TtroCurrencyCalculatorVCDataSource : MICountryPickerDataSource {
    
}

public class TtroCurrencyCalculatorVC: UIViewController {
    
    var sourceCountryView : CountryView!
    
    var destinationCountryView : CountryView!
    
    fileprivate var exchangeRatesUSDBased = [String : Double]()
    
    fileprivate var countryPickerNavigationController : TtroCountryPickerViewController!
    
    var exchangeRate : Double = 0
    
//    let countryPicker = MICountryPicker(completionHandler: nil)
    
    let countryListView = CountryListView(frame : .zero)
    
    var selectedCountryList = [CountryExtended]()
    
    enum SelectCountryMode {
        case source, destination, list
    }
    
    var dataSource : TtroCurrencyCalculatorVCDataSource!
    
    var selectCountryMode = SelectCountryMode.source
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        CountryView.numberFormatter.usesSignificantDigits = true
        CountryView.numberFormatter.maximumSignificantDigits = 5
        CountryView.numberFormatter.maximumFractionDigits = 2
        CountryView.numberFormatter.roundingMode = .floor
        
        view.backgroundColor = UIColor.white
        
        let topView = UIView()
        view.addSubview(topView)
        
        topView <- [
            CenterX(),
            Height(*0.2).like(view),
            Width().like(view),
            Top(),
        ]
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        
        bottomView <- [
            CenterX(),
            Height(*0.2).like(view),
            Width().like(view),
            Top().to(topView),
        ]
        
        sourceCountryView = CountryView(onTap: {
            self.onSource()
        })
        topView.addSubview(sourceCountryView)
        sourceCountryView <- Edges()
        sourceCountryView.delegate = self
        
        destinationCountryView = CountryView(onTap: {
            self.onDestination()
        })
        bottomView.addSubview(destinationCountryView)
        destinationCountryView <- Edges()
        
        
        dataSource = DataController.sharedInstance
        countryPickerNavigationController = TtroCountryPickerViewController()
        countryPickerNavigationController.pickerDelegate = self
        countryPickerNavigationController.pickerDataSource = dataSource
        
        
        view.addSubview(countryListView)
        countryListView <- [
            Top().to(bottomView),
            Bottom(),
            Width(*0.9).like(view),
            CenterX()
        ]
        countryListView.delegate = self
        countryListView.countryListTableView.delegate = self
        countryListView.countryListTableView.dataSource = self
        
        
        let popButton = UIButton(type: .system)
        popButton.setTitle("Pop", for: .normal)
        popButton.addTarget(self, action: #selector(self.onPop), for: .touchUpInside)
        self.view.addSubview(popButton)
        popButton <- [
            Bottom(20),
            CenterX()
        ]
        getExchangeRates()
        
        //countryPickerNavigationController = UINavigationController(rootViewController: countryPicker)
    }
    
    func onSource() {
        selectCountryMode = .source
        self.present(countryPickerNavigationController, animated: true, completion: nil)
        //present(countryPicker, animated: true, completion: nil)
    }
    
    func onDestination() {
        selectCountryMode = .destination
        self.present(countryPickerNavigationController, animated: true, completion: nil)
    }
    
    func onPop(){
//        let currencyPickerDelegate = CurrencyPickerDelegate(pickerRowSelected: nil, pickerRowSelectedCurrencyTitle: { (title, row) in
//            print(title)
//            self.updateExchangeAmountLabel(country: self.currencyPickerDelegate.countryList[row])
//        })
//        currencyPickerDelegate.pickerDataSource = DataController.sharedInstance
//        currencyPickerDelegate.pickerView = currencyPicker
//        currencyPickerDelegate.initPickerSource()
        
        let vc = TtroPopCurrencyConverter(sourceCurrency: "IRR")
        present(vc, animated: true, completion: nil)
    }
    
}

extension TtroCurrencyCalculatorVC : MICountryPickerDelegate{
    
    public func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName country: CountryP, flag: UIImage?) {
        switch selectCountryMode {
        case .source:
            sourceCountryView.setData(countryExtended: CountryExtended(country: country, flag: flag), isSourceCurrency: true)
            sourceCountryView.amount = 0
        case .destination:
            destinationCountryView.setData(countryExtended: CountryExtended(country: country, flag: flag), isSourceCurrency: false)
        case .list:
            selectedCountryList.append(CountryExtended(country: country, flag: flag))
            countryListView.countryListTableView.reloadData()
        }
        
        if (sourceCountryView.currency != "" && destinationCountryView.currency != "") {
            self.exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: destinationCountryView.currency)
            self.destinationCountryView.amount = (self.sourceCountryView.amount * exchangeRate)
            updateCountryList()
        }
        countryPickerNavigationController.dismiss(animated: true, completion: nil)
    }
    
    func updateCountryList(){
        for country in selectedCountryList {
            //country.exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: country.currency!)
        }
    }
    
    public func countryPicker(setInfoType picker: MICountryPicker) -> MICountryPicker.InfoType {
        return MICountryPicker.InfoType.currecny
    }
}

extension TtroCurrencyCalculatorVC : CountryViewDelegate {
    public func onAmountEdit(amount : Double) {
        self.destinationCountryView.amount = amount * exchangeRate
        updateCells()
    }
}

extension TtroCurrencyCalculatorVC : CountryListViewDelegate {
    func onAddCountry() {
        selectCountryMode = .list
        
        present(countryPickerNavigationController, animated: true, completion: nil)
    }
}

extension TtroCurrencyCalculatorVC : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CountryTableViewCell.cellHeight
    }
}

extension TtroCurrencyCalculatorVC : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCountryList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CountryTableViewCell.self), for: indexPath) as! CountryTableViewCell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CountryTableViewCell, indexPath: IndexPath) {
        
        cell.flagImageView.image = selectedCountryList[indexPath.row].flag
        
        
        let country = selectedCountryList[indexPath.row].country
        updateCell(cell: cell, exchangeRate: getExchangeRate(source: sourceCountryView.currency, destination: country.currency!))
        cell.nameLabel.text = country.name
        cell.type = .swipeThrough
        cell.revealDirection = .right
        cell.bgViewRightColor = UIColor.TtroColors.red.color
        cell.delegate = self
    }
    
    func updateCells(){
        let cells = countryListView.countryListTableView.visibleCells as! [CountryTableViewCell]
        if let indexes = countryListView.countryListTableView.indexPathsForVisibleRows {
            if (cells.count == 0){
                return
            }
            for i in 0...cells.count - 1 {
                updateCell(cell: cells[i], exchangeRate: getExchangeRate(source: sourceCountryView.currency, destination: selectedCountryList[indexes[i].row].country.currency!))
            }
        }
    }
    
    func updateCell(cell: CountryTableViewCell, exchangeRate : Double){
        if (exchangeRate != 0){
//            CountryView.numberFormatter.currencyCode =
            cell.infoLabel.text = CountryView.numberFormatter.string(from: NSNumber(value: sourceCountryView.amount * exchangeRate))
        } else {
            cell.infoLabel.text = ""
        }
    }
}

// MARK : Exchange rate
extension TtroCurrencyCalculatorVC {
    func getExchangeRates() {
        ServerConnection.sharedInstance.getExchangeRate(source: "", destination: "", callback: { (data, serverConnection, type) in
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

extension TtroCurrencyCalculatorVC : BWSwipeCellDelegate {
    public func swipeCellDidCompleteRelease(_ cell: BWSwipeCell) {
        print("here", cell.state)
        if (cell.state == .pastThresholdRight){
            if let countryCell = cell as? CountryTableViewCell {
                for countryExtended in selectedCountryList {
                    if (countryExtended.country.name == countryCell.nameLabel.text){
//                        selectedCList.inde
                        selectedCountryList.remove(at: selectedCountryList.index(of: countryExtended)!)
                        countryListView.countryListTableView.reloadData()
                        break
                    }
                }
            }
        }
    }
}

class CountryExtended : NSObject {
    var country : CountryP
    var flag : UIImage?
//    var exchangeRate : Double = 0
    
    init(country : CountryP, flag : UIImage?) {
        self.country = country
        self.flag = flag
        //self.exchangeRate = exchangeRate
    }
}
