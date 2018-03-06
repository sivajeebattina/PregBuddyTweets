//
//  CommonViewController.swift
//  PregBuddyTweets
//
//  Created by Uber - Sivajee Battina on 06/03/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func showAnAlertWithMessage(msg: String){
        let alert = UIAlertController(title: "Hey buddy!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
