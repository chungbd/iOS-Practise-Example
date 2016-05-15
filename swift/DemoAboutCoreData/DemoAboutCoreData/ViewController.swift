//
//  ViewController.swift
//  DemoAboutCoreData
//
//  Created by Chung BD on 5/12/16.
//  Copyright © 2016 Chung BD. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblDemo: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    var txtUserName:UITextField?
    var listUser:[AnyObject]?

    let cellIdentifier = "demoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navBar.topItem?.title = "Demo about Core Data"
        listUser = _dataController.getAllUserName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK - Public Methods
    func addNewUserWith(user: String) -> Void {
        _dataController.createAndSaveWith(user)
        listUser = _dataController.getAllUserName()
        tblDemo.reloadData()
    }

    //MARK - IBActions
    @IBAction func btnAdd(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new user name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { [unowned self]action in
            if let user = self.txtUserName?.text where user.characters.count > 0 {
                self.addNewUserWith(user)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
        alert.addTextFieldWithConfigurationHandler { [unowned self](textfield) in
            textfield.placeholder = "User Name"
            self.txtUserName = textfield
        }

        self.presentViewController(alert, animated: true, completion: nil)
    }


    //MARK - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listUser != nil {
            return listUser!.count
        } else {
            return 0
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        let person = listUser![indexPath.row] as! Person


        let txt = cell?.viewWithTag(10) as! UILabel
        txt.text = person.name
        return cell!
    }


}

