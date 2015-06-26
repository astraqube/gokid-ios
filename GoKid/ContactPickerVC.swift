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
    
    init(firstName: String, fullName: String, selected: Bool, phoneNum: String) {
        self.fullName = fullName
        self.firstName = firstName
        self.selected = selected
        self.phoneNum = phoneNum
    }
}

class ContactPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var tableDataSource = [Person]()
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.cellWithID("ContactCell", indexPath) as! ContactCell
        var person = tableDataSource[indexPath.row]
        cell.nameLabel.text = person.fullName
        cell.setSelection(person.selected)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var person = tableDataSource[indexPath.row]
        person.selected = !person.selected
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        cell.setSelection(person.selected)
        tryUpdateCollectionView()
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
                var fullName = getFullNameOfPerson(addressBookPerson)
                var firstName = getFirstNameOfPerson(addressBookPerson)
                var phoneNumber = getProccessedPhoneNumOfPerson(addressBookPerson)
                
                var person = Person(firstName: firstName, fullName: fullName, selected: false, phoneNum: phoneNumber)
                data.append(person)
            }
        }
        data.sort({ $0.firstName < $1.firstName })
        tableDataSource = data
        tableView.reloadData()
        withDelay(0.5) {
            self.tableView.reloadData()
        }
    }
    
    func tryUpdateCollectionView() {
        var data = [Person]()
        for person in tableDataSource {
            if person.selected {
                data.append(person)
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
        for person in tableDataSource {
            if person.selected {
                phoneNumbers.append(person.phoneNum)
            }
        }
        return phoneNumbers
    }
    
    func getFirstNameOfPerson(person: SwiftAddressBookPerson) -> String {
        if let name = person.firstName {
            return name
        }
        return "null"
    }
    
    func getFullNameOfPerson(person: SwiftAddressBookPerson) -> String {
        var firstName = ""
        var lastName = ""
        println("\(firstName)  \(lastName)")
        if person.firstName != nil { firstName = person.firstName! }
        if person.lastName != nil { lastName = person.lastName! }
        var fullName = firstName + " " + lastName
        return fullName
    }
    
    func getProccessedPhoneNumOfPerson(person: SwiftAddressBookPerson) -> String {
        if let number = getFirstRawPhoneNumberOfPerson(person) {
            var final = number.delete(" ").delete("(").delete(")").delete("-")
            return final
        }
        return ""
    }
    
    func getFirstRawPhoneNumberOfPerson(person: SwiftAddressBookPerson) -> String? {
        if let phoneNumbers = person.phoneNumbers?.map({$0.value}) {
            if phoneNumbers.count > 0 {
                return phoneNumbers[0]
            }
        }
        return nil
    }
}



