//
//  ParseResponse.swift
//  TtroCurrencyCalculator
//
//  Created by Farid on 12/11/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import Foundation
import Gloss

enum ResponseType {
    case countryNames
    case countryCurrencies
    case exchangeRates
}

class ParseResponse  {
    func parse(_ data : Data?, messageType : ResponseType) -> Decodable?{
        do {
            var jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
            if (jsonResponse == nil){
                let jsonArray = try JSONSerialization.jsonObject(with: data!, options:
                    JSONSerialization.ReadingOptions.mutableContainers)  as? [[String: AnyObject]]
                jsonResponse = jsonArray![0]
            }
            switch messageType {
            
            default:
                return GenericResponse(json: jsonResponse!)
            }
            
        } catch {
            print(error)
            return nil
        }
    }
}

class GenericResponse : Decodable {
    var dict = [String : String]()
    required init?(json: JSON) {
        let keys = Array(json.keys)
        for key in keys {
            dict[key] = (json[key] as? String) ?? ""
        }
    }
}
