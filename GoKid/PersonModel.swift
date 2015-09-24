//
//  PersonModel.swift
//  GoKid
//
//  Created by Dean Quinanola on 9/23/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

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

    class func searchForContact(query: String, comp: (contacts: [AnyObject]!, error: NSError!) -> ()) {
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

        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let queue = dispatch_get_global_queue(qualityOfServiceClass, 0)

        addressBook.loadContactsOnQueue(queue) { (contacts: [AnyObject]!, error: NSError!) in
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
                                data.append(person)
                            }
                        }
                        if query.isValidEmail() {
                            var person = Person(
                                firstName: nil,
                                lastName: nil,
                                phoneNum: nil,
                                email: query)
                            data.append(person)
                        }
                    }
                }
            }
            
            comp(contacts: data, error: error)
        }
    }
    
}
