//
//  ScriptEditViewController.swift
//  SpeechMaster
//
//  Created by Kushagra Kulshrestha on 13/02/25.
//

import UIKit

class ScriptEditViewController: UIViewController {

    @IBOutlet weak var ScriptTextView: UITextView!
    var editScriptText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ScriptTextView.text = editScriptText
        //HomeViewModel.shared.
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
