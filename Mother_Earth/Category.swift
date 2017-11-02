//
//  Category.swift
//  Mother_Earth
//
//  Created by Sonar on 25/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import Foundation

struct Category: Equatable{
    let id : Int
    let name : String
    let description: String
    let apiEndPoint : String
    var events = [Event]()
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let name = json["title"] as? String,
            let description = json["description"] as? String else {
                return nil
        }
        self.id = id
        self.name = name
        self.description = description
        self.apiEndPoint = "\(EONETRequestRouter.categoriesEndPoint)/\(id)"
    }
    
    // MARK: - Equatable
    static func ==(lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
