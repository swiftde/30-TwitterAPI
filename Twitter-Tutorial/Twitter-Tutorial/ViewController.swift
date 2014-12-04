//
//  ViewController.swift
//  Twitter-Tutorial
//
//  Created by Benjamin Herzog on 03.12.14.
//  Copyright (c) 2014 Benjamin Herzog. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    let accountStore = ACAccountStore()
    let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    var twitterAccount: ACAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = "Das ist ein Test-Tweet aus meinem neuesten Video! #Swift"
        textField.becomeFirstResponder()
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { success, error in
            if !success {
                println("Keine Berechtigung erhalten... -.-")
            }
            else {
                let alleAccounts = self.accountStore.accountsWithAccountType(self.accountType)
                if alleAccounts.count > 0 {
                    self.twitterAccount = alleAccounts.last as? ACAccount
                }
            }
            NSUserDefaults.standardUserDefaults().setBool(success, forKey: "TwitterAuth")
        }
    }

    @IBAction func bildLadenButtonPressed(sender: AnyObject) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("TwitterAuth") {
            return
        }
        
        let url = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: nil)
        request.account = twitterAccount
        
        request.performRequestWithHandler { data, response, error in
            
            if response.statusCode == 200 {
                // hat geklappt
                println("Authentifizierung hat geklappt... :)")
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as [String: AnyObject]
                let bildURL = json["profile_image_url_https"] as String
                let bildData = NSData(contentsOfURL: NSURL(string: bildURL)!)!
                let bild = UIImage(data: bildData)
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageView.image = bild
                }
            }
            else if response.statusCode == 401 {
                println("Authentifizierung hat nicht geklappt... :(")
            }
            else {
                println("Ein ganz komischer Status Code kam zurück... :O")
            }
            
        }
        
    }

    @IBAction func tweetSendenButtonPressed(sender: AnyObject) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("TwitterAuth") {
            return
        }
        
        let anzahlBuchstaben = countElements(textField.text)
        
        if anzahlBuchstaben == 0 {
            return
        }
        
        let smallerNumber = anzahlBuchstaben < 140 ? anzahlBuchstaben : 140
        let textToTweet = textField.text[0..<smallerNumber]
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: ["status": textToTweet])
        request.account = twitterAccount
        
        request.performRequestWithHandler { data, response, error in
            
            if response.statusCode == 200 {
                println("hat geklappt")
            }
            
        }
        
    }
}


extension String
{
    subscript(i: Int) -> Character {
        return self[advance(startIndex, i)]
    }
    
    subscript(range: Range<Int>) -> String {
        return self[advance(startIndex, range.startIndex)..<advance(startIndex, range.endIndex)]
    }
}














