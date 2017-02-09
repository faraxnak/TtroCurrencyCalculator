//
//  ViewController.swift
//  TtroCurrencyCalculatorSample
//
//  Created by Farid on 12/8/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import UIKit
import TtroCurrencyCalculator
import EasyPeasy

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
        present(calcVC, animated: true, completion: nil)
    }
}

