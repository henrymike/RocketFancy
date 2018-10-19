//
//  ViewController.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Alamofire
import AlamofireImage

class ViewController: UIViewController {
    
    
    //MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let launchPersistentContainer = NSPersistentContainer(name: "RocketFancy")
    private lazy var launchFetchedResultsController: NSFetchedResultsController<Launch> = {
        let fetchRequest: NSFetchRequest = Launch.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "flightNumber", ascending: true)]
        let launchFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        launchFetchedResultsController.delegate = self
        return launchFetchedResultsController
    }()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 88.0
        }
    }
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRemoteData()
    }
    
    func fetchCoreData () {
        do {
            try self.launchFetchedResultsController.performFetch()
            tableView.reloadData()
            print("Fetch attempt successful; data reloaded")
        } catch {
            let fetchError = error as Error
            print("Unable to perform fetch request: \(fetchError)")
        }
    }
    
    
    //MARK: - Date Formatter Methods
    let dateFormatterRaw: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    let dateFormatterDisplay: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension ViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//        //reload tableView
//    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let launchSections = launchFetchedResultsController.sections else { return 0 }
        return launchSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let launches = launchFetchedResultsController.fetchedObjects else { return 0 }
        return launches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LaunchTableViewCell else { return UITableViewCell() }
        let launch = launchFetchedResultsController.object(at: indexPath)
        
        let date: Date!; let dateString: String!
        if let launchDate = launch.launchDate  {
            date = dateFormatterRaw.date(from: launchDate)
            dateString = dateFormatterDisplay.string(from: date)
        } else { dateString = "" }
        
        cell.configureCellForLaunch(launch, launchDate: dateString)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}

extension ViewController {
    //MARK: - Networking Methods
    func fetchRemoteData() {
        print("URLRequest: \(SpaceXRouter.launches.urlRequest!)")
        Alamofire.request(SpaceXRouter.launches.urlRequest!).responseJSON { response in
            switch response.result {
            case .success(let value):
                let managedObjectContext = self.appDelegate.persistentContainer.viewContext
                let json = JSON(value).arrayValue
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Launch")
                
                for item in json {
                    if let launchEntity = NSEntityDescription.entity(forEntityName: "Launch", in: managedObjectContext) {
                        let launchInfo = NSManagedObject(entity: launchEntity, insertInto: managedObjectContext) as! Launch
                        
                        //Set flightNumber & check for existing entry in Core Data
                        if let flightNumber = item["flight_number"].int16 {
                            let predicate = NSPredicate(format: "%K == %i", "flightNumber", flightNumber)
                            fetchRequest.predicate = predicate
                            let fetchedResults = try? managedObjectContext.fetch(fetchRequest) as? [Launch]
                            if let results = fetchedResults {
                                if (results?.count)! > 0 {
                                    print("Result found - continuing: \(String(describing: results))")
                                    break
                                }
                            }
                            launchInfo.flightNumber = flightNumber
                        } else {
                            print("Error: Missing unique Flight Number info. Put user error message here.")
                            return
                        }
                        launchInfo.hasLaunched = item["upcoming"].boolValue
                        launchInfo.imageMissionPatchUrl = item["links"]["mission_patch"].stringValue
                        launchInfo.launchDate = item["launch_date_utc"].stringValue
                        launchInfo.launchSite = item["launch_site"]["site_name_long"].stringValue
                        launchInfo.launchSuccess = item["launch_success"].boolValue
                        launchInfo.launchYear = item["launch_year"].stringValue
                        launchInfo.missionName = item["mission_name"].stringValue
                        launchInfo.wikipediaLink = item["links"]["wikipedia"].stringValue
                        
                        self.appDelegate.saveContext()
                        print("Appended launch: \(launchInfo)")
                    }
                }
            case .failure(let error):
                print("Error while fetching from network: \(String(describing: error))")
            }
            
            self.fetchCoreData()
        }
    }
}
