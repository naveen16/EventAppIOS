//
//  AccountViewController.swift
//  EventApp
//
//  Created by Naveen Raj on 1/12/17.
//  Copyright © 2017 Naveen Raj. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    var ref: DatabaseReference!
    var userId: String!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let logoutSegue = "logoutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        userId = user?.uid
        self.ref.child("users").child(userId).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            self.nameLabel.text = snapshot.value as? String
        })
        self.emailLabel.text = user?.email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutPress(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.performSegue(withIdentifier: self.logoutSegue, sender: nil)
    }
    
}


