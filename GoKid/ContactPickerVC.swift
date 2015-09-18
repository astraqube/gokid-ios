//
//  ContactPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class Person: NSObject {
    var firstName: String?
    var lastName: String?
    var selected: Bool = false
    var phoneNum: APPhoneWithLabel?
    var email: String?

    override func isEqual(object: AnyObject?) -> Bool {
        if let person = object as? Person {
            if person.phoneNum != nil && self.phoneNum != nil {
                return person.phoneNum!.phone == self.phoneNum!.phone
            }
            if person.email != nil && self.email != nil {
                return person.email! == self.email!
            }
        }
        return false
    }

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
        if phoneNum != nil {
            return phoneNum!.phone
        }
        if email != nil {
            return email!
        }
        return ""
    }

    var contactDisplay: String {
        if phoneNum != nil {
            return "\(phoneNum!.localizedLabel): \(phoneNum!.phone)"
        }
        if email != nil {
            return "email: \(email!)"
        }
        return ""
    }

    init(firstName: String?, lastName: String?, phoneNum: APPhoneWithLabel?, email: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNum = phoneNum
        self.email = email
    }

    func matches(keywords: String) -> Bool {
        if keywords == "" { return true }
        let stack = "\(fullName) \(contactDisplay)"
        return stack.lowercaseString.rangeOfString(keywords.lowercaseString) != nil
    }
}


class ContactPickerVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var carpool: CarpoolModel!

    @IBOutlet weak var searchBarInput: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var tableHeaderSource = NSMutableArray()
    var tableDataSource = NSMutableDictionary()
    var collectionDataSource = NSMutableSet()

    override func viewDidLoad() {
        super.viewDidLoad()
        tryUpdateTableView()

        // FIXME: temporary support for CarpoolEditVC's invocation
        if carpool == nil {
            carpool = userManager.currentCarpoolModel
        }

        self.subtitleLabel.text = carpool.descriptionString
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarColorDark()
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
        return tableHeaderSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = tableHeaderSource.objectAtIndex(section) as! String
        return (tableDataSource.objectForKey(letter.capitalizedString) as! NSArray).count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableHeaderSource.objectAtIndex(section) as? String
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
        let letter = tableHeaderSource.objectAtIndex(indexPath.section) as! String
        var person = tableDataSource[letter]?.objectAtIndex(indexPath.row) as! Person

        person.selected = self.collectionDataSource.containsObject(person)
        cell.loadPerson(person)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        let letter = tableHeaderSource.objectAtIndex(indexPath.section) as! String
        var person = tableDataSource[letter]?.objectAtIndex(indexPath.row) as! Person

        person.selected = self.collectionDataSource.containsObject(person)
        cell.loadPerson(person)

        if person.selected {
            person.selected = false
            collectionDataSource.removeObject(person)
        } else {
            person.selected = true
            collectionDataSource.addObject(person)
            searchBarInput.text = ""
            searchForContact(searchBarInput.text)
        }

        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return tableHeaderSource as [AnyObject]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
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
        var person = collectionDataSource.allObjects[indexPath.row] as! Person
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactNameCell", forIndexPath: indexPath) as? ContactNameCell
        cell?.nameLabel.text = person.fullName
        cell?.cancleButtonHandler = cancelButtonClick
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var person = collectionDataSource.allObjects[indexPath.row] as! Person
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
            self.searchForContact("")
            break;

        case .Denied:
            self.showAlert("Unable to access your contacts", messege: "Please allow access to Contacts", cancleTitle: "OK")
            break;
        }
    }
    
    func constructTableDataAndUpdate(data: [Person]) {
        tableDataSource.removeAllObjects()
        tableHeaderSource.removeAllObjects()

        let letters = NSCharacterSet.letterCharacterSet()

        for person in data {
            var char = person.fullName.firstCharacter()
            let _letter = !letters.characterIsMember(first(char.utf16)!) ? "#" : char
            let letter = _letter.capitalizedString
            var section: NSMutableArray!

            if let _section = tableDataSource.objectForKey(letter) as? NSMutableArray {
                section = _section
            } else {
                tableHeaderSource.addObject(letter)
                tableDataSource.setObject(NSMutableArray(), forKey: letter)
                section = tableDataSource.objectForKey(letter) as! NSMutableArray
            }

            section.addObject(person)
        }

        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func cancelButtonClick(cell :ContactNameCell) {
        var row = collectionView.indexPathForCell(cell)!.row
        var person = collectionDataSource.allObjects[row] as! Person

        person.selected = false
        collectionDataSource.removeObject(person)
        
        onMainThread {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func getCurrentSelectedPhoneNumber() -> [String] {
        var contacts = [String]()
        for obj in collectionDataSource {
            var person = obj as! Person
            if person.phoneNum != nil {
                contacts.append(person.phoneNum!.phone)
            } else if person.email != nil {
                contacts.append(person.email!)
            }
        }
        
        return contacts
    }
}

extension ContactPickerVC: UISearchBarDelegate {

    func searchForContact(query: String) {
        debounce(NSTimeInterval(0.3), queue: dispatch_get_main_queue()) {

            var data = [Person]()
            let addressBook = APAddressBook()

            addressBook.fieldsMask = .Default | .PhonesWithLabels | .Emails
            addressBook.sortDescriptors = [
                NSSortDescriptor(key: "firstName", ascending: true),
                NSSortDescriptor(key: "lastName", ascending: true)
            ]
            addressBook.filterBlock = { (contact: APContact!) -> Bool in
                if query != "" {
                    let name = "\(contact.firstName) \(contact.lastName)"
                    let number = " ".join(contact.phones as! [String])
                    let email = " ".join(contact.emails as! [String])

                    if name.lowercaseString.rangeOfString(query.lowercaseString) != nil {
                        return true
                    }

                    if number.rangeOfString(query) != nil {
                        return true
                    }

                    if email.lowercaseString.rangeOfString(query.lowercaseString) != nil {
                        return true
                    }

                    return false

                } else {
                    return contact.phones.count > 0 || contact.emails.count > 0
                }
            }
            
            addressBook.loadContacts { (contacts: [AnyObject]!, error: NSError!) in
                if (contacts != nil) {
                    if !contacts.isEmpty {
                        for addressBookPerson in contacts {
                            if let c = addressBookPerson as? APContact {
                                for phone in c.phonesWithLabels {
                                    var person = Person(
                                        firstName: c.firstName,
                                        lastName: c.lastName,
                                        phoneNum: phone as? APPhoneWithLabel,
                                        email: nil)
                                    person.selected = self.collectionDataSource.containsObject(person)
                                    if person.matches(query) {
                                        data.append(person)
                                    }
                                }
                                for email in c.emails {
                                    var person = Person(
                                        firstName: c.firstName,
                                        lastName: c.lastName,
                                        phoneNum: nil,
                                        email: email as? String)
                                    person.selected = self.collectionDataSource.containsObject(person)
                                    if person.matches(query) {
                                        data.append(person)
                                    }
                                }
                            }
                        }
                    } else {
                        if query != "" {
                            if let phoneNumber = query.extractNumbers() {
                                if count(phoneNumber) >= 10 {
                                    var person = Person(
                                        firstName: nil,
                                        lastName: nil,
                                        phoneNum: APPhoneWithLabel(phone: query, originalLabel: "Number", localizedLabel: "Number"),
                                        email: nil)
                                    person.selected = self.collectionDataSource.containsObject(person)
                                    data.append(person)
                                }
                            }
                            if query.isValidEmail() {
                                var person = Person(
                                    firstName: nil,
                                    lastName: nil,
                                    phoneNum: nil,
                                    email: query)
                                person.selected = self.collectionDataSource.containsObject(person)
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
