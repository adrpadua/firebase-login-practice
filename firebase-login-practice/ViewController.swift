//
//  ViewController.swift
//  firebase-login-practice
//
//  Created by Adrian Padua on 7/10/16.
//  Copyright © 2016 Adrian Padua. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    @IBAction func fbBtnPressed(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookLogin)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                //DataService.ds.REF_BASE.authWithOAuthProvider(")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in. \(user)")
                        
                        let userData = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser((user?.uid)!, user: userData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                    
                })
                
            }
        })
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                    print(error!)
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                
                                let userData = ["provider" : "email"]
                                DataService.ds.createFirebaseUser((user?.uid)!, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        
                        })
                    } else {
                        self.showErrorAlert("Could Not Log In", msg: "Please check your username and password.")
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}



