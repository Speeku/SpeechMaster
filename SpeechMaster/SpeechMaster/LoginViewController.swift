//
//  LoginViewController.swift
//  SpeechMaster
//
//  Created by Abuzar on 18/02/25.
//

import UIKit
import GoogleSignIn
class LoginViewController: UIViewController {
    @IBOutlet weak var rememberMeCheckbox: UIButton!
    @IBOutlet weak var rememberMeLabelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateCheckboxState()
        // Do any additional setup after loading the view.
    }
    @IBAction func rememberMeCheckboxTapped(_ sender: UIButton) {
        rememberMeCheckbox.isSelected.toggle()
        updateCheckboxState()
        
    }
    func updateCheckboxState() {
        let imageName = rememberMeCheckbox.isSelected ? "checkmark.square.fill" : "square"
        rememberMeCheckbox.setImage(UIImage(systemName: imageName), for: .normal)
        
    }
    
    func handleGoogleSignIn() {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else { return }
        
        let homeVC = UIStoryboard(name: "FakeLandingViewController", bundle: nil).instantiateViewController(withIdentifier: "FakeLandingViewController") as! FakeLandingViewController
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }
    
    @IBAction func signIn(sender: Any) {
      GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
        guard error == nil else { return }

        // If sign in succeeded, display the app's main content View.
      }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
