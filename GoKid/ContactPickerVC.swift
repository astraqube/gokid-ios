//
//  ContactPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class Person {
    var firstName: String
    var fullName: String
    var selected: Bool
    var phoneNum: String
    var rawPhoneNum: String
    
    init(firstName: String, fullName: String, selected: Bool, phoneNum: String, rawPhoneNum: String) {
        self.fullName = fullName
        self.firstName = firstName
        self.selected = selected
        self.phoneNum = phoneNum
        self.rawPhoneNum = rawPhoneNum
    }
}

class ContactPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var tableDataSource = [[Person]]()
    var collectionDataSource = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpDataSourceAndDelegate()
        tryUpdateTableView()
    }
    
    func setUpNavigationBar() {
        setNavBarTitle("Add Friends")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    func setUpDataSourceAndDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var dm = DataManager.sharedInstance
        var um = UserManager.sharedInstance
        var carpoolID = um.currentCarpoolModel.id
        var phoneNumbers = getCurrentSelectedPhoneNumber()
        
        dm.invite(phoneNumbers, carpoolID: carpoolID) { (success, errorStr) in
            if success {
                self.showAlert("Success", messege: "Messege Sent", cancleTitle: "OK")
            } else {
                self.showAlert("Alert", messege: "Failed to Sent Messege", cancleTitle: "Cancel")
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var title = alertView.buttonTitleAtIndex(buttonIndex)
        if title == "OK" {
            var vc = vcWithID("CarpoolSucceedVC")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableDataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var people = tableDataSource[section]
        if people.count > 0 {
            var person = people[0]
            return person.firstName.firstCharacter()
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.cellWithID("ContactCell", indexPath) as! ContactCell
        var person = tableDataSource[indexPath.section][indexPath.row]
        cell.nameLabel.text = person.fullName
        cell.phoneNumLabel.text = person.rawPhoneNum
        cell.setSelection(person.selected)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var person = tableDataSource[indexPath.section][indexPath.row]
        person.selected = !person.selected
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        cell.setSelection(person.selected)
        tryUpdateCollectionView()
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    // MARK: UICollectionView DataSource
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var person = collectionDataSource[indexPath.row]
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactNameCell", forIndexPath: indexPath) as? ContactNameCell
        cell?.nameLabel.text = person.firstName
        cell?.cancleButtonHandler = cancleButtonClick
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var person = collectionDataSource[indexPath.row]
        var font = UIFont.boldSystemFontOfSize(17)
        var attributes = [NSFontAttributeName : font]
        var width = NSAttributedString(string: person.firstName, attributes: attributes).size().width
        return CGSizeMake(width+50, 50)
    }
    
    // MARK: Address Book Method
    // --------------------------------------------------------------------------------------------
    
    func tryUpdateTableView() {
        swiftAddressBook?.requestAccessWithCompletion() { (success, error) in
            if success { self.fetchDataUpdateTableView() }
            else {
                var title = "Cannot access contacts"
                var messege = "Please allow access to Contacts in order to invite"
                self.showAlert(title, messege: messege, cancleTitle: "OK")
            }
        }
    }
    
    func fetchDataUpdateTableView() {
        var data = [Person]()
        if let people = swiftAddressBook?.allPeople {
            for addressBookPerson in people {
                var fullName = addressBookPerson.fullName()
                var firstName = addressBookPerson.firstNameStr()
                var phoneNum = addressBookPerson.proccessedPhoneNum()
                var rawNum = addressBookPerson.rawPhoneNumber()
                var person = Person(firstName: firstName, fullName: fullName, selected: false, phoneNum: phoneNum, rawPhoneNum: rawNum)
                data.append(person)
            }
        }
        data.sort({ $0.firstName < $1.firstName })
        constructTableDataAndUpdate(data)
    }
    
    func constructTableDataAndUpdate(data: [Person]) {
        tableDataSource = [[Person]]()
        var sections = [Person]()
        var last = data[0].firstName.firstCharacter()
        for person in data {
            if person.firstName.firstCharacter() != last {
                tableDataSource.append(sections)
                sections = [Person]()
            }
            sections.append(person)
        }
        tableDataSource.append(sections)
        
        tableView.reloadData()
        withDelay(0.5) {
            self.tableView.reloadData()
        }
    }
    
    func tryUpdateCollectionView() {
        var data = [Person]()
        for section in tableDataSource {
            for person in section {
                if person.selected {
                    data.append(person)
                }
            }
        }
        collectionDataSource = data
        collectionView.reloadData()
    }
    
    func cancleButtonClick(cell :ContactNameCell) {
        var row = collectionView.indexPathForCell(cell)!.row
        var person = collectionDataSource[row]
        
        person.selected = false
        tableView.reloadData()
        
        collectionDataSource.removeAtIndex(row)
        collectionView.reloadData()
    }
    
    func getCurrentSelectedPhoneNumber() -> [String] {
        var phoneNumbers = [String]()
        for section in tableDataSource {
            for person in section {
                if person.selected {
                    phoneNumbers.append(person.phoneNum)
                }
            }
        }
        return phoneNumbers
    }
}



