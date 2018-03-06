//
//  BookMarksViewController.swift
//  PregBuddyTweets
//
//  Created by Uber - Sivajee Battina on 06/03/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit
import CoreData

class BookMarkTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetLabel:UILabel!
}

class BookMarksViewController: CommonViewController {
    var bookMarksArray:[String] = []
    
    //MARK:- Outlet connections
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated:false);
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "BookMarks"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        loadTweetsToShow()
    }
    
    func loadTweetsToShow(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
            bookMarksArray.removeAll()
            for tweet in results {
                let tweetText = tweet.value(forKeyPath: "tweetText") as? String ?? ""
                bookMarksArray.append(tweetText)
            }
            
            tableView.reloadData()
        } catch {
            showAnAlertWithMessage(msg: "Something went wrong while fetching data")
        }
    }
}

extension BookMarksViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetCell = tableView.dequeueReusableCell(withIdentifier: "BookMarkCellIdentifier", for: indexPath) as! BookMarkTableViewCell
        tweetCell.tweetLabel?.text = bookMarksArray[indexPath.row]
        return tweetCell
    }
    
}

