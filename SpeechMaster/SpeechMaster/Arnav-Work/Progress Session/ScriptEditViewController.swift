//
//  ScriptEditViewController.swift
//  SpeechMaster
//
//  Created by Kushagra Kulshrestha on 13/02/25.
//

import UIKit

protocol ScriptEditDelegate: AnyObject {
    func scriptDidUpdate(newText: String)
}

class ScriptEditViewController: UIViewController {
    
    @IBOutlet weak var ScriptTextView: UITextView!
    var editScriptText = ""
    weak var delegate: ScriptEditDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ScriptTextView.text = editScriptText
        //HomeViewModel.shared.
    }
    
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        let updatedText = ScriptTextView.text ?? ""
        let scriptId = HomeViewModel.shared.currentScriptID
        
        if let index = HomeViewModel.shared.scripts.firstIndex(where: { $0.id == scriptId }) {
            HomeViewModel.shared.setScriptText(for: scriptId, text: updatedText)
            
            // Notify delegate about the update
            delegate?.scriptDidUpdate(newText: updatedText)
            
            let alert = UIAlertController(
                title: "Success",
                message: "Script updated successfully!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        }
    }
    
}

