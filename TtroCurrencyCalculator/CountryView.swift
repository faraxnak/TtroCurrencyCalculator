//
//  CountryView.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy

@objc public protocol CountryViewDelegate : class {
    
    @objc optional func onAmountEdit(amount : Double)
}

public class CountryView: UIView {
    
    fileprivate var nameLabel : UILabel!
    fileprivate var currencyLabel : UILabel!
    fileprivate var flagImageView : UIImageView!
    fileprivate var amountTextField : UITextField!
    
    let elementHeight : CGFloat = 50
    
    fileprivate var onTapClosure : (() -> ())!
    
    static let numberFormatter = KNumberFormatter()
    
    public var delegate : CountryViewDelegate?
    
    public var currency : String {
        get {
            return currencyLabel.text ?? ""
        }
    }
    
    public var amount : Double {
        get {
            return Double(amountTextField.text ?? "") ?? 0
        }
        set {
            amountTextField.text = CountryView.numberFormatter.string(from: NSNumber(value: newValue))
        }
    }
    
    public convenience init(onTap onTapClosure : @escaping () -> ()) {
        self.init(frame : .zero)
        self.onTapClosure = onTapClosure
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        flagImageView.addGestureRecognizer(tapGR)
        
    }
    
    override public init(frame : CGRect){
        super.init(frame: frame)
        
        flagImageView = UIImageView()
        flagImageView.contentMode = .scaleAspectFit
        addSubview(flagImageView)
        flagImageView <- [
            Height(elementHeight),
            Width().like(flagImageView, .height),
            CenterY(),
            Left(elementHeight/2)
        ]
        
        flagImageView.layer.cornerRadius = elementHeight/2
        flagImageView.layer.masksToBounds = true
        flagImageView.backgroundColor = UIColor.cyan
        flagImageView.isUserInteractionEnabled = true
        
        nameLabel = UILabel()
        addSubview(nameLabel)
        nameLabel <- [
            Left(elementHeight/2).to(flagImageView),
            CenterY(-elementHeight/2),
            Width(*0.4).like(self)
        ]
        
        currencyLabel = UILabel()
        self.addSubview(currencyLabel)
        currencyLabel <- [
            Left(20).to(nameLabel),
            CenterY().to(nameLabel),
        ]
        
        amountTextField = UITextField()
        addSubview(amountTextField)
        amountTextField <- [
            CenterY(elementHeight/2),
            Left().to(nameLabel, .left),
            Right().to(currencyLabel, .right)
        ]
        amountTextField.keyboardType = .numberPad
        amountTextField.borderStyle = .roundedRect
        amountTextField.isUserInteractionEnabled = false
        amountTextField.addTarget(self, action: #selector(self.onEdit), for: UIControlEvents.editingChanged)
        amountTextField.placeholder = "Tap to select country"
        amountTextField.delegate = self
        
    }
    
    public func setData(country: Country, isSourceCurrency : Bool){
        nameLabel.text = country.name
        currencyLabel.text = country.currency
        flagImageView.image = country.flag
        amountTextField.placeholder = ""
        if (isSourceCurrency){
            amountTextField.isUserInteractionEnabled = true
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap() {
        onTapClosure()
    }
    
    
    
}

extension CountryView : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (Double(string) != nil || string == "") {
            return true
        } else {
            return false
        }
    }
    
    func onEdit(){
        delegate?.onAmountEdit?(amount: amount)
    }
}

////
class KNumberFormatter : NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        var s = super.string(from: number)
        s = s?.replacingOccurrences(of: "000000000", with: "B", options: String.CompareOptions.backwards, range: nil)
        s = s?.replacingOccurrences(of: "000000", with: "M", options: String.CompareOptions.backwards, range: nil)
        s = s?.replacingOccurrences(of: "000", with: "K", options: String.CompareOptions.backwards, range: nil)
        return s
        
    }
}
