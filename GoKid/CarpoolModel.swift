//
//  CarpoolModel.swift
//  
//
//  Created by Bingwen Fu on 6/11/15.
//
//

import UIKit

class CarpoolModel: NSObject {
    var name = ""
    var id = 0
    
    init(json: JSON) {
        name = json["carpool"]["name"].stringValue
        id = json["carpool"]["id"].intValue
        super.init()
    }
    
    override init() {
        super.init()
    }
}
