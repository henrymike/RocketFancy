//
//  ViewController.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //MARK: - Properties
    let networkManager = NetworkManager.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var launchesArray = [Launch]()
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let context = self.appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Launch")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "flightNumber") as! Int16)
            }
        } catch {
            print("Core Data Fetch failure")
        }
        
        //        networkManager.fetchData { (launches) in
        //            if let unwrappedLaunches = launches {
        //                self.launchesArray = unwrappedLaunches
        //            }
        //            print("Count: \(self.launchesArray.count)")
        //        }
        
    }
    
    
}

