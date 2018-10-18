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
                    if let launch = NSEntityDescription.entity(forEntityName: "Launch", in: context) {
                        let launchInfo = NSManagedObject(entity: launch, insertInto: context) as! Launch
                        if let flightNumber = item["flight_number"].int16 {
                            launchInfo.flightNumber = flightNumber
                        }
                        launchInfo.hasLaunched = item["upcoming"].boolValue
                        launchInfo.imageMissionPatchUrl = item["mission_patch"].stringValue
                        launchInfo.launchDate = item["launch_date_local"].stringValue
                        launchInfo.launchSite = item["launch_site"]["site_name_long"].stringValue
                        launchInfo.launchSuccess = item["launch_success"].boolValue
                        //                launch.launchToRocket = json[0]["rocket"]["rocket_name"].stringValue
                        launchInfo.launchYear = item["launch_year"].stringValue
                        launchInfo.missionName = item["mission_name"].stringValue
                        launchInfo.wikipediaLink = item["links"]["wikipedia"].stringValue
                        
                        launches.append(launchInfo)
                        self.appDelegate.saveContext()
                        print("Appended launch: \(launchInfo)")
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
