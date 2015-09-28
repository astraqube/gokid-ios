//
//  ContactPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class ContactPickerVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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

        if phoneNumbers.isEmpty {
            self.showAlert("Error", messege: "You have not selected any recipients", cancleTitle: "Cancel")
            return
        }

        LoadingView.showWithMaskType(.Black)
        dataManager.invite(phoneNumbers, carpoolID: carpool.id) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                var successAlert = UIAlertController(title: "Success", message: "Invitations Sent", preferredStyle: .Alert)

                successAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert: UIAlertAction!) in
                    let vc = vcWithID("CarpoolSucceedVC") as! CarpoolSucceedVC
                    vc.carpool = self.carpool
                    self.navigationController?.pushViewController(vc, animated: true)
                }))

                self.presentViewController(successAlert, animated: true, completion: nil)
            } else {
                self.showAlert("Failed to send Invitations", messege: errorStr, cancleTitle: "Cancel")
            }
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
            searchContact(searchBarInput.text)
        }

        self.collectionView.reloadData()
        self.tableView.reloadData()
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
            self.searchContact("")
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

    func searchContact(keywords: String) {
        Person.searchForContact(keywords) { (contacts: [AnyObject]!, error: NSError!) in
            if error == nil {
                self.constructTableDataAndUpdate(contacts.map { (c: AnyObject) -> Person in
                    let person = c as! Person
                    person.selected = self.collectionDataSource.containsObject(person)
                    return person
                })
            } else {
                self.showAlert("Error", messege: error.localizedDescription, cancleTitle: "OK")
            }
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchContact(searchBar.text)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchContact(searchText)
    }

}
