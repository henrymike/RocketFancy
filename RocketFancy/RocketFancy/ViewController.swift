//
//  ViewController.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    let networkManager = NetworkManager.sharedInstance
    var launchesArray = [Launch]()

    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.fetchData { (launches) in
            if let unwrappedLaunches = launches {
                self.launchesArray = unwrappedLaunches
            }
            print("Count: \(self.launchesArray.count)")
        }
        
    }


}

