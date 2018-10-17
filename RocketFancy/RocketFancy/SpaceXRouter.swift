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
        static let baseURLPath = "https://api.spacexdata.com/v3"
    }
    
    case cores
    case dragons
    case launches
    case rockets
    
    var path: String {
        switch self {
        case .cores:
            return "/cores"
        case .dragons:
            return "/dragons"
        case .launches:
            return "/launches"
        case .rockets:
            return "/rockets"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        return try URLEncoding.default.encode(request, with: nil)
    }
}
