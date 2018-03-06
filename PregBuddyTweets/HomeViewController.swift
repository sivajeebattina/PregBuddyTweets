//
//  ViewController.swift
//  PregBuddyTweets
//
//  Created by Uber - Sivajee Battina on 06/03/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit
import CoreData
import Swifter
import SafariServices

class TweetCell: UITableViewCell {
    @IBOutlet weak var tweetLabel:UILabel!
    @IBOutlet weak var bookMarkButton:UIButton!
}

class HomeViewController: CommonViewController {
    enum FILTER:String{
        case ALL = "All Tweets", MOST_LIKED = "Most Liked Tweets", MOST_RETWEETED = "Most Retweeted Tweets"
    }
    var currentFilter:FILTER = .ALL
    
    var tweets : [JSON] = []
    var showingTweetsArray:[JSON] = []
    let ELEMENTS_FOR_PAGE = 20
    var currentPageControlIndex = 0
    var totalNumberOfPages = 0
    
    //MARK:- Outlet connections
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated:false);

        totalNumberOfPages = Int(ceil(Double(tweets.count/20)))
        
        //Tableview dynamic sizing of cells
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Left & Right gesture recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.tableView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.tableView.addGestureRecognizer(swipeLeft)
        
        loadTweetsToShow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle()
        setRightBarButtonItem()
    }
    
    //MARK:- Custom methods
    func setNavigationTitle(){
        self.tabBarController?.navigationItem.title = currentFilter.rawValue
    }
    
    func setRightBarButtonItem(){
            let button = UIButton(type: .custom)
            button.setImage(#imageLiteral(resourceName: "filter icon"), for: .normal)
            button.frame = CGRect(x: 0.0, y: 0.0, width: 35.0, height: 35.0)
            button.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
        
            self.tabBarController?.navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    func loadTweetsToShow(){
        var subTweets:[JSON] = []
        if currentFilter == FILTER.ALL {
            if ((currentPageControlIndex+1)*ELEMENTS_FOR_PAGE <= tweets.count) {
                let startIndex = currentPageControlIndex * ELEMENTS_FOR_PAGE
                let endIndex = (currentPageControlIndex+1)*ELEMENTS_FOR_PAGE
                
                subTweets = Array(tweets[startIndex..<endIndex])
                showingTweetsArray.removeAll()
                showingTweetsArray.append(contentsOf: subTweets)
            }
            else {
                let startIndex = currentPageControlIndex*ELEMENTS_FOR_PAGE
                let endIndex = tweets.count
                subTweets = Array(tweets[startIndex..<endIndex])
            }
            
            pageControl.isHidden = false
        }
        else if currentFilter == FILTER.MOST_LIKED {
            let beforeSortTweets = tweets
            let sortedArr = beforeSortTweets.sorted(by: { Int(($0.object!["favorite_count"]?.double)!) > Int(($1.object!["favorite_count"]?.double)!) })
            subTweets.append(contentsOf: sortedArr.prefix(10))
            
            pageControl.isHidden = true
        }
        else if currentFilter == FILTER.MOST_RETWEETED {
            let beforeSortTweets = tweets
            let sortedArr = beforeSortTweets.sorted(by: { Int(($0.object!["retweet_count"]?.double)!) > Int(($1.object!["retweet_count"]?.double)!) })
            subTweets.append(contentsOf: sortedArr.prefix(10))
            
            pageControl.isHidden = true
        }
        
        showingTweetsArray.removeAll()
        showingTweetsArray.append(contentsOf: subTweets)
        UIView.transition(with: tableView, duration: 0.8, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)

    }
    
    //MARK:- Action methods
    @objc func filterButtonClicked(){
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select filter to apply", message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let allTweetsAction = UIAlertAction(title: "All Tweets", style: .default)
        { _ in
            self.currentFilter = FILTER.ALL
            self.setNavigationTitle()
            self.loadTweetsToShow()
        }
        actionSheetController.addAction(allTweetsAction)
        
        //Most Liked
        let mostLikedActionButton = UIAlertAction(title: "Most Liked", style: .default)
        { _ in
            self.currentFilter = FILTER.MOST_LIKED
            self.setNavigationTitle()
            self.loadTweetsToShow()
        }
        actionSheetController.addAction(mostLikedActionButton)
        
        let mostRetweetedActionBtn = UIAlertAction(title: "Most Retweeted", style: .default)
        { _ in
            self.currentFilter = FILTER.MOST_RETWEETED
            self.setNavigationTitle()
            self.loadTweetsToShow()
        }
        actionSheetController.addAction(mostRetweetedActionBtn)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }

    @IBAction func bookMarkClicked(_ sender: UIButton) {
        let indexOfTweet = sender.tag
        let tweetText = showingTweetsArray[indexOfTweet]["text"].string ?? ""
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        request.predicate = NSPredicate(format: "tweetText = %@", tweetText)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            if result.count > 0 {
               showAnAlertWithMessage(msg: "You have already bookmarked this tweet")
            }
            else {
                let entity = NSEntityDescription.entity(forEntityName: "Tweet", in: context)
                let tweetObj = NSManagedObject(entity: entity!, insertInto: context)
                
                tweetObj.setValue(tweetText, forKey: "tweetText")
                
                do {
                    try context.save()
                    showAnAlertWithMessage(msg: "You book marked it successfully.")
                } catch {
                    showAnAlertWithMessage(msg: "Something went wrong while bookmarking")
                }
            }
            
        } catch {
            showAnAlertWithMessage(msg: "Something went wrong while bookmarking")
        }
    }
    
    //MARK:- Gesture recognizer methods
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if currentPageControlIndex > 0 {
                    currentPageControlIndex = currentPageControlIndex - 1
                }
            case UISwipeGestureRecognizerDirection.left:
                if currentPageControlIndex < (totalNumberOfPages-1){
                    currentPageControlIndex = currentPageControlIndex + 1
                }
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
            
            if pageControl.currentPage != currentPageControlIndex {
                pageControl.currentPage = currentPageControlIndex
                loadTweetsToShow()
            }
        }
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingTweetsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCellIdentifier", for: indexPath) as! TweetCell
        tweetCell.tweetLabel?.text = showingTweetsArray[indexPath.row]["text"].string
        tweetCell.bookMarkButton.tag = indexPath.row
        return tweetCell
    }
}
