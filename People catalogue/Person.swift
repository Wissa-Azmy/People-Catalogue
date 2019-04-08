//
//  Person.swift
//  People catalogue
//
//  Created by Wissa Azmy on 4/3/19.
//  Copyright © 2019 Wissa Azmy. All rights reserved.
//

import Foundation


class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
