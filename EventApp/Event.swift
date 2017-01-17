//
//  Event.swift
//  EventApp
//
//  Created by Naveen Raj on 12/26/16.
//  Copyright © 2016 Naveen Raj. All rights reserved.
//

import Foundation
import Firebase

class Event{
    
    var date:String
    var description:String
    var location:String
    var latitude:Double
    var longitude:Double
    var name:String
    var startTime:String
    var endTime:String
    var entryFee:String
    var createdBy:String
    var imageUrl: String
    let ref: FIRDatabaseReference?
    
    init(date:String, description:String, location:String, latitude:Double, longitude:Double, name:String, startTime:String, endTime:String, entryFee:String, createdBy:String, imageUrl:String) {
        self.date = date
        self.description = description
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.entryFee = entryFee
        self.createdBy = createdBy
        self.imageUrl = imageUrl
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        date = snapshotValue["date"] as! String
        description = snapshotValue["description"] as! String
        location = snapshotValue["location"] as! String
        latitude = snapshotValue["latitude"] as! Double
        longitude = snapshotValue["longitude"] as! Double
        name = snapshotValue["name"] as! String
        startTime = snapshotValue["startTime"] as! String
        endTime = snapshotValue["endTime"] as! String
        entryFee = snapshotValue["entryFee"] as! String
        createdBy = snapshotValue["createdBy"] as! String
        imageUrl = snapshotValue["imageUrl"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "date": self.date,
            "description": self.description,
            "location": self.location,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "name": self.name,
            "startTime": self.startTime,
            "endTime": self.endTime,
            "entryFee": self.entryFee,
            "createdBy": self.createdBy,
            "imageUrl": self.imageUrl
            ] as NSDictionary
    }
    
    func toString() -> String {
        return "\(name)\n\(date)"
    }
}
