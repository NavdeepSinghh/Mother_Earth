//
//  Error.swift
//  Mother_Earth
//
//  Created by Sonar on 25/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import Foundation

enum EONETError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
}
