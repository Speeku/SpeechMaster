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
    private var currentDocument: URL?
    private let keynoteManager = KeynoteManager.shared
    private let ds = HomeViewModel.shared
//    var texty: String = ""
//    var scriptId: UUID = UUID()
    
    @IBOutlet var uploadKeynote: UIButton!
    @IBOutlet var withoutKeynote: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
        uploadKeynote.layer.cornerRadius = 20
        withoutKeynote.layer.cornerRadius = 20
        }
        
        @IBAction func selectKeynote(_ sender: Any) {
            let keynoteUTType = UTType(filenameExtension: "key") ?? UTType(filenameExtension: "keynote") ?? UTType.data
            
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [keynoteUTType,.pdf, .presentation])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            
            present(documentPicker, animated: true)
        }
        
        @IBAction func withoutKeynoteTapped(_ sender: Any) {
            // Navigate to PerformanceViewController without keynote
            navigateToPerformance(withKeynote: false)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else { return }
            
            // Create bookmark data for the selected keynote
            do {
                let bookmarkData = try selectedFileURL.bookmarkData(
                    options: .minimalBookmark,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                // Save the keynote URL to KeynoteManager
                keynoteManager.saveKeynoteURL(selectedFileURL, bookmarkData: bookmarkData) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            // Navigate to PerformanceViewController with keynote
                            self?.navigateToPerformance(withKeynote: true)
                        case .failure(let error):
                            self?.showError(error)
                        }
                    }
                }
            } catch {
                showError(error)
            }
        }
        
        private func navigateToPerformance(withKeynote: Bool) {
            let performanceVC = PerformanceViewController()
            if withKeynote, let currentDocument = currentDocument {
                do {
                    // Create bookmark data for persistent access
                    let bookmarkData = try currentDocument.bookmarkData(
                        options: .minimalBookmark,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
     
                    // Save the keynote URL and bookmark data
                    keynoteManager.saveKeynoteURL(currentDocument, bookmarkData: bookmarkData) { [weak self] result in
                        switch result {
                        case .success:
                            performanceVC.currentKeynoteURL = currentDocument
                        case .failure(let error):
                            self?.showError(error)
                        }
                    }
                } catch {
                    showError(error)
                }
            }
            
            // Push the performance view controller using the existing navigation controller
            self.navigationController?.pushViewController(performanceVC, animated: true)
        }
        
        private func showError(_ error: Error) {
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}

