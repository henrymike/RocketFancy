//
//  SpaceXRouter.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import Foundation
import Alamofire

public enum SpaceXRouter: URLRequestConvertible {
    enum Constants {
        static let baseURLPath = "https://api.spacexdata.com/v3/launches"
    }
    
    case events
    
    var path: String {
        switch self {
        case .events:
            return "/events.json"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        print("Request: \(request)")
        return try URLEncoding.default.encode(request, with: nil)
    }
}
