import UIKit
import PDFKit

class PDFGenerator {
    
    /// Generates a PDF from a script and returns the URL to the generated file
    /// - Parameter script: The script to convert to PDF
    /// - Returns: URL to the generated PDF file
    static func generatePDF(from script: Script) -> URL? {
        // Create a PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "SpeechMaster",
            kCGPDFContextAuthor: "SpeechMaster User",
            kCGPDFContextTitle: script.title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Set up the PDF page size (using A4 size)
        let pageWidth = 8.27 * 72.0
        let pageHeight = 11.69 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // Create a temporary file URL for the PDF
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(script.title.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: fileURL) { context in
                // First page
                context.beginPage()
                
                // Draw the title
                let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.black
                ]
                
                let titleString = NSAttributedString(string: script.title, attributes: titleAttributes)
                let titleStringSize = titleString.size()
                let titleRect = CGRect(x: (pageWidth - titleStringSize.width) / 2.0,
                                      y: 50,
                                      width: titleStringSize.width,
                                      height: titleStringSize.height)
                titleString.draw(in: titleRect)
                
                // Draw a line under the title
                let lineY = titleRect.maxY + 10
                context.cgContext.setStrokeColor(UIColor.gray.cgColor)
                context.cgContext.setLineWidth(1.0)
                context.cgContext.move(to: CGPoint(x: 50, y: lineY))
                context.cgContext.addLine(to: CGPoint(x: pageWidth - 50, y: lineY))
                context.cgContext.strokePath()
                
                // Draw the date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateString = "Created on: \(dateFormatter.string(from: script.createdAt))"
                let dateFont = UIFont.systemFont(ofSize: 12.0)
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: dateFont,
                    .foregroundColor: UIColor.darkGray
                ]
                
                let dateAttributedString = NSAttributedString(string: dateString, attributes: dateAttributes)
                let dateRect = CGRect(x: 50, y: lineY + 20, width: pageWidth - 100, height: 20)
                dateAttributedString.draw(in: dateRect)
                
                // Draw the script text
                let textFont = UIFont.systemFont(ofSize: 14.0)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .natural
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.lineSpacing = 6
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: textFont,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ]
                
                let attributedText = NSAttributedString(string: script.scriptText, attributes: textAttributes)
                
                // Calculate text drawing rect
                let textRect = CGRect(x: 50, y: dateRect.maxY + 30, width: pageWidth - 100, height: pageHeight - dateRect.maxY - 80)
                
                // Draw the text
                attributedText.draw(in: textRect)
            }
            
            return fileURL
        } catch {
            print("Error generating PDF: \(error)")
            return nil
        }
    }
} 