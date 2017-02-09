//
//  TtroPopCurrencyCalculatorDelegate.swift
//  Pods
//
//  Created by Farid on 2/9/17.
//
//

import UIKit
import TtroPopView
import EasyPeasy
import PayWandBasicElements
import CoreData
import PayWandModelProtocols

public protocol TtroPopCurrencyConverterDelegate: UIPickerViewDataSource, UIPickerViewDelegate {
    func onOkButton()
    
    func onConverterPageButton()
    
    func getExchangeRate(source : String, destination : String) -> Double
}

public class TtroPopCurrencyConverter : TtroPopViewController {
    
    var currencyPicker = UIPickerView()
    var changeCurrencyButton : UIButton!
    var exchangeCurrencyLabel : TtroLabel!
    var exchangedAmountLabel : TtroLabel!
    var sourceCurrency : String!
    
    public var converterDelegate : TtroPopCurrencyConverterDelegate!
    
    fileprivate var exchangeRatesUSDBased = [String : Double]()
    
    func updateExchangeAmountLabel(country : CountryP){
        self.exchangeCurrencyLabel.text = country.currency! + " (\(country.name!))"
        self.exchangedAmountLabel.text = "\(25000 * self.converterDelegate.getExchangeRate(source: sourceCurrency, destination: country.currency!))"
    }
    
    public convenience init(sourceCurrency : String) {
        self.init(nibName : nil, bundle : nil )
        self.modalPresentationStyle = .overCurrentContext
        delegate = self
        currencyPicker.dataSource = converterDelegate
        currencyPicker.delegate = converterDelegate
        ServerConnection.sharedInstance.getExchangeRates()
        self.sourceCurrency = sourceCurrency
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TtroPopCurrencyConverter : TtroPopViewControllerDelegate {
    public func ttroPopView(numberOfViews popView : TtroPopView) -> Int {
        return 4
    }
    
    public func ttroPopView(numberOfViews popView : TtroPopView, viewAtIndex index : Int) -> UIView {
        switch index {
        case 0:
            return getAmountView()
        case 1:
            return getExchangeCurrencyView()
        case 2:
            //currencyPicker.isHidden = true
            currencyPicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
            return currencyPicker
        case 3:
            exchangedAmountLabel = TtroLabel(font: UIFont.TtroPayWandFonts.regular2.font, color: UIColor.TtroColors.darkBlue.color)
            exchangedAmountLabel.text = "0 $"
            exchangedAmountLabel.textAlignment = .center
            exchangedAmountLabel <- Height(50)
            //exchangedAmountLabel <- Height(*0.25).like(ttroPopView)
            return exchangedAmountLabel
        default:
            fatalError("index exceeds maximium number of views")
        }
    }
    
    func getAmountView() -> UIView {
        let amountView = UIView()
        
        let sourceCurrencyLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light2.font, color: UIColor.TtroColors.darkBlue.color)
        sourceCurrencyLabel.text = sourceCurrency
        amountView.addSubview(sourceCurrencyLabel)
        sourceCurrencyLabel <- [
            Left(),
            CenterY(),
            Top(10),
            Bottom(10)
        ]
        
        let sourceAmountTextField = TtroTextField(placeholder: "Enter amount", font: UIFont.TtroPayWandFonts.light2.font)
        sourceAmountTextField.textColor = UIColor.TtroColors.darkBlue.color
        sourceAmountTextField.backgroundColor = UIColor.TtroColors.white.color
        amountView.addSubview(sourceAmountTextField)
        sourceAmountTextField <- [
            Right().to(amountView, .right),
            CenterY()
        ]
        sourceAmountTextField.text = "25000"
        
        let currencySymbolLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light2.font, color: UIColor.TtroColors.darkBlue.color)
        currencySymbolLabel.text = "¢"
        currencySymbolLabel.textAlignment = .center
        currencySymbolLabel <- Width(20)
        sourceAmountTextField.rightView = currencySymbolLabel
        sourceAmountTextField.rightViewMode = .always
        return amountView
    }
    
    func getExchangeCurrencyView() -> UIView {
        let view = UIView()
        view <- Height(50)
        //view.layer.borderColor = UIColor.TtroColors.darkBlue.color.withAlphaComponent(0.3).cgColor
        //view.layer.borderWidth = 1
        exchangeCurrencyLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light2.font, color: UIColor.TtroColors.darkBlue.color)
        exchangeCurrencyLabel.text = "USD (United States)"
        view.addSubview(exchangeCurrencyLabel)
        exchangeCurrencyLabel <- [
            Left(),
            CenterY()
        ]
        changeCurrencyButton = UIButton(type: .system)
        changeCurrencyButton.setTitle("…", for: .normal)
        changeCurrencyButton.setTitle("x", for: .selected)
        changeCurrencyButton.setTitleColor(UIColor.TtroColors.darkBlue.color, for: .normal)
        changeCurrencyButton.titleLabel?.font = UIFont.TtroPayWandFonts.regular2.font
        changeCurrencyButton.addTarget(self, action: #selector(self.onChangeCurrency), for: .touchUpInside)
        
        view.addSubview(changeCurrencyButton)
        changeCurrencyButton <- [
            Right(),
            CenterY(),
        ]
        return view
    }
    
    func onChangeCurrency() {
        if (currencyPicker.isHidden){
            changeCurrencyButton.isSelected = true
            currencyPicker.isHidden = false
            currencyPicker.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.currencyPicker.alpha = 1
            })
        } else {
            changeCurrencyButton.isSelected = false
            currencyPicker.isHidden = true
        }
//        ttroPopView.layoutIfNeeded()
    }
    
    public func bottomView(numberOfButtons bottomView : BottomView) -> Int {
        return 2
    }
    
    public func bottomView(listOfButtonTitles bottomView : BottomView, numberOfButtons n : Int) -> [String] {
        return ["Ok", "Converter Page"]
    }
    
    public func onSecondButton(){
        print("2")
        converterDelegate.onConverterPageButton()
        
    }
    
    public func onFirstButton(){
        print("1")
        converterDelegate.onOkButton()
    }
}



//////////
//
//
//public protocol CurrencyPickerDataSource : class {
//    
//    func country(countryWithNSFRResult result : NSFetchRequestResult) -> CountryP
//    
//    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>
//}
//
//
//class CurrencyPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
//    //var currencyList = [String]()
//    var countryList = [CountryP]()
//    
//    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
//    var pickerView : UIPickerView!
//    
//    typealias PickerRowSelected = (_ selectedItem : String, _ row : Int) -> ()
//    var pickerRowSelected : PickerRowSelected?
//    
//    var pickerRowSelectedCurrencyTitle : PickerRowSelected?
//    
//    init(pickerRowSelected: PickerRowSelected?, pickerRowSelectedCurrencyTitle: PickerRowSelected? = nil) {
//        super.init()
//        self.pickerRowSelected = pickerRowSelected
//        self.pickerRowSelectedCurrencyTitle = pickerRowSelectedCurrencyTitle
//        //initPickerSource()
//    }
//    
//    var pickerDataSource : CurrencyPickerDataSource!
//    
//    fileprivate func initPickerSource(){
//        performFetch()
//    }
//    
//    // The number of columns of data
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    // The number of rows of data
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        print(fetchedResultsController.fetchedObjects!.count)
//        return fetchedResultsController.fetchedObjects!.count
//    }
//    
//    //    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
//    //        return currencyList[row]
//    //    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        //pickerRowSelected?(currencySymbols[row], row)
//        pickerRowSelectedCurrencyTitle?(countryList[row].currency!, row)
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
//        
//        //            let country = Country() //try fetchedResultsController.object(at: indexPath) as! CountryMO
//        //            let bundle = "flags.bundle/"
//        //print(fetchedResultsController.fetchedObjects?[row] as Any, row)
//        //let country = pickerDataSource.country(countryWithNSFRResult: fetchedResultsController.object(at: IndexPath(row: row, section: 0)))
//        let country = countryList[row]
//        
//        return NSAttributedString(string: countryList[row].currency!, attributes: [NSForegroundColorAttributeName : UIColor.TtroColors.darkBlue.color])
//    }
//}
//
//extension CurrencyPickerDelegate : NSFetchedResultsControllerDelegate {
//    
//    func performFetch() {
//        if (fetchedResultsController == nil){
//            
//            fetchedResultsController = pickerDataSource.createFetchedResultsController()
//            fetchedResultsController.delegate = self
//        }
//        do {
//            try fetchedResultsController.performFetch()
//            if fetchedResultsController.fetchedObjects != nil {
//                countryList.removeAll()
//                for object in fetchedResultsController.fetchedObjects! {
//                    countryList.append(pickerDataSource.country(countryWithNSFRResult: object))
//                }
//            }
//        } catch {
//            print(error)
//        }
//    }
//}
