//
//  Controller.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy

public class TtroCurrencyCalculatorVC: UIViewController {
    
    var sourceCountryView : CountryView!
    
    var destinationCountryView : CountryView!
    
    fileprivate var exchangeRatesUSDBased = [String : Double]()
    
    var exchangeRate : Double = 0
    
    let countryPicker = MICountryPicker(completionHandler: nil)
    
    let countryListView = CountryListView(frame : .zero)
    
    var selectedCountryList = [Country]()
    
    enum SelectCountryMode {
        case source, destination, list
    }
    
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
        
        countryPicker.delegate = self
        countryPicker.dataSource = DataController.sharedInstance
        countryPicker.checkCountryList()
        
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
        
        getExchangeRates()
    }
    
    func onSource() {
        selectCountryMode = .source
        present(countryPicker, animated: true, completion: nil)
    }
    
    func onDestination() {
        selectCountryMode = .destination
        present(countryPicker, animated: true, completion: nil)
    }
    
}

extension TtroCurrencyCalculatorVC : MICountryPickerDelegate{
    public func countryPicker(_ picker: MICountryPicker, didSelectCountryWithInfo country: Country) {
        
        switch selectCountryMode {
        case .source:
            sourceCountryView.setData(country: country, isSourceCurrency: true)
            sourceCountryView.amount = 0
        case .destination:
            destinationCountryView.setData(country: country, isSourceCurrency: false)
        case .list:
            selectedCountryList.append(country)
            countryListView.countryListTableView.reloadData()
        }
        
        if (sourceCountryView.currency != "" && destinationCountryView.currency != "") {
            self.exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: destinationCountryView.currency)
            self.destinationCountryView.amount = (self.sourceCountryView.amount * exchangeRate)
            updateCountryList()
        }
        
        countryPicker.dismiss(animated: true, completion: nil)
    }
    
    func updateCountryList(){
        for country in selectedCountryList {
            country.exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: country.currency!)
        }
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
        present(countryPicker, animated: true, completion: nil)
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
        
        let country = selectedCountryList[indexPath.row]
        //let bundle = "flags.bundle/"
        
        if let filePath = Bundle(for: MICountryPicker.self).path(forResource:country.code.lowercased(), ofType: "png"){
            cell.flagImageView.image = UIImage(contentsOfFile: filePath)
        }
        cell.nameLabel.text = country.name
        updateCell(cell: cell, exchangeRate: country.exchangeRate)
        
    }
    
    func updateCells(){
        let cells = countryListView.countryListTableView.visibleCells as! [CountryTableViewCell]
        if let indexes = countryListView.countryListTableView.indexPathsForVisibleRows {
            if (cells.count == 0){
                return
            }
            for i in 0...cells.count - 1 {
                updateCell(cell: cells[i], exchangeRate: selectedCountryList[indexes[i].row].exchangeRate)
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
