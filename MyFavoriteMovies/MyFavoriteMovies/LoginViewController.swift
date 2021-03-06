//
//  LoginViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    var authStep = "Request Token"
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate                        
        
        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            /*
                Steps for Authentication...
                https://www.themoviedb.org/documentation/api/sessions
                
                Step 1: Create a request token
                Step 2: Ask the user for permission via the API ("login")
                Step 3: Create a session ID
                
                Extra Steps...
                Step 4: Get the user id ;)
                Step 5: Go to the next view!            
            */
            getRequestToken()
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MoviesTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: TheMovieDB
    
    private func getRequestToken() {
        
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        
        authStep = "Request Token"
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/new"))
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print("Login failed: (\(self.authStep))")
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login failed: (\(self.authStep))"
                }
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                displayError("Your request returned something other than 2XX")
                return
            }
            
            guard let data = data else {
                displayError("No data was return from your request.")
                return
            }
            
            let parsedJSON: AnyObject!
            do {
                parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse Data: \(data)")
                return
            }
            
            guard   let body = parsedJSON as? [String: AnyObject],
                    let success = body[Constants.TMDBResponseKeys.Success] as? Bool where success else {
                displayError("(Your request was no successful but returned: \(parsedJSON)")
                return
            }
            
            guard let requestToken = body[Constants.TMDBResponseKeys.RequestToken] as? String else {
                displayError("No request token was returned from your request. Returned Data: \(body)")
                return
            }
            print(requestToken)
            
            self.appDelegate.requestToken = requestToken
            self.loginWithToken(requestToken)
            
            /* 5. Parse the data */
            /* 6. Use the data! */
        }

        /* 7. Start the request */
        task.resume()
    }
    
    private func loginWithToken(requestToken: String) {
        
        authStep = "Login With Token"
        
        func displayError(error: String) {
            print("Login failed: (\(self.authStep))")
            print(error)
            performUIUpdatesOnMain {
                self.setUIEnabled(true)
                self.debugTextLabel.text = "Login failed: (\(self.authStep))"
            }
        }

        guard   let _usrname = usernameTextField.text,
                let _pswd = passwordTextField.text else {
                displayError("The Username or Password fields are empty")
                return
        }
        
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey : Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken : requestToken,
            Constants.TMDBParameterKeys.Password : _pswd,
            Constants.TMDBParameterKeys.Username : _usrname
        ]
        
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/validate_with_login"))
        
        _ = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                displayError("Your request returned something other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No Data was returned from your request!")
                return
            }
            
            let parsedJSON: AnyObject!
            do {
                parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse returned data to JSON: \(data)")
                return
            }
            
            guard   let body = parsedJSON as? [String : AnyObject],
                    let success = body[Constants.TMDBResponseKeys.Success] as? Bool where success else {
                displayError("Your request was not successful!")
                return
            }
            
            guard let returnedRequestToken = body[Constants.TMDBResponseKeys.RequestToken] as? String else {
                displayError("Could not find request token in returned data: \(body)")
                return
            }
            print("Login Completed: \(returnedRequestToken)")
            self.getSessionID(requestToken)
            
        }.resume()
        
        /* TASK: Login, then get a session id */
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
    }
    
    private func getSessionID(requestToken: String) {
        
        authStep = "Get Session ID"
        
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey : Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken : requestToken
        ]
        
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/session/new"))
        
        _ = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            func displayError(error: String) {
                print("Login Failed - (\(self.authStep))")
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed - (\(self.authStep))"
                }
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                displayError("Your request returned something other than a 2XX response!")
                return
            }
            
            guard let data = data else {
                displayError("No Data was returned with your request.")
                return
            }
            
            var parsedJSON: AnyObject!
            do {
                parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: \(data)")
                return
            }
            
            guard   let body = parsedJSON as? [String : AnyObject],
                    let success = body[Constants.TMDBResponseKeys.Success] as? Bool where success else {
                displayError("Your request for a session id was unsuccessful.")
                return
            }
            
            guard let sessionID = body[Constants.TMDBResponseKeys.SessionID] as? String else {
                displayError("Could not find parameter \(Constants.TMDBResponseKeys.SessionID) in returned body: \(body)")
                return
            }
            self.appDelegate.sessionID = sessionID
            self.getUserID(sessionID)
        
            
        }.resume()
        /* TASK: Get a session ID, then store it (appDelegate.sessionID) and get the user's id */
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
    }
    
    private func getUserID(sessionID: String) {
        
        authStep = "Get User ID"
        
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey      :   Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.SessionID   :   sessionID
        ]
        
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/account"))
        
        _ = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print("Login Failed: \(self.authStep)")
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed: \(self.authStep)"
                }
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                displayError("Your request returned something other than a 2xx statusCode!")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned from your request!")
                return
            }
            
            var parsedJSON: AnyObject!
            do {
                parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Unable to parse returned data into JSON: \(data)")
                return
            }
            
            guard   let body = parsedJSON as? [String: AnyObject],
                    let id = body[Constants.TMDBResponseKeys.ID] as? Int else {
                    displayError("Could not parse id from returned JSON: \(parsedJSON)")
                    return
            }
            print(body)
            self.appDelegate.userID = id
            print(id)
            self.completeLogin()
            
        }.resume()
            
        
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
