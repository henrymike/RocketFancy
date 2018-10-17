//
//  NetworkManager.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager: NSObject {
    
    //MARK: - Properties
    static let sharedInstance = NetworkManager()
    
    
    //MARK: - Networking Methods
    func fetchData() {
        print("URLRequest: \(SpaceXRouter.events.urlRequest!)")
        Alamofire.request(SpaceXRouter.events.urlRequest!).responseJSON { response in
            guard response.result.isSuccess,
                let value = response.result.value else {
                    print("Error while fetching events: \(String(describing: response.result.error))")
                    //                    completion(nil)
                    return
            }
            print("RR: \(value)")
            
            return
        }
    }
}
