import SwiftUI
import UIKit

struct ShareUtility {
    
    /// Presents a share sheet to share the provided items
    /// - Parameters:
    ///   - items: The items to share (URLs, strings, images, etc.)
    ///   - completion: Optional completion handler called when sharing is complete
    static func share(items: [Any], completion: (() -> Void)? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // For iPad, we need to set the sourceView and sourceRect to avoid crash
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = rootViewController.view
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, 
                                                y: UIScreen.main.bounds.height / 2, 
                                                width: 0, 
                                                height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootViewController.present(activityViewController, animated: true, completion: completion)
    }
    
    /// Shares a script as a PDF file
    /// - Parameter script: The script to share
    static func shareScriptAsPDF(_ script: Script) {
        guard let pdfURL = PDFGenerator.generatePDF(from: script) else {
            print("Failed to generate PDF")
            return
        }
        
        share(items: [pdfURL])
    }
} 