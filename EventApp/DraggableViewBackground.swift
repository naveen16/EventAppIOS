//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import AlamofireImage

class DraggableViewBackground: UIView, DraggableViewDelegate, CLLocationManagerDelegate {
    var exampleCardLabels: [String]!
    var allCards: [DraggableView]!
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 420
    let CARD_WIDTH: CGFloat = 330
    
    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var emptyLabel: UILabel!
    var imageEvent: UIImage!
    var bgImage: UIImageView?
    var topLabel: UILabel!
    
    var ref: DatabaseReference!
    var userId: String!
    
    var eventList: [Event]!
    var eventKeys: [String]!
    var interestedEvents: [String]!
    var notInterestedEvents: [String]!
    
    let locationManager = CLLocationManager()
    
    let eventsToEventDetails = "EventsToEventDetails"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        userId = user?.uid
        exampleCardLabels = []
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
        eventList = []
        eventKeys = []
        interestedEvents = []
        notInterestedEvents = []
        self.populateInterestedEvents()
    }
    
    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        self.frame = CGRect(x: 0, y: 75, width: self.frame.width, height: self.frame.height)
        
        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 35, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10 - 75, width: 59, height: 59))
        xButton.setImage(UIImage(named: "xButton"), for: UIControlState())
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)
        
        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 85, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10 - 75, width: 59, height: 59))
        checkButton.setImage(UIImage(named: "checkButton"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 150, width: 250, height: 300))
        emptyLabel.text = "   No more events in your area \n\n            Check back later"
        emptyLabel.numberOfLines = 0
        emptyLabel.center.x = self.center.x
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
        self.addSubview(emptyLabel)
    }
    
    func createDraggableViewWithDataAtIndex(_ index: NSInteger) -> DraggableView {
        let event = eventList[index]
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2 - 75, width: CARD_WIDTH, height: CARD_HEIGHT))
        draggableView.information.text = exampleCardLabels[index]
        draggableView.information.textRect(forBounds: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT), limitedToNumberOfLines: 2)
        let imageUrlString = event.imageUrl
        let imageUrl:URL = URL(string: imageUrlString)!
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.CARD_WIDTH, height: self.CARD_HEIGHT-100))
            //imageView.center = draggableView.center
            
            // When from background thread, UI needs to be updated on main_queue
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                imageView.image = image
                //imageView.contentMode = UIViewContentMode.scaleAspectFit
                draggableView.addSubview(imageView)
            }
        }
        draggableView.information.numberOfLines = 0
        draggableView.delegate = self
        return draggableView
    }
    
    func getEventObject() -> Event{
        return eventList[0]
    }
    
    func populateInterestedEvents(){
        print("IN INTERESTED EVENTS")
        self.ref.child("users").child(userId).child("interested_events").observeSingleEvent(of: .value, with: { (snapshot)in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                self.interestedEvents.append(rest.value as! String)
            }
            self.populateNotInterestedEvents()
        })
        
    }
    
    func populateNotInterestedEvents(){
        print("IN NOT INTERESTED EVENTS")
        self.ref.child("users").child(userId).child("not_interested_events").observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                self.notInterestedEvents.append(rest.value as! String)
            }
            self.populateEvents()
        })
    }
    
    func populateEvents(){
        print("IN POPULATE EVENTS")
        ref.child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                //print(rest.key)
                //print("VALUE: \(rest.value)")
                let event = Event(snapshot: rest)
                let currentDate = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                var day = "01"
                var month = "01"
                var year = "1400"
                let eDate = event.date
                if eDate.count == 10 {
                    var start = eDate.index(eDate.startIndex, offsetBy: 0)
                    var end = eDate.index(eDate.startIndex, offsetBy: 2)
                    var range = start..<end
                    month = String(eDate[range])
                    start = eDate.index(eDate.startIndex, offsetBy: 3)
                    end = eDate.index(eDate.startIndex, offsetBy: 5)
                    range = start..<end
                    day = String(eDate[range])
                    start = eDate.index(eDate.startIndex, offsetBy: 6)
                    end = eDate.index(eDate.startIndex, offsetBy: 10)
                    range = start..<end
                    year = String(eDate[range])
                }
                let dateStr = year+"-"+month+"-"+day
                let dateEvent = dateFormatter.date(from: dateStr)
                let lat = event.latitude
                let lng = event.longitude
                print("LATITUDE: \(lat) LONGITUDE: \(lng)")
                var currentLoc = self.getCurrentLocation()
                let dist = self.getDistanceBetweenLocations(lat1: lat, lng1: lng, lat2: currentLoc[0], lng2: currentLoc[1])
                print("DATE is later: \(currentDate.compare(dateEvent!) != ComparisonResult.orderedDescending)")
                print("DISTANCE: \(dist)")
                if !self.notInterestedEvents.contains(rest.key) && !self.interestedEvents.contains(rest.key)  &&
                    currentDate.compare(dateEvent!) != ComparisonResult.orderedDescending
                    && dist < 50 {
                        self.eventList.append(event)
                        self.eventKeys.append(rest.key)
                        self.exampleCardLabels.append(event.toString())
                }
                
            }
            
            print("COUNT: \(self.eventList.count)")
            for e in self.eventList {
                print("NAME: \(e.name)")
            }

            self.loadCards()
            
        })
        
    }
    
    func getCurrentLocation() -> Array<Double>{
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let location = self.locationManager.location
        
        let latitude: Double = location!.coordinate.latitude
        let longitude: Double = location!.coordinate.longitude
        
        return [latitude,longitude]
    }
    
    func getDistanceBetweenLocations(lat1:Double, lng1:Double, lat2:Double, lng2:Double) -> Double{
        let coordinate1 = CLLocation(latitude: lat1, longitude: lng1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lng2)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        return distanceInMeters*0.000621371
    }


    
    func loadCards() -> Void {
        print("IN LOAD CARDS")
        if exampleCardLabels.count > 0 {
            let numLoadedCardsCap = exampleCardLabels.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : exampleCardLabels.count
            for i in 0 ..< exampleCardLabels.count {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
            
        }
        
    }
    
    
    func cardSwipedLeft(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        eventList.remove(at: 0)
        let key = eventKeys.remove(at: 0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        self.ref.child("users").child(userId).child("not_interested_events").childByAutoId().setValue(key)
    }
    
    func cardSwipedRight(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        eventList.remove(at: 0)
        let key = eventKeys.remove(at: 0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        self.ref.child("users").child(userId).child("interested_events").childByAutoId().setValue(key)
    }
    
    @objc func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }
    
    @objc func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
}
