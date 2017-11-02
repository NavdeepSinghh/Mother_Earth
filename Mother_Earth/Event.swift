//
//  Event.swift
//  Mother_Earth
//
//  Created by Sonar on 25/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import Foundation

struct Event {
    let id: String
    let title: String
    let description: String
    let link: URL?
    let closeDate: Date?
    let categories: [Int]
    let locations: [Location]
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let title = json["title"] as? String,
            let description = json["description"] as? String,
            let link = json["link"] as? String,
            let closeDate = json["closed"] as? String,
            let categories = json["categories"] as? [[String: Any]] else {
                return nil
        }
        self.id = id
        self.title = title
        self.description = description
        self.link = URL(string: link)
        self.closeDate = EONETRequestRouter.dateFormatter.date(from: closeDate)
        self.categories = categories.flatMap { categoryDesc in
            guard let catID = categoryDesc["id"] as? Int else {
                return nil
            }
            return catID
        }
        if let geometries = json["geometries"] as? [[String: Any]] {
            locations = geometries.flatMap(Location.init)
        } else {
            locations = []
        }
    }
    
    static func compareDates(lhs: Event, rhs: Event) -> Bool {
        switch (lhs.closeDate, rhs.closeDate) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return false
        case (let ldate, let rdate): return ldate! < rdate!
        }
    }
}
