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

public protocol TtroPopCurrencyConverterDelegate {
    func onOkButton(popCurrencyConverter : TtroPopCurrencyConverter)
    
    func onConverterPageButton(popCurrencyConverter : TtroPopCurrencyConverter)
    
    func getExchangeRate(source : String, destination : String) -> Double
    
    func getPickerDataSource(popCurrencyConverter : TtroPopCurrencyConverter) -> UIPickerViewDataSource
    
    func getPickerDelegate(popCurrencyConverter : TtroPopCurrencyConverter) -> UIPickerViewDelegate
}

public class TtroPopCurrencyConverter : TtroPopViewController {
    
    var currencyPicker = UIPickerView()
    var changeCurrencyButton : UIButton!
    var exchangeCurrencyLabel : TtroLabel!
    var exchangedAmountLabel : TtroLabel!
    var sourceCurrency : CurrencyP!
    var initialAmount : Double!
    var sourceAmountTextField : TtroTextField!
    var destinationCurrency : CurrencyP?
    
    //var userAmountTextFieldInput = ""
    
    public var converterDelegate : TtroPopCurrencyConverterDelegate!
    
    fileprivate var exchangeRatesUSDBased = [String : Double]()
    
    public func updateExchangeAmountLabel(currency : CurrencyP){
        self.exchangeCurrencyLabel.text = currency.title// + " (\(country.name!))"
        self.destinationCurrency = currency
        if let amount = Double(sourceAmountTextField.text!) {
            let newAmount = amount * self.converterDelegate.getExchangeRate(source: sourceCurrency.symbol!, destination: currency.title!)
            self.exchangedAmountLabel.text = String.localizedStringWithFormatForCurrency("%@ %C", currency: currency, currency.symbol!, newAmount)
        }
    }
    
    public convenience init(sourceCurrency : CurrencyP, initialAmount : Double!) {
        self.init(nibName : nil, bundle : nil )
        self.modalPresentationStyle = .overCurrentContext
        delegate = self
        self.sourceCurrency = sourceCurrency
        self.initialAmount = initialAmount
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.dataSource = converterDelegate.getPickerDataSource(popCurrencyConverter : self)
        currencyPicker.delegate = converterDelegate.getPickerDelegate(popCurrencyConverter : self)
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
            currencyPicker.isHidden = true
            currencyPicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
            return currencyPicker
        case 3:
            exchangedAmountLabel = TtroLabel(font: UIFont.TtroPayWandFonts.regular3.font, color: UIColor.TtroColors.darkBlue.color)
            exchangedAmountLabel.text = "0 $"
            exchangedAmountLabel.textAlignment = .center
            exchangedAmountLabel.easy.layout(Height(50))
            //exchangedAmountLabel <- Height(*0.25).like(ttroPopView)
            return exchangedAmountLabel
        default:
            fatalError("index exceeds maximium number of views")
        }
    }
    
    func getAmountView() -> UIView {
        let amountView = UIView()
        
        let sourceCurrencyLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.darkBlue.color)
        sourceCurrencyLabel.text = sourceCurrency.title
        amountView.addSubview(sourceCurrencyLabel)
        sourceCurrencyLabel.easy.layout([
            Left(5),
            CenterY(),
            Top(10),
            Bottom(10)
        ])
        
        sourceAmountTextField = TtroTextField(placeholder: "Enter amount", font: UIFont.TtroPayWandFonts.light3.font)
        sourceAmountTextField.textColor = UIColor.TtroColors.darkBlue.color
        sourceAmountTextField.backgroundColor = UIColor.TtroColors.white.color
        sourceAmountTextField.returnKeyType = .done
        sourceAmountTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        sourceAmountTextField.delegate = self
        amountView.addSubview(sourceAmountTextField)
        sourceAmountTextField.easy.layout([
            Right().to(amountView, .right),
            CenterY(),
            Width(*0.6).like(amountView),
            Height(30)
        ])
        if (initialAmount != 0){
            sourceAmountTextField.text = String(initialAmount)
        }
        
        let currencySymbolLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.darkBlue.color)
        currencySymbolLabel.text = sourceCurrency.symbol //?.appending(" ")
        currencySymbolLabel.textAlignment = .center
        currencySymbolLabel.easy.layout(Width(30))
        sourceAmountTextField.rightView = currencySymbolLabel
        sourceAmountTextField.rightViewMode = .always
        return amountView
    }
    
    func getExchangeCurrencyView() -> UIView {
        let view = UIView()
        view.easy.layout(Height(50))
//        view.layer.borderColor = UIColor.TtroColors.darkBlue.color.withAlphaComponent(0.3).cgColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 5
        
        exchangeCurrencyLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.darkBlue.color)
        exchangeCurrencyLabel.text = "Select"
        view.addSubview(exchangeCurrencyLabel)
        exchangeCurrencyLabel.easy.layout([
            Left(5),
            CenterY()
        ])
        changeCurrencyButton = UIButton(type: .system)
        changeCurrencyButton.setTitle("…", for: .normal)
        changeCurrencyButton.setTitle("×", for: .selected)
        changeCurrencyButton.setTitleColor(UIColor.TtroColors.darkBlue.color, for: .normal)
        changeCurrencyButton.titleLabel?.font = UIFont.TtroPayWandFonts.regular2.font
        changeCurrencyButton.addTarget(self, action: #selector(self.onChangeCurrency), for: .touchUpInside)
        changeCurrencyButton.tintColor = UIColor.white
        changeCurrencyButton.setTitleColor(UIColor.TtroColors.darkBlue.color, for: .selected)
        
        view.addSubview(changeCurrencyButton)
        changeCurrencyButton.easy.layout([
            Right(5),
            CenterY(),
        ])
        
        let borderView = UIView()
        view.insertSubview(borderView, belowSubview: exchangeCurrencyLabel)
        borderView.layer.borderColor = UIColor.TtroColors.white.color.cgColor //.withAlphaComponent(0.8).cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.cornerRadius = 5
        borderView.easy.layout([
            Top(-5).to(exchangeCurrencyLabel, .top),
            Left(-5).to(exchangeCurrencyLabel, .left),
            Bottom(-5).to(exchangeCurrencyLabel, .bottom),
            Right(-5).to(changeCurrencyButton, .right)
        ])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(onChangeCurrency))
        borderView.addGestureRecognizer(tapGR)
        return view
    }
    
    func onChangeCurrency() {
        sourceAmountTextField.endEditing(false)
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
        return 1
    }
    
    public func bottomView(listOfButtonTitles bottomView : BottomView, numberOfButtons n : Int) -> [String] {
        return ["Done"]
    }
    
    public func onFirstButton(){
        converterDelegate.onOkButton(popCurrencyConverter: self)
    }
}

extension TtroPopCurrencyConverter : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (!currencyPicker.isHidden) {
            onChangeCurrency()
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if (destinationCurrency != nil){
            updateExchangeAmountLabel(currency: destinationCurrency!)
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Double(textField.text! + string) == nil {
            return false
        }
        return true
    }
    
    func textFieldDidChange(textField: UITextField){
//        if let amount = Double(userAmountTextFieldInput) {
//            sourceAmountTextField.text = String.localizedStringWithFormat("%.1f", amount)
//        } else if userAmountTextFieldInput.isEmpty {
//            sourceAmountTextField.text = "0"
//        }
        if (destinationCurrency != nil){
            updateExchangeAmountLabel(currency: destinationCurrency!)
        }
    }
}
