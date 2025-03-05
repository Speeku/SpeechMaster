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
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create configuration for the button
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8  // Space between image and title
        config.image = UIImage(systemName: "chevron.left")
        config.title = "Home"
        config.baseForegroundColor = .systemBlue
        
        button.configuration = config
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadKeynote.layer.cornerRadius = 20
        withoutKeynote.layer.cornerRadius = 20
        setupBackButton()
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func backButtonTapped() {
        // Dismiss directly to root view controller
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar again when leaving this view
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func navigateToPerformance(withKeynote: Bool) {
        let performanceVC = PerformanceViewController(withKeynote: withKeynote)
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
                        DispatchQueue.main.async {
                            self?.navigationController?.pushViewController(performanceVC, animated: true)
                        }
                    case .failure(let error):
                        self?.showError(error)
                    }
                }
            } catch {
                showError(error)
            }
        } else {
            navigationController?.pushViewController(performanceVC, animated: true)
        }
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

