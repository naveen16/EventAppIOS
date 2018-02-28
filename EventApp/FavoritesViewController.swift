//
//  FavoritesViewController.swift
//  EventApp
//
//  Created by Naveen Raj on 12/30/16.
//  Copyright © 2016 Naveen Raj. All rights reserved.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ref: DatabaseReference!
    var userId: String!
    
    let favoritesToEvents = "FavoritesToEvents"
    let favoritesToEventDetails = "FavoritesToEventDetails"
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    var eventsArray: [String] = []
    var eventObjectsArray: [Event] = []
    var interestedEventKeys: [String] = []
    var interestedEventValues : [String] = []
    
    var name: String!
    var date: String!
    var time: String!
    var address: String!
    var price: String!
    var eDescription: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        userId = user?.uid
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        populateEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateEvents(){
        print("IN POPULATE EVENTS FAVORITES")
        self.ref.child("users").child(userId).child("interested_events").observe(.value, with: { snapshot in
            self.eventObjectsArray = []
            self.eventsArray = []
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                print(rest.key)
                //print("VALUE: \(rest.value)")
                self.interestedEventKeys.append(rest.key)
                self.interestedEventValues.append(rest.value as! String)
                self.ref.child("events").child(rest.value as! String).observe(.value, with: { snap in
                    let event = Event(snapshot: snap)
                    self.eventsArray.append(event.name)
                    self.eventObjectsArray.append(event)
                })
            }
            self.eventsTableView.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventObjectsArray[indexPath.item]
        name = event.name
        date = event.date
        time = event.startTime+" - "+event.endTime
        address = event.location
        price = event.entryFee
        eDescription = event.description
        self.performSegue(withIdentifier: self.favoritesToEventDetails, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == self.favoritesToEventDetails) {
            let svc = segue.destination as! EventDetailsViewController;
            svc.name = name
            svc.date = date
            svc.time = time
            svc.address = address
            svc.price = price
            svc.eDescription = eDescription
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath as IndexPath)
        cell.textLabel?.text = eventsArray[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            eventsArray.remove(at: indexPath.item)
            eventObjectsArray.remove(at: indexPath.item)
            let key = interestedEventKeys.remove(at: indexPath.item)
            let value = interestedEventValues.remove(at: indexPath.item)
            eventsTableView.deleteRows(at: [indexPath], with: .fade)
            self.ref.child("users").child(userId).child("interested_events").child(key).removeValue()
            self.ref.child("users").child(userId).child("not_interested_events").child(key).setValue(value)
        }
    }
    
}


