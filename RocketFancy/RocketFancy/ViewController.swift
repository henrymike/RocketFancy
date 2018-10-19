//
//  ViewController.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/17/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class ViewController: UIViewController {
    
    
    //MARK: - Properties
    let networkManager = NetworkManager.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private lazy var launchFetchedResultsController: NSFetchedResultsController<Launch> = {
        let fetchRequest: NSFetchRequest = Launch.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "flightNumber", ascending: true)]
        let launchFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        launchFetchedResultsController.delegate = self
        return launchFetchedResultsController
    }()
    private let launchPersistentContainer = NSPersistentContainer(name: "RocketFancy")
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 88.0
        }
    }
    let imageCache = NSCache<NSString, UIImage>()
    //    var launchesArray = [Launch]()
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
