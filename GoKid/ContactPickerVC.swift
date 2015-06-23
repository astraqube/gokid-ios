//
//  ContactPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class ContactPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var allContacts = [SwiftAddressBookPerson]()
    var tableViewData = [String]()
    var tableSelected = [Bool]()
    var collectionData = [(String, Int)]()
    
    struct Person {
        var fullName: String
        var selected: Bool
        var phoneNum: String
    }
    var tableDataSource = [Person]()

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
        var carpoolID = um.currentCarpool.id
        var phoneNumbers = getCurrentSelectedPhoneNumber()
        
        dm.invite(phoneNumbers, carpoolID: carpoolID) { (success, errorStr) in
            if success {
                self.showAlert("Success", messege: "Messege Sent", cancleTitle: "OK")
            } else {
                self.showAlert("Alert", messege: "Failed to Sent Messege", cancleTitle: "Cancle")
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var row = indexPath.row
        var cell = tableView.cellWithID("ContactCell", indexPath) as! ContactCell
        cell.nameLabel.text = tableViewData[row]
        cell.setSelection(tableSelected[row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row = indexPath.row
        var a = tableSelected[row]
        tableSelected[row] = !a
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        cell.setSelection(tableSelected[row])
        tryUpdateCollectionView()
    }
    
    // MARK: UICollectionView DataSource
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var row = indexPath.row
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactNameCell", forIndexPath: indexPath) as? ContactNameCell
        cell?.nameLabel.text = collectionData[row].0
        cell?.cancleButtonHandler = cancleButtonClick
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var str = NSString(string: collectionData[indexPath.row].0)
        var font = UIFont.boldSystemFontOfSize(17)
        var attributes = [NSFontAttributeName : font]
        var width = NSAttributedString(string: str as String, attributes: attributes).size().width
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
        var names = [String]()
        var selections = [Bool]()
        if let people = swiftAddressBook?.allPeople {
            allContacts = people
            for person in people {
                // var phoneNumbers = person.phoneNumbers?.map( {$0.value})
                var fullName = fullNameFromPerson(person)
                names.append(fullName)
                selections.append(false)
                println(fullName)
            }
        }
        tableViewData = names
        tableSelected = selections
        tableView.reloadData()
        withDelay(0.5) {
            self.tableView.reloadData()
        }
    }
    
    func fullNameFromPerson(person: SwiftAddressBookPerson) -> String {
        var firstName = ""
        var lastName = ""
        println("\(firstName)  \(lastName)")
        if person.firstName != nil { firstName = person.firstName! }
        if person.lastName != nil { lastName = person.lastName! }
        var fullName = firstName + " " + lastName
        return fullName
    }
    
    func tryUpdateCollectionView() {
        var data = [(String, Int)]()
        for i in 0..<tableViewData.count {
            if tableSelected[i] == true {
                data.append((tableViewData[i], i))
            }
        }
        collectionData = data
        collectionView.reloadData()
    }
    
    func cancleButtonClick(cell :ContactNameCell) {
        var i = collectionView.indexPathForCell(cell)!.row
        var data = collectionData[i]
        var index = data.1
        collectionData.removeAtIndex(i)
        tableSelected[index] = !tableSelected[index]
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func getCurrentSelectedPhoneNumber() -> [String] {
        var phoneNumbers = [String]()
        for i in 0..<tableViewData.count {
            if tableSelected[i] == true {
                if let number = firstPhoneNumberOfPerson(allContacts[i]) {
                    var final = number.delete(" ").delete("(").delete(")").delete("-")
                    phoneNumbers.append(final)
                }
            }
        }
        return phoneNumbers
    }
    
    func firstPhoneNumberOfPerson(person: SwiftAddressBookPerson) -> String? {
        if let phoneNumbers = person.phoneNumbers?.map({$0.value}) {
            if phoneNumbers.count > 0 {
                return phoneNumbers[0]
            }
        }
        return nil
    }
}



