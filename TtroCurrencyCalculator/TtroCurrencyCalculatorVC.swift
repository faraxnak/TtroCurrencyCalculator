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
    func getExchangeRates(currency: String, callback : @escaping ([ExchangeModelP]) -> ())
    
    func getInitialConvertCountries() -> [CountryP]?
    
    
}

public extension TtroCurrencyCalculatorVCDataSource {
    func getExchangeRates(currency: String, callback : @escaping ([ExchangeModelP]) -> ()) {
    }
}

public class TtroCurrencyCalculatorVC: UIViewController {
    
    var sourceCountryView : CountryView!
    
    var destinationCountryView : CountryView!
    
    fileprivate var exchangeModels = [ExchangeModelP]()
    
    fileprivate var countryPickerNavigationController : TtroCountryPickerViewController!
    
    var exchangeRate : Double = 0
    
    let countryListView = CountryListView(frame : .zero)
    
    var selectedCountryList = [CountryExtended]()
    
    enum SelectCountryMode {
        case source, destination, list
    }
    
    public var dataSource : TtroCurrencyCalculatorVCDataSource!
    
    var selectCountryMode = SelectCountryMode.source
    
    var updateTimeInfoLabel : TtroLabel!
    var exchangeRateInfoLabel: TtroLabel!
    var exchangeRateLabel: TtroLabel!
    
    fileprivate var shouldLoadCurrencyFromUserData = true
    
    public func setBackgroundImage(image: UIImage){
        UIGraphicsBeginImageContext(self.view.frame.size)
        image.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let title = UILabel()
        view.addSubview(title)
        title.font = UIFont.TtroPayWandFonts.regular4.font
        title.textColor = UIColor.TtroColors.darkBlue.color
        title.text = "Currency Converter"
        title.easy.layout([
            CenterX(),
            Top(60)
        ])
        
        CountryView.numberFormatter.usesSignificantDigits = true
        CountryView.numberFormatter.maximumSignificantDigits = 5
        CountryView.numberFormatter.maximumFractionDigits = 2
        CountryView.numberFormatter.roundingMode = .floor
        
        view.backgroundColor = UIColor.white
        
        let topView = UIView()
        view.addSubview(topView)
        
        topView.easy.layout([
            CenterX(),
            //Height(*0.2).like(view),
            Width(*0.9).like(view),
            Top(30).to(title),
        ])
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        
        bottomView.easy.layout([
            CenterX(),
            //Height(*0.2).like(view),
            Width(*0.9).like(view),
            Top(30).to(topView),
        ])
        
        sourceCountryView = CountryView(onTap: {
            self.onSource()
        })
        topView.addSubview(sourceCountryView)
        sourceCountryView.easy.layout(Edges())
        sourceCountryView.delegate = self
        
        destinationCountryView = CountryView(onTap: {
            self.onDestination()
        })
        bottomView.addSubview(destinationCountryView)
        destinationCountryView.easy.layout(Edges())
        destinationCountryView.delegate = self
        
        
        //dataSource = DataController.sharedInstance
        countryPickerNavigationController = TtroCountryPickerViewController()
        countryPickerNavigationController.pickerDelegate = self
        countryPickerNavigationController.pickerDataSource = dataSource
        
        let infoView = UIView()
        view.addSubview(infoView)
        infoView.easy.layout([
            Top().to(bottomView),
            Bottom(),
            CenterX(),
            Width().like(bottomView)
        ])
        
        
        updateTimeInfoLabel = TtroLabel(font: UIFont.TtroPayWandFonts.regular2.font, color: UIColor.TtroColors.white.color)
        infoView.addSubview(updateTimeInfoLabel)
        updateTimeInfoLabel.easy.layout([
            Right(),
            Width().like(infoView),
            Bottom(5).to(infoView, .centerY),
        ])
        
        let updateTimeLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.white.color)
        updateTimeLabel.text = "Last update time:"
        infoView.addSubview(updateTimeLabel)
        updateTimeLabel.easy.layout([
            Bottom(5).to(updateTimeInfoLabel, .top),
            Left()
        ])
        updateTimeInfoLabel.textAlignment = .right
        updateTimeInfoLabel.adjustsFontSizeToFitWidth = true
        
        exchangeRateLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.white.color)
        infoView.addSubview(exchangeRateLabel)
        exchangeRateLabel.easy.layout([
            Left(),
            Top(5).to(infoView, .centerY)
        ])
        exchangeRateInfoLabel = TtroLabel(font: UIFont.TtroPayWandFonts.regular2.font, color: UIColor.TtroColors.white.color)
        infoView.addSubview(exchangeRateInfoLabel)
        exchangeRateInfoLabel.easy.layout([
            Right(),
            CenterY().to(exchangeRateLabel)
        ])
        exchangeRateInfoLabel.textAlignment = .right
        
//        getExchangeRates()
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
    
    func getExchangeRates(){
        dataSource.getExchangeRates (currency: sourceCountryView.currency) { [weak self] (models) in
            self?.exchangeModels.removeAll()
            self?.exchangeModels = models
            self?.updateWithNewModels()
        }
    }
    
    func updateWithNewModels(){
        if (sourceCountryView.currency != "" && destinationCountryView.currency != "") {
            if (sourceCountryView.amount == 0) {
                sourceCountryView.amount = 1
            }
            exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: destinationCountryView.currency)
            destinationCountryView.amount = (sourceCountryView.amount * exchangeRate)
//            exchangeRateLabel.text = sourceCountryView.currency.appending("/").appending(destinationCountryView.currency).appending(":")
//            exchangeRateInfoLabel.text = String(exchangeRate)
            updateExchangeRateView(source: sourceCountryView.currency, destination: destinationCountryView.currency, rate: exchangeRate)
            updateCountryList()
        }
    }
    
//    func onDone(){
//        self.dismiss(animated: true, completion: nil)
//    }
    
    override public func viewDidAppear(_ animated: Bool) {
        if shouldLoadCurrencyFromUserData,
            let countries = dataSource.getInitialConvertCountries(),
            let country = countries.first,
            let sourceCountry = countries.last,
            let flag = countryPickerNavigationController.getCountryFlag(country: country),
            let sourceFlag = countryPickerNavigationController.getCountryFlag(country: sourceCountry) {
            destinationCountryView.setData(countryExtended: CountryExtended(country: country, flag: flag), isSourceCurrency: false)
            sourceCountryView.setData(countryExtended: CountryExtended(country: sourceCountry, flag: sourceFlag), isSourceCurrency: true)
        }
        shouldLoadCurrencyFromUserData = false
        getExchangeRates()
    }
    
    func updateExchangeRateView(source: String, destination: String, rate: Double){
        if rate > 1 {
            exchangeRateLabel.text = sourceCountryView.currency.appending("/").appending(destinationCountryView.currency).appending(":")
            exchangeRateInfoLabel.text = String.localizedStringWithFormat("%.2f", exchangeRate)
        } else {
            exchangeRateLabel.text = destinationCountryView.currency.appending("/").appending(sourceCountryView.currency).appending(":")
            exchangeRateInfoLabel.text = String.localizedStringWithFormat("%.2f", 1/exchangeRate)
        }
    }
    
    public func addCloseButton(){
        let button = UIButton()
        button.backgroundColor = UIColor.TtroColors.darkBlue.color
        button.setTitle("Close", for: .normal)
        view.addSubview(button)
        button.easy.layout([
            Width().like(view),
            Bottom(),
            Height(45),
            CenterX()
        ])
        button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    }
    
    func onClose(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension TtroCurrencyCalculatorVC : MICountryPickerDelegate{
    
    public func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName country: CountryP, flag: UIImage?) {
        switch selectCountryMode {
        case .source:
            sourceCountryView.setData(countryExtended: CountryExtended(country: country, flag: flag), isSourceCurrency: true)
            sourceCountryView.amount = 0
            getExchangeRates()
        case .destination:
            destinationCountryView.setData(countryExtended: CountryExtended(country: country, flag: flag), isSourceCurrency: false)
        case .list:
            selectedCountryList.append(CountryExtended(country: country, flag: flag))
            countryListView.countryListTableView.reloadData()
        }
        
        if (sourceCountryView.currency != "" && destinationCountryView.currency != "") {
            exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: destinationCountryView.currency)
            destinationCountryView.amount = (sourceCountryView.amount * exchangeRate)
//            exchangeRateLabel.text = sourceCountryView.currency.appending("/").appending(destinationCountryView.currency).appending(":")
//            exchangeRateInfoLabel.text = String(exchangeRate)
            updateExchangeRateView(source: sourceCountryView.currency, destination: destinationCountryView.currency, rate: exchangeRate)
            updateCountryList()
        }
        countryPickerNavigationController.dismiss(animated: true, completion: nil)
    }
    
    func updateCountryList(){
//        for country in selectedCountryList {
//            //country.exchangeRate = getExchangeRate(source: sourceCountryView.currency, destination: country.currency!)
//        }
    }
    
    public func countryPicker(setInfoType picker: MICountryPicker) -> MICountryPicker.InfoType {
        return MICountryPicker.InfoType.currency
    }
}

extension TtroCurrencyCalculatorVC : CountryViewDelegate {
    func onAmountEdit(_ countryView: CountryView, amount : Double) {
        if countryView.isSourceCurrency {
            self.destinationCountryView.amount = amount * exchangeRate
        } else {
            self.sourceCountryView.amount = amount / exchangeRate
        }
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
        
        cell.backgroundColor = UIColor.clear
//        cell.layer.cornerRadius = 10
//        cell.layer.masksToBounds = true
        let country = selectedCountryList[indexPath.row].country
        updateCell(cell: cell, exchangeRate: getExchangeRate(source: sourceCountryView.currency, destination: country.currency!.title!), currency:  country.currency)
        cell.nameLabel.text = country.name!// + "(" + country.currency!.title! + ")"
        cell.nameLabel.numberOfLines = 2
        cell.nameLabel.text = (country.currency?.title ?? "") + "\n" + country.name!
        cell.nameLabel.textColor = UIColor.TtroColors.white.color
        cell.type = .swipeThrough
        cell.revealDirection = .right
        cell.bgViewRightColor = UIColor.TtroColors.red.color.withAlphaComponent(0.8)
        cell.infoLabel.textColor = UIColor.TtroColors.white.color
        cell.backViewbackgroundColor = UIColor.clear //UIColor.TtroColors.darkBlue.color.withAlphaComponent(0.7)
        cell.bgViewInactiveColor = UIColor.clear
        cell.delegate = self
    }
    
    func updateCells(){
        let cells = countryListView.countryListTableView.visibleCells as! [CountryTableViewCell]
        if let indexes = countryListView.countryListTableView.indexPathsForVisibleRows {
            if (cells.count == 0){
                return
            }
            for (i,cell) in cells.enumerated() {
                updateCell(cell: cell, exchangeRate: getExchangeRate(source: sourceCountryView.currency, destination: selectedCountryList[indexes[i].row].country.currency!.title!), currency: selectedCountryList[indexes[i].row].country.currency)
            }
        }
    }
    
    func updateCell(cell: CountryTableViewCell, exchangeRate : Double, currency: CurrencyP?){
        if (exchangeRate != 0){
//            CountryView.numberFormatter.currencyCode =
            var s = CountryView.numberFormatter.string(from: NSNumber(value: sourceCountryView.amount * exchangeRate))
            s?.append(" ")
            s?.append(currency?.symbol ?? "")
            cell.infoLabel.text = s
        } else {
            cell.infoLabel.text = ""
        }
    }
}

// MARK : Exchange rate
extension TtroCurrencyCalculatorVC {
    
    func getExchangeRate(source : String, destination : String) -> Double {
        var rateSource : Double = 0
        var rateDestination : Double = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss"
//        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        for model in exchangeModels {
            if model.currentCurrency?.title == source {
                rateSource = 1
                break
            } else if model.destinationCurrency?.title == source {
                rateSource = Double(model.rate)
                if let date = model.lastUpdateTime {
                    updateTimeInfoLabel.text = dateFormatter.string(from: date)
                }
                break
            }
        }
        for model in exchangeModels {
            if model.currentCurrency?.title == destination {
                rateDestination = 1
                break
            } else if model.destinationCurrency?.title == destination {
                rateDestination = Double(model.rate)
                if let date = model.lastUpdateTime {
                    updateTimeInfoLabel.text = dateFormatter.string(from: date)
                }
                break
            }
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
