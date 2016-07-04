//
//  ViewController.swift
//  CheckConnection
//
//  Created by Chung BD on 5/29/16.
//  Copyright © 2016 Chung BD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func touchUpInside_btn(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            showAlertView("Your connection is good")
        } else {
            showAlertView("Please check your connection again!!!!")
        }

    }

    func showAlertView(content:String?) -> Void {
        let alert = UIAlertController(title: "Warning", message: content, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

