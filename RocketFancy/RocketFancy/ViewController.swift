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
    let imageCache = NSCache<NSString, UIImage>()
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData { (launches) in }
        
        do {
            try self.launchFetchedResultsController.performFetch()
            print("Fetch attempt successful")
        } catch {
            let fetchError = error as Error
            print("Unable to perform fetch request: \(fetchError)")
        }
        print("Escaped trycatch block")
        
        
        //Core Data Simple Fetch
        //        let context = self.appDelegate.persistentContainer.viewContext
        //        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Launch")
        //        request.returnsObjectsAsFaults = false
        //
        //        do {
        //            let result = try context.fetch(request)
        //            for data in result as! [NSManagedObject] {
        //                print(data.value(forKey: "flightNumber") as! Int16)
        //            }
        //        } catch {
        //            print("Core Data Fetch failure")
        //        }
        
        //Save Core Data Initially
//                networkManager.fetchData { (launches) in
//                    if let unwrappedLaunches = launches {
//                        self.launchesArray = unwrappedLaunches
//                    }
//                    print("Count: \(self.launchesArray.count)")
//                }
        
    }
    
    
    //MARK: - Core Data Methods
    func loadLaunchData() {
        if launchFetchedResultsController == nil {
            //            let request = Launch.create
        }
    }
    
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //reload tableView
    }
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
    func fetchData(completion: @escaping ([Launch]?) -> Void) {
        print("URLRequest: \(SpaceXRouter.launches.urlRequest!)")
        Alamofire.request(SpaceXRouter.launches.urlRequest!).responseJSON { response in
            switch response.result {
            case .success(let value):
//                var launches = [Launch]()
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
                        
//                        launches.append(launchInfo)
                        self.appDelegate.saveContext()
                        print("Appended launch: \(launchInfo)")
                    }
                }
//                print("Count: \(launches.count)")
                
            case .failure(let error):
                print("Error while fetching from network: \(String(describing: error))")
                return
            }
            return
        }
    }
}
