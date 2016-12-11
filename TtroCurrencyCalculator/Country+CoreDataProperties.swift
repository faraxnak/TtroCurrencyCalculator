//
//  Country+CoreDataProperties.swift
//  TtroCurrencyCalculator
//
//  Created by Farid on 12/11/16.
//  Copyright © 2016 ParsPay. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country");
    }

    @NSManaged public var currency: String?
    @NSManaged public var name: String?
    @NSManaged public var iso: String?
    @NSManaged public var phoneCode: NSObject?

}
