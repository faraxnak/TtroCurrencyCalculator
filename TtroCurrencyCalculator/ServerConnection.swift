//
//  ServerConnection.swift
//  TtroCurrencyCalculator
//
//  Created by Farid on 12/11/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//

import Foundation
import Alamofire
import Gloss

class ServerConnection {
    init(){
        
    }
    
    typealias onReceivingResponse = (_ data: Decodable?, _ serverConnection : Bool, _ messageType : ResponseType) -> ()
    
    static let sharedInstance = ServerConnection()
    
    let parser = ParseResponse()
    
    let serverURL = "http://country.io/"
    
    func getCountryNames(callback : @escaping onReceivingResponse){
        let actionString = "names.json"
        let messageType = ResponseType.countryNames
        
        Alamofire.request(
            serverURL + actionString,
            method: .get,
            encoding: JSONEncoding.default)
            .validate()
            .responseJSON { (response) -> Void in
                self.handleResponse(response, responseType: messageType, responseHandler: callback)
        }
    }
    
    func getCountryCurrencies(callback : @escaping onReceivingResponse){
        let actionString = "currency.json"
        let messageType = ResponseType.countryNames
        
        Alamofire.request(
            serverURL + actionString,
            method: .get,
            encoding: JSONEncoding.default)
            .validate()
            .responseJSON { (response) -> Void in
                self.handleResponse(response, responseType: messageType, responseHandler: callback)
        }
    }
    
    func handleResponse(_ response : DataResponse<Any>! = nil, responseType messageType : ResponseType, responseHandler callback : onReceivingResponse){
        print("Message Type : \(messageType)")
        let isSuccess = response.result.isSuccess
        guard isSuccess else {
            print("Error : \(response.result.error)")
            //print(HTTPStatusCode(HTTPResponse: response.response) as Any)
            if response.data != nil {
                print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String)
            }
            callback(nil, false, messageType)
            return
        }
        print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String)
        callback(self.parser.parse(response.data, messageType: messageType),true, messageType)
    }
}
