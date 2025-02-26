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


}
