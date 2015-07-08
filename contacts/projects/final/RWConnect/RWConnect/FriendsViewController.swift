//
//  FriendsViewController.swift
//  RWConnect
//
//  Created by Evan Dekhayser on 6/16/15.
//  Copyright © 2015 Razeware, LLC. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class FriendsViewController: UITableViewController {
	
	var friendsList = Friend.defaultContacts()
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return friendsList.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell")!
		
		let friend = friendsList[indexPath.row]
		cell.textLabel?.text = friend.firstName + " " + friend.lastName
		cell.detailTextLabel?.text = friend.workEmail
		cell.imageView?.image = friend.profilePicture
		
		return cell
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
	
}

// Show Contact Info on Accessory Press
extension FriendsViewController{
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		let friend = friendsList[indexPath.row]
		let contact = friend.contactValue
		let contactViewController = CNContactViewController(forUnknownContact: contact)
		contactViewController.allowsEditing = false
		contactViewController.allowsActions = false
		contactViewController.edgesForExtendedLayout = .None
		navigationController?.pushViewController(contactViewController, animated: true)
	}
}

// Import Friends from Contacts

extension FriendsViewController: CNContactPickerDelegate{
	@IBAction func addFriends(sender: UIBarButtonItem) {
		let contactPicker = CNContactPickerViewController()
		contactPicker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0", argumentArray: nil)
		contactPicker.delegate = self
		presentViewController(contactPicker, animated: true, completion: nil)
	}
	
	func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
		let newFriends = contacts.map{ contact in
			return Friend(contact: contact)
		}
		for friend in newFriends {
			if !friendsList.contains(friend){
				friendsList.append(friend)
			}
		}
		tableView.reloadData()
	}
}

// Create New Contacts from Friends
extension FriendsViewController{
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let createContact = UITableViewRowAction(style: .Normal, title: "Create Contact") { rowAction, indexPath in
			
			tableView.setEditing(false, animated: true)
			
			let contactStore = CNContactStore()
			contactStore.requestAccessForEntityType(CNEntityType.Contacts) { userGrantedAccess, _ in
				guard userGrantedAccess else {
					self.presentPermissionErrorAlert()
					return
				}
				
				let friend = self.friendsList[indexPath.row]
				let contactFormatter = CNContactFormatter()
				let contactName = contactFormatter.stringFromContact(friend.contactValue)!
				let predicateForMatchingName = CNContact.predicateForContactsMatchingName(contactName)
				let matchingContacts = try! contactStore.unifiedContactsMatchingPredicate(predicateForMatchingName, keysToFetch: [])
				if !matchingContacts.isEmpty{
					self.saveFriendToContacts(friend)
				} else {
					let alert = UIAlertController(title: "Contact Already Exists", message: nil, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
					dispatch_async(dispatch_get_main_queue()){
						self.presentViewController(alert, animated: true, completion: nil)
					}
				}
			}
		}
		createContact.backgroundColor = rwGreen
		return [createContact]
	}
	
	func saveFriendToContacts(friend: Friend){
		let contact = friend.contactValue
		let saveRequest = CNSaveRequest()
		saveRequest.addContact(contact, toContainerWithIdentifier: nil)
		
		handleSaveRequest(saveRequest)
	}
	
	func handleSaveRequest(saveRequest: CNSaveRequest){
		do{
			let contactStore = CNContactStore()
			try contactStore.executeSaveRequest(saveRequest)
			let successAlert = UIAlertController(title: "Contacts Saved", message: nil, preferredStyle: .Alert)
			successAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			dispatch_async(dispatch_get_main_queue()){
				self.presentViewController(successAlert, animated: true, completion: nil)
			}
		} catch {
			let alert = UIAlertController(title: "Could Not Save Contact", message: "An unknown error occurred.", preferredStyle: .Alert)
			let dismissAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
			alert.addAction(dismissAction)
			dispatch_async(dispatch_get_main_queue()){
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
	
	func presentPermissionErrorAlert(){
		dispatch_async(dispatch_get_main_queue()){
			let alert = UIAlertController(title: "Could Not Save Contact", message: "How am I supposed to add the contact if you didn't give me permission?", preferredStyle: .Alert)
			
			let openSettingsAction = UIAlertAction(title: "Settings", style: .Default, handler: { alert in
				UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
			})
			let dismissAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
			alert.addAction(openSettingsAction)
			alert.addAction(dismissAction)
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
}

