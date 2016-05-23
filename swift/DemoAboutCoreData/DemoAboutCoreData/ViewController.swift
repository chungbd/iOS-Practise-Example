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
    @IBOutlet weak var btnEditMode: UIBarButtonItem!

    var txtUserName:UITextField?
    var listUser:[AnyObject]?
    var isDeleteMode:Bool = false
    var isReorderMode:Bool = false

    let cellIdentifier = "demoCell"

    //MARK: Life cycle
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

    //MARK: - Public Methods
    func addNewUserWith(user: String) -> Void {
        DataController.createAndSaveWith(user)
        listUser = _dataController.getAllUserName()
        tblDemo.reloadData()
    }
//    - (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//        [super setEditing:editing animated:animated];
//        [tableView setEditing:editing animated:YES];
//        if (editing) {
//        addButton.enabled = NO;
//        } else {
//        addButton.enabled = YES;
//        }
//    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tblDemo.setEditing(editing, animated: true)
    }
    //MARK: -

    //MARK: - IBActions
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

    @IBAction func touchUpInside_btnEditMode(sender: AnyObject) {
//        print("Click on Edit mode")
        if isReorderMode || isDeleteMode {
            setEditing(false, animated: true)
            btnEditMode.title = "Edit"
            isDeleteMode  = false
            isReorderMode = false
        } else {
            btnEditMode.title = "Cancel Edit"
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "Delete Mode", style: .Destructive) { [unowned self](action) in
                self.isDeleteMode = true
                self.setEditing(true, animated: true)
            }

            let insertAction = UIAlertAction(title: "Reorder Mode", style: .Default) { [unowned self](action) in
                self.isReorderMode = true
                self.setEditing(true, animated: true)
            }
            let cancel = UIAlertAction(title: "Cance", style: .Cancel) { [unowned self](action) in
                self.isReorderMode = false
                self.isDeleteMode = false
                self.setEditing(false, animated: true)
                self.btnEditMode.title = "Edit"
            }

            alert.addAction(deleteAction)
            alert.addAction(insertAction)
            alert.addAction(cancel)

            if let presenter = alert.popoverPresentationController {
                let buttonView = btnEditMode.valueForKey("view") as? UIView
                presenter.sourceView = buttonView
                presenter.sourceRect = (buttonView?.bounds)!
            }
            self.presentViewController(alert, animated: true) {
                
            }
        }
    }


    //MARK: - UITableViewDataSource
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

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //update to Core data
            let person = self.listUser![indexPath.row] as! Person
            DataController.deleteObject(with: person)

            //update to Model
            self.listUser?.removeAtIndex(indexPath.row)

            //update to UI
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        if editingStyle == .Insert {
            print("Do insert mode")
        }

    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let objToMove = self.listUser![sourceIndexPath.row]
        self.listUser?.removeAtIndex(sourceIndexPath.row)
        self.listUser?.insert(objToMove, atIndex: destinationIndexPath.row)
    }

    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if isDeleteMode {
            return .Delete
        } else {
            return .None
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isReorderMode {
            return true
        }
        return false
    }


}

