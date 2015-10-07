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
        if keywords.extractNumbers() != "" {
            return stack.extractNumbers().rangeOfString(keywords.extractNumbers()) != nil
        } else {
            return stack.lowercaseString.rangeOfString(keywords.lowercaseString) != nil
        }
    }

    // MARK: Singleton
    class var addressBook : APAddressBook {
        struct Static {
            static let instance : APAddressBook = APAddressBook()
        }
        return Static.instance
    }

    class func searchForContact(query: String, comp: (contacts: [AnyObject]!, error: NSError!) -> ()) {
        if APAddressBook.access() != .Granted { return }
        
        var data = [Person]()

        addressBook.fieldsMask = .Default | .PhonesWithLabels | .Emails
        addressBook.sortDescriptors = [
            NSSortDescriptor(key: "firstName", ascending: true),
            NSSortDescriptor(key: "lastName", ascending: true)
        ]

        addressBook.filterBlock = { (contact: APContact!) -> Bool in
            if query != "" {
                let name = "\(contact.firstName) \(contact.lastName)"

                if name.lowercaseString.rangeOfString(query.lowercaseString) != nil {
                    return true
                }

                if contact.phones != nil {
                    let number = " ".join((contact.phones as! [String]).map {
                            return $0.extractNumbers()
                        })

                    let numQuery = query.extractNumbers()
                    if numQuery != "" && number.rangeOfString(numQuery) != nil {
                        return true
                    }
                }

                if contact.emails != nil {
                    let email = " ".join(contact.emails as! [String])

                    if email.lowercaseString.rangeOfString(query.lowercaseString) != nil {
                        return true
                    }
                }

                return false

            } else {
                return (contact.phones != nil && !contact.phones.isEmpty) || (contact.emails != nil && !contact.emails.isEmpty)
            }
        }

        let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)

        addressBook.loadContactsOnQueue(queue) { (contacts: [AnyObject]!, error: NSError!) in
            if error != nil {
                print(error.localizedDescription)
            } else {
                if !contacts.isEmpty {
                    for addressBookPerson in contacts {
                        if let c = addressBookPerson as? APContact {
                            if c.phonesWithLabels != nil {
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
                            }

                            if c.emails != nil {
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
                    }
                } else {
                    if query != "" {
                        let phoneNumber = query.extractNumbers()
                        if phoneNumber != "" {
                            if count(phoneNumber) >= 10 {
                                let phoneNum = APPhoneWithLabel()
                                phoneNum.phone = query
                                phoneNum.originalLabel = "Number"
                                phoneNum.localizedLabel = "Number"
                                
                                let person = Person(
                                    firstName: nil,
                                    lastName: nil,
                                    phoneNum: phoneNum,
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
