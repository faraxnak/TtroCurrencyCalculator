//
//  Country.swift
//  TtroCurrencyCalculator
//
//  Created by Farid on 12/8/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import Foundation

class Country {
    
    static var countryList = [Country]()
    
    static func loadCountries(){
        if (countryList.count == 0){
            if let path = Bundle.main.path(forResource: "test", ofType: "json")
            {
                do {
                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                    print(jsonData)
                } catch {
                    print(error)
                }
//                if let jsonData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
//                {
//                    if let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
//                    {
//                        if let persons : NSArray = jsonResult["person"] as? NSArray
//                        {
//                            // Do stuff
//                        }
//                    }
//                }
            }
        }
    }
}
