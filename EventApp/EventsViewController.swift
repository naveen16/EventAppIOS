///
//  EventsViewController.swift
//  EventApp
//
//  Created by Naveen Raj on 12/27/16.
//  Copyright © 2016 Naveen Raj. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class EventsViewController: UIViewController {
    
    var ref: DatabaseReference!
    var userId: String!
    
    let logoutSegue = "logoutSegue"
    let eventsToEventDetails = "EventsToEventDetails"
    
    var name: String!
    var date: String!
    var time: String!
    var address: String!
    var price: String!
    var eDescription: String!
    
    var topLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var draggableBackground: DraggableViewBackground!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        userId = user?.uid
        
        
        draggableBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableBackground)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.goToEventDetails (_:)))
        draggableBackground.addGestureRecognizer(gesture)
        
        topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        topLabel.text = "Events In Your Area"
        topLabel.center.x = self.view.center.x
        //self.view.addSubview(topLabel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goToEventDetails(_ sender:UITapGestureRecognizer){
        let event = draggableBackground.getEventObject()
        self.name = event.name
        self.date = event.date
        self.time = event.startTime+" - "+event.endTime
        self.address = event.location
        self.price = event.entryFee
        self.eDescription = event.description
        self.performSegue(withIdentifier: self.eventsToEventDetails, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == self.eventsToEventDetails) {
            let svc = segue.destination as! EventDetailsViewController;
            
            svc.name = self.name
            svc.date = self.date
            svc.time = self.time
            svc.address = self.address
            svc.price = self.price
            svc.eDescription = self.eDescription
            
        }
    }
    
}


