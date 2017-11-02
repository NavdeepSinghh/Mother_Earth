//
//  EONETRequestRouter.swift
//  Mother_Earth
//
//  Created by Sonar on 25/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EONETRequestRouter {
    static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
    static let categoriesEndPoint = "/categories"
    static let eventsEndPoint = "/events"
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
    static func selectedEvents(events: [Event], forCategory category: Category) -> [Event]{
        return events.filter{ event in
            return event.categories.contains(category.id) &&
                !category.events.contains {
                    $0.id == event.id
            }
        }
            .sorted(by: Event.compareDates)
    }
    
    
    // Generic Request
    static func request(endPoint: String, query: [String: Any] = [:]) -> Observable<[String: Any]> {
        do {
            guard let url = URL(string: API)?.appendingPathComponent(endPoint), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else{
                throw EONETError.invalidURL(endPoint)
            }
            components.queryItems = try query.flatMap{ (key, value) in
                guard let val = value as? CustomStringConvertible else {
                    throw EONETError.invalidParameter(key, value)
                }
                return URLQueryItem (name: key, value: val.description)
            }
            guard let finalURL = components.url else {
                throw EONETError.invalidURL(endPoint)
            }
            
            let request = URLRequest(url: finalURL)
            
            return URLSession.shared.rx.response(request: request)
                .map{ _, data -> [String: Any] in
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [String: Any] else {
                        throw EONETError.invalidJSON(finalURL.absoluteString)
                    }
                    return result
            }
        }catch {
            return Observable.empty()
        }
    }
    
    // Fetch Categories
    static var categories: Observable<[Category]> = {
        return EONETRequestRouter.request(endPoint: categoriesEndPoint)
            .map { data in
                let categories = data["categories"] as? [[String: Any]] ?? []
                return categories
                    .flatMap(Category.init)
                    .sorted { $0.name < $1.name }
            }
            .shareReplay(1)
    }()
    
    fileprivate static func events(forLast days: Int, closed: Bool) ->
        Observable<[Event]> {
            return request(endPoint: eventsEndPoint, query: [
                "days": NSNumber(value: days),
                "status": (closed ? "closed" : "open")
                ])
                .map { json in
                    guard let raw = json["events"] as? [[String: Any]] else {
                        throw EONETError.invalidJSON(eventsEndPoint)
                    }
                    return raw.flatMap(Event.init)
            }
    }
    
    static func events(forLast days: Int = 360) -> Observable<[Event]> {
        let openEvents = events(forLast: days, closed: false)
        let closedEvents = events(forLast: days, closed: true)
        return openEvents.concat(closedEvents)
    }
    
}
