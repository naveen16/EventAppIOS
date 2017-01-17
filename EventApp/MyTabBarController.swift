//
//  MyTabBarController.swift
//  EventApp
//
//  Created by Naveen Raj on 1/5/17.
//  Copyright © 2017 Naveen Raj. All rights reserved.
//

import Foundation
import UIKit

// This class holds the data for my model.
class EventData {
    var name: String!
    var date: String!
    var startTime: String!
    var endTime: String!
    var address: String!
    var price: String!
    var eDescription: String!
}

class MyTabBarController: UITabBarController {
    
    // Instantiate the one copy of the model data that will be accessed
    // by all of the tabs.
    var model = EventData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
