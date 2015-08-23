//
//  ContactPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class Person {
    var firstName: String?
    var lastName: String?
    var selected: Bool
    var phoneNum: APPhoneWithLabel

    var fullName: String {
        if firstName != nil && lastName != nil {
            return "\(firstName!) \(lastName!)"
        }
        if firstName != nil {
            return firstName!
        }
        if lastName != nil {
            return lastName!
        }
        return "(No Name)"
    }

    var phoneDisplay: String {
        return "\(phoneNum.localizedLabel): \(phoneNum.phone)"
    }

    init(firstName: String?, lastName: String?, selected: Bool, phoneNum: APPhoneWithLabel) {
        self.firstName = firstName
        self.lastName = lastName
        self.selected = selected
        self.phoneNum = phoneNum
    }
}

class ContactPickerVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var carpool: CarpoolModel!

    let addressBook = APAddressBook()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var tableDataSource = [[Person]]()
    var collectionDataSource = NSMutableArray.new() //[Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAddressBook()
        setUpDataSourceAndDelegate()
        tryUpdateTableView()

        self.subtitleLabel.text = carpool.descriptionString
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarColorDark()
    }

    func setUpDataSourceAndDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func setUpAddressBook() {
        addressBook.fieldsMask = .Default | .PhonesWithLabels
        addressBook.sortDescriptors = [
            NSSortDescriptor(key: "firstName", ascending: true),
            NSSortDescriptor(key: "lastName", ascending: true)
        ]
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        var phoneNumbers = getCurrentSelectedPhoneNumber()
        
        LoadingView.showWithMaskType(.Black)
        dataManager.invite(phoneNumbers, carpoolID: carpool.id) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.showAlert("Success", messege: "Message Sent", cancleTitle: "OK")
            } else {
                self.showAlert("Fail to sent messege", messege: errorStr, cancleTitle: "Cancel")
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var title = alertView.buttonTitleAtIndex(buttonIndex)
        if title == "OK" {
            var vc = vcWithID("CarpoolSucceedVC") as! CarpoolSucceedVC
            vc.carpool = self.carpool
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
            var char = person.fullName.firstCharacter()
            if char == "(" {
                return "No Name"
            } else {
                return char
            }
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var id = "customHeader";
        var vHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier(id) as? UITableViewHeaderFooterView
        
        if  vHeader == nil {
            vHeader = UITableViewHeaderFooterView(reuseIdentifier: id)
            vHeader?.textLabel.font = UIFont(name: "Raleway-Bold", size: 15)
        }
        vHeader?.textLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        vHeader?.contentView.backgroundColor = rgb(246, 253, 243)
        return vHeader;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.cellWithID("ContactCell", indexPath) as! ContactCell
        var person = tableDataSource[indexPath.section][indexPath.row]
        cell.nameLabel.text = person.fullName
        cell.phoneNumLabel.text = person.phoneDisplay

        var selected = containsPerson(person)
        cell.setSelection(selected)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var person = tableDataSource[indexPath.section][indexPath.row]
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        var selected = containsPerson(person)
        
        if selected {
            removePerson(person)
            cell.setSelection(false)
        } else {
            addPerson(person)
            cell.setSelection(true)
        }

        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    // terrible
    func containsPerson(p2: Person) -> Bool {
        for o in collectionDataSource {
            var p = o as! Person
            if p.firstName == p2.firstName && p.lastName == p2.lastName && p.phoneNum.phone == p2.phoneNum.phone {
                return true
            }
        }
        return false
    }
    
    func removePerson(p2: Person) {
        var newArray = NSMutableArray.new()
        for o in collectionDataSource {
            var p = o as! Person
            if p.firstName == p2.firstName && p.lastName == p2.lastName && p.phoneNum.phone == p2.phoneNum.phone {
                // don't append
            } else {
                newArray.addObject(p)
            }
        }
        collectionDataSource = newArray
    }
    
    func addPerson(p2: Person) {
        collectionDataSource.addObject(p2)
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
        var person = collectionDataSource[indexPath.row] as! Person
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactNameCell", forIndexPath: indexPath) as? ContactNameCell
        cell?.nameLabel.text = person.fullName
        cell?.cancleButtonHandler = cancleButtonClick
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var person = collectionDataSource[indexPath.row] as! Person
        var font = UIFont.boldSystemFontOfSize(15)
        var attributes = [NSFontAttributeName : font]
        var width = NSAttributedString(string: person.fullName, attributes: attributes).size().width
        return CGSizeMake(width+40, 20)
    }
    
    // MARK: Address Book Method
    // --------------------------------------------------------------------------------------------
    
    func tryUpdateTableView() {
        switch(APAddressBook.access())
        {
        case .Unknown:
            APAddressBook.requestAccess { (success: Bool, error: NSError!) in
                self.tryUpdateTableView()
            }
            break;

        case .Granted:
            self.fetchDataUpdateTableView()
            break;

        case .Denied:
            self.showAlert("Unable to access your contacts", messege: "Please allow access to Contacts", cancleTitle: "OK")
            break;
        }
    }
    
    func fetchDataUpdateTableView() {
        searchForContact("")
    }
    
    func constructTableDataAndUpdate(data: [Person]) {
        tableDataSource = [[Person]]()
        var sections = [Person]()
        var last: String!

        for person in data {
            if person.fullName.firstCharacter() != last {
                tableDataSource.append(sections)
                sections = [Person]()
            }
            sections.append(person)
            last = person.fullName.firstCharacter()
        }
        tableDataSource.append(sections)

        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func cancleButtonClick(cell :ContactNameCell) {
        var row = collectionView.indexPathForCell(cell)!.row
        var person = collectionDataSource[row] as! Person
        
        person.selected = false
        tableView.reloadData()
        
        collectionDataSource.removeObject(person)
        
        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func getCurrentSelectedPhoneNumber() -> [String] {
        var phoneNumbers = [String]()
        for obj in collectionDataSource {
            var person = obj as! Person
            phoneNumbers.append(person.phoneNum.phone)
        }
        
        return phoneNumbers
    }
}

extension ContactPickerVC: UISearchBarDelegate {

    func searchForContact(query: String) {
        debounce(NSTimeInterval(0.5), queue: dispatch_get_main_queue()) {

            var data = [Person]()

            self.addressBook.filterBlock = { (contact: APContact!) -> Bool in
                if query != "" {
                    let name = "\(contact.firstName) \(contact.lastName)"
                    let number = " ".join(contact.phones as! [String])

                    if name.lowercaseString.rangeOfString(query.lowercaseString) != nil {
                        return true
                    }

                    if number.rangeOfString(query) != nil {
                        return true
                    }

                    return false

                } else {
                    return contact.phones.count > 0
                }
            }
            
            self.addressBook.loadContacts { (contacts: [AnyObject]!, error: NSError!) in
                if (contacts != nil) {
                    for addressBookPerson in contacts {
                        if let c = addressBookPerson as? APContact {
                            for phone in c.phonesWithLabels {
                                let person = Person(firstName: c.firstName,
                                    lastName: c.lastName,
                                    selected: false,
                                    phoneNum: phone as! APPhoneWithLabel)
                                data.append(person)
                            }
                        }
                    }
                    self.constructTableDataAndUpdate(data)
                } else if (error != nil) {
                    self.showAlert("Error", messege: error.localizedDescription, cancleTitle: "OK")
                }
            }
        }()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchForContact(searchBar.text)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchForContact(searchText)
    }
}
