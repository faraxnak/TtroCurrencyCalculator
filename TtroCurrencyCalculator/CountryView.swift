//
//  CountryView.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy
import TtroCountryPicker
import PayWandModelProtocols

@objc protocol CountryViewDelegate : class {
    
    @objc optional func onAmountEdit(_ countryView: CountryView, amount : Double)
}

class CountryView: UIView {
    
    fileprivate var nameLabel : UILabel!
    fileprivate var currencyLabel : UILabel!
    fileprivate var flagImageView : UIImageView!
    fileprivate var amountTextField : UITextField!
    fileprivate var infoView : UIView!
    
    var currencySymbolLabel : UILabel!
    
    let elementHeight : CGFloat = 50
    
    fileprivate var onTapClosure : (() -> ())!
    
    static let numberFormatter = KNumberFormatter()
    
    public var delegate : CountryViewDelegate?
    
    var currency : String {
        get {
            return currencyLabel.text ?? ""
        }
    }
    
    var amount : Double {
        get {
            return CountryView.numberFormatter.number(from: amountTextField.text ?? "")?.doubleValue ?? 0
        }
        set {
            amountTextField.text = CountryView.numberFormatter.string(from: NSNumber(value: newValue))
        }
    }
    
    var isSourceCurrency : Bool = true
    
    convenience init(onTap onTapClosure : @escaping () -> ()) {
        self.init(frame : .zero)
        self.onTapClosure = onTapClosure
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        infoView.addGestureRecognizer(tapGR)
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        infoView = UIView()
        addSubview(infoView)
        infoView <- [
            //Height(40),
            Width(*0.9).like(self),
            Top(),
//            Bottom(5).to(self, .centerY),
            CenterX(),
            Height(40)
        ]
        infoView.backgroundColor = UIColor.TtroColors.darkBlue.color.withAlphaComponent(0.7)
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = true
        //infoView.layer.borderColor = UIColor.TtroColors.darkBlue.color.withAlphaComponent(0.7).cgColor
        //infoView.layer.borderWidth = 2
        
        flagImageView = UIImageView()
        flagImageView.contentMode = .scaleAspectFit
        infoView.addSubview(flagImageView)
        flagImageView <- [
            Left(),
            Height().like(infoView),
            Width().like(flagImageView, .height),
            CenterY()
        ]
//        addSubview(flagImageView)
//        flagImageView <- [
//            Height(elementHeight),
//            Width().like(flagImageView, .height),
//            CenterY(),
//            Left(elementHeight/2)
//        ]
//        
//        flagImageView.layer.cornerRadius = elementHeight/2
//        flagImageView.layer.masksToBounds = true
//        flagImageView.backgroundColor = UIColor.cyan
        flagImageView.isUserInteractionEnabled = true
        
        currencyLabel = UILabel()
        infoView.addSubview(currencyLabel)
        currencyLabel <- [
            CenterY(),
            Right(10),
            Width(50)
        ]
        currencyLabel.font = UIFont.TtroPayWandFonts.regular2.font
        currencyLabel.textColor = UIColor.TtroColors.white.color
        currencyLabel.textAlignment = .right
//        self.addSubview(currencyLabel)
//        currencyLabel <- [
//            Left(20).to(nameLabel),
//            CenterY().to(nameLabel),
//        ]
        
        nameLabel = UILabel()
        infoView.addSubview(nameLabel)
        nameLabel <- [
            Left(10).to(flagImageView),
            CenterY(),
            Right().to(currencyLabel, .left)
        ]
        nameLabel.font = UIFont.TtroPayWandFonts.regular2.font
        nameLabel.textColor = UIColor.TtroColors.white.color
//        addSubview(nameLabel)
//        nameLabel <- [
//            Left(elementHeight/2).to(flagImageView),
//            CenterY(-elementHeight/2),
//            Width(*0.4).like(self)
//        ]
        
        amountTextField = UITextField()
        addSubview(amountTextField)
        amountTextField <- [
            //CenterY(elementHeight/2),
            //Left().to(nameLabel, .left),
            //Right().to(currencyLabel, .right)
            Top(10).to(infoView),
            Height(50),
            Bottom(5),
            Width().like(infoView),
            CenterX()
        ]
        amountTextField.backgroundColor = UIColor.TtroColors.white.color.withAlphaComponent(0.8)
        amountTextField.textColor = UIColor.TtroColors.darkBlue.color
        amountTextField.font = UIFont.TtroPayWandFonts.regular4.font
        amountTextField.keyboardType = .numbersAndPunctuation
//        amountTextField.borderStyle = .roundedRect
        amountTextField.layer.cornerRadius = 10
        amountTextField.layer.masksToBounds = true
        amountTextField.isUserInteractionEnabled = true
        amountTextField.addTarget(self, action: #selector(self.onEdit), for: UIControlEvents.editingChanged)
        amountTextField.placeholder = "0"
        amountTextField.delegate = self
//        amountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
//        amountTextField.leftViewMode = .always
        amountTextField.returnKeyType = .default
        amountTextField.textAlignment = .center
        amountTextField.adjustsFontSizeToFitWidth = true
        amountTextField.autocorrectionType = .no
        
        currencySymbolLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
        currencySymbolLabel.font = amountTextField.font
        currencySymbolLabel.textColor = amountTextField.textColor
        //currencySymbolLabel.text = "$"
        amountTextField.rightView = currencySymbolLabel
        amountTextField.rightViewMode = .always
    }
    
    func setData(countryExtended: CountryExtended, isSourceCurrency : Bool){
        nameLabel.text = countryExtended.country.name
        currencyLabel.text = countryExtended.country.currency?.title
        flagImageView.image = countryExtended.flag
        amountTextField.placeholder = ""
        self.isSourceCurrency = isSourceCurrency
//        if (isSourceCurrency){
//            amountTextField.isUserInteractionEnabled = true
//        }
        currencySymbolLabel.text = countryExtended.country.currency?.symbol
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap() {
        onTapClosure()
    }
    
    
    
}

extension CountryView : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text?.appending(string),
            CountryView.numberFormatter.number(from: text)?.doubleValue != nil {
            if textField.text == "0" {
                textField.text = ""
            }
            return true
        } else if string == "" {
            return true
        } else {
            return false
        }
    }
    
    func onEdit(){
        delegate?.onAmountEdit?(self, amount: amount)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.endEditing(false) {
            return true
        } else {
            return false
        }
    }
}

////
public class KNumberFormatter : NumberFormatter {
    override public func string(from number: NSNumber) -> String? {
        var s = super.string(from: number)
        s = s?.replacingOccurrences(of: "000000000", with: "B", options: String.CompareOptions.backwards, range: nil)
        s = s?.replacingOccurrences(of: "000000", with: "M", options: String.CompareOptions.backwards, range: nil)
        s = s?.replacingOccurrences(of: "000", with: "K", options: String.CompareOptions.backwards, range: nil)
        return s
        
    }
    
    override public func number(from string: String) -> NSNumber? {
        var s = string
        s = s.replacingOccurrences(of: "B", with: "000000000", options: String.CompareOptions.backwards, range: nil)
        s = s.replacingOccurrences(of: "M", with: "000000", options: String.CompareOptions.backwards, range: nil)
        s = s.replacingOccurrences(of: "K", with: "000", options: String.CompareOptions.backwards, range: nil)
        return super.number(from: s)
    }
}
