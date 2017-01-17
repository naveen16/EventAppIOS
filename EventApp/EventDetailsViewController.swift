//
//  EventDetailsViewController.swift
//  EventApp
//
//  Created by Naveen Raj on 12/30/16.
//  Copyright © 2016 Naveen Raj. All rights reserved.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var userId: String!
    
    let eventDetailsToEvents = "EventDetailsToEvents"
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    var name: String!
    var date: String!
    var time: String!
    var address: String!
    var price: String!
    var eDescription: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        userId = user?.uid
        eventName.text = self.name
        eventDate.text = self.date
        eventTime.text = self.time
        eventAddress.numberOfLines = 3
        eventAddress.text = self.address
        eventPrice.text = "$"+self.price
        eventDescription.numberOfLines = 5
        eventDescription.text = self.eDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closePress(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.eventDetailsToEvents, sender: nil)
    }

    
}


