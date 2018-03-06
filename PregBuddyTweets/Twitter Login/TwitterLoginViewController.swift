//
//  TwitterLoginViewController.swift
//  PregBuddyTweets
//
//  Created by Uber - Sivajee Battina on 06/03/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit
import Accounts
import Social
import Swifter
import SafariServices

class TwitterLoginViewController: UIViewController, SFSafariViewControllerDelegate {
    var swifter: Swifter
    let useACAccount = false
    let mentionString = "pregnancy"
    
    required init?(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT", consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx")
        
        super.init(coder: aDecoder)
    }
    
    //MARK:- Action methods
    @IBAction func didTouchUpInsideLoginButton(_ sender: AnyObject) {
        let failureHandler: (Error) -> Void = { error in
            self.alert(title: "Error", message: error.localizedDescription)
            
        }
        if useACAccount {
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            // Prompt the user for permission to their twitter account stored in the phone's settings
            accountStore.requestAccessToAccounts(with: accountType, options: nil) { granted, error in
                guard granted else {
                    self.alert(title: "Error", message: error!.localizedDescription)
                    return
                }
                
                let twitterAccounts = accountStore.accounts(with: accountType)!
                
                if twitterAccounts.isEmpty {
                    self.alert(title: "Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                } else {
                    let twitterAccount = twitterAccounts[0] as! ACAccount
                    self.swifter = Swifter(account: twitterAccount)
                    self.fetchTwitterSearchResultsWithMention()
                }
            }
        } else {
            let url = URL(string: "swifter://success")!
            swifter.authorize(with: url, presentFrom: self, success: { _, _ in
                self.fetchTwitterSearchResultsWithMention()
            }, failure: failureHandler)
        }
    }
    
    //MARK:- Custom methods
    func fetchTwitterSearchResultsWithMention() {
        let failureHandler: (Error) -> Void = { error in
            self.alert(title: "Error", message: error.localizedDescription)
        }
        self.swifter.searchTweet(using: mentionString, geocode: nil, lang: nil, locale: nil, resultType: "recent", count: 100, until: nil, sinceID: nil, maxID: nil, includeEntities: true, callback: nil, tweetMode: .default, success: { (json, searchMetaData) in
            
            // Successfully fetched timeline, so lets create and push the table view
            let tabVC = self.storyboard!.instantiateViewController(withIdentifier: "TabbarController") as! UITabBarController
            
            let firstTab = tabVC.viewControllers![0] as! HomeViewController
            guard let tweets = json.array else { return }
            firstTab.tweets = tweets
            self.navigationController?.pushViewController(tabVC, animated: true)
            
        }, failure: failureHandler)
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Safari delegate methods
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
