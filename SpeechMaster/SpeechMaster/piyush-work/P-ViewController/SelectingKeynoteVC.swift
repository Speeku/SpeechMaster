//
//  SelectingKeynoteVC.swift
//  SpeechMaster
//
//  Created by Piyush on 20/01/25.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook
import ObjectiveC


class SelectingKeynoteVC: UIViewController,UIDocumentPickerDelegate {
    var currentDocument: URL?
    var texty: String = ""
    var scriptId: UUID?
    
    @IBOutlet var uploadKeynote: UIButton!
    @IBOutlet var withoutKeynote: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
        uploadKeynote.layer.cornerRadius = 20
        withoutKeynote.layer.cornerRadius = 20
        }
        
        @IBAction func selectKeynote(_ sender: Any) {
            let keynoteUTType = UTType(filenameExtension: "key") ?? UTType(filenameExtension: "keynote") ?? UTType.data
            
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [keynoteUTType])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            
            present(documentPicker, animated: true)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else { return }
            currentDocument = selectedFileURL
            
            // Perform segue to PerformanceScreenVC
            performSegue(withIdentifier: "showPerformance", sender: self)
        }
        
        // Prepare for segue
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showPerformance",
               let destinationVC = segue.destination as? PerformanceScreenVC {
                destinationVC.selectedKeynoteURL = currentDocument
                destinationVC.scriptText = texty
                destinationVC.scriptId = scriptId
            }
        }

}

