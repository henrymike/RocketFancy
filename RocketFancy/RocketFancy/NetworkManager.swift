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
import CoreData

class NetworkManager: NSObject {
    
    //MARK: - Properties
    static let sharedInstance = NetworkManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //MARK: - Networking Methods
    func fetchData(completion: @escaping ([Launch]?) -> Void) {
        print("URLRequest: \(SpaceXRouter.launches.urlRequest!)")
        Alamofire.request(SpaceXRouter.launches.urlRequest!).responseJSON { response in
            switch response.result {
            case .success(let value):
                let context = self.appDelegate.persistentContainer.viewContext
                var launches = [Launch]()
                let json = JSON(value).arrayValue
                for item in json {
                    print("1")
                    if let entity = NSEntityDescription.entity(forEntityName: "Launch", in: context) {
                        let launch = NSManagedObject(entity: entity, insertInto: context) as! Launch
                        if let flightNumber = item["flight_number"].int16 {
                            launch.flightNumber = flightNumber
                        }
                        launch.hasLaunched = item["upcoming"].boolValue
                        launch.imageMissionPatchUrl = item["mission_patch"].stringValue
                        launch.launchDate = item["launch_date_local"].stringValue
                        launch.launchSite = item["launch_site"]["site_name_long"].stringValue
                        launch.launchSuccess = item["launch_success"].boolValue
                        //                launch.launchToRocket = json[0]["rocket"]["rocket_name"].stringValue
                        launch.launchYear = item["launch_year"].stringValue
                        launch.missionName = item["mission_name"].stringValue
                        launch.wikipediaLink = item["links"]["wikipedia"].stringValue
                        
                        launches.append(launch)
                        print("Appended launch: \(launch)")
                    }
                }
                print("Count: \(launches.count)")
               
            case .failure(let error):
                print("Error while fetching from network: \(String(describing: error))")
                return
            }
            return
            //           completion(launches)
        }
        
    }
}
