import UIKit
import QuickLook
import AVFoundation
import Speech

class PerformanceScreenVC: UIViewController {
    
    var script = "A string is a series of characters, such as that forms a collection. Strings in Swift are Unicode correct and locale insensitive, and are designed to be efficient. The String type bridges with the Objective-C class NSString and offers interoperability with C functions that works with strings."
    
    @IBOutlet var videoTimer :         UILabel!
    @IBOutlet var coachLabel :         UILabel!
    @IBOutlet var coachButton :        UIButton!
    @IBOutlet var scriptButton :       UIButton!
    @IBOutlet var settingPerformance : UIButton!

    // Varables for enabling camera and capturing video
    var captureSession =       AVCaptureSession()
    var videoOutput =          AVCaptureMovieFileOutput()
    var cameraPreviewLayer :   AVCaptureVideoPreviewLayer?
    var currentCamera:         AVCaptureDevice?
    var isRecording = false
    var videoURL: URL?
    
    @IBOutlet var showingKeynote: UIView!
    private var previewController: QLPreviewController?
    var selectedKeynoteURL: URL? {
           didSet {
               // Display keynote when URL is set
               if isViewLoaded {
                   displayKeynote()
               }
           }
       }
    
    
    
    
    // variables for scrolling the content of textView
    private var scrollTimer :     Timer?
    private let scrollSpeed :     TimeInterval = 0.1  // Adjust speed as needed
    private let pixelsPerScroll : CGFloat = 1     // Adjust scroll amount as needed

    
    //variable for timer of video
    private var recordingTimer : Timer?
    private var elapsedSeconds : Int = 0


    @IBOutlet var cameraView :           UIView!
    @IBOutlet var textView :             UITextView!
    @IBOutlet var startRecordingButton : UIButton!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        // calling camera and capture video session functions
        checkPermissions()
        setUpCaptureSession()
        setUpDevice()
        setUpInputOutput()
        setUpPreviewLayer()
        startRunningCaptureSession()
        
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true  // Set to false if you don't want user scrolling
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.text = script
        
        videoTimer.text = "00:00"
        
        if selectedKeynoteURL != nil {
                   displayKeynote()
               }
   
    }
    
    func checkPermissions() {
        // Check camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                print("Camera permission is required")
            }
        }
        
        // Check microphone permission
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                print("Microphone permission is required")
            }
        }
    }
    
    
    
    // Record Session Button
    @IBAction func startRecording(_ sender: UIButton) {
        if isRecording {
            // Stop recording
            videoOutput.stopRecording()
            isRecording = false
            stopAutoScroll()                 // for auto scrolling off of the textView
            stopRecordingTimer()             // for stoping the timer as soon as video is ended
            sender.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)  // changing the button image
            print("Recording stopped")    // for console awareness
        } else {
            // Create unique file path in Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "recording_\(Date().timeIntervalSince1970).mov"
            let outputFileURL = documentsPath.appendingPathComponent(fileName)
            
            // Remove existing file if any
            try? FileManager.default.removeItem(at: outputFileURL)
            
            // Start recording
            videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
            videoURL = outputFileURL
            isRecording = true
            startAutoScroll()
            startRecordingTimer()
            sender.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            print("Recording started")
        }
    }
    
    
    @IBAction func coachButton(_ sender: Any) {
        coachLabel.isHidden = !coachLabel.isHidden
        if coachLabel.isHidden {
                // Label is hidden - use unfilled person symbol
                coachButton.setImage(UIImage(systemName: "person"), for: .normal)
            } else {
                // Label is visible - use filled person symbol
                coachButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
            }
    }
    
    @IBAction func scriptButton(_ sender: Any) {
        textView.isHidden = !textView.isHidden
        if textView.isHidden {
            //textView is hidden - use unfilled document Button
            scriptButton.setImage(UIImage(systemName: "document"), for: .normal)
        }
            else{
                
                scriptButton.setImage(UIImage(systemName: "document.fill"), for: .normal)
            }
        }
    
    private func startAutoScroll() {
        // Stop any existing timer
        scrollTimer?.invalidate()
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: scrollSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentOffset = self.textView.contentOffset.y
            let maxOffset = self.textView.contentSize.height - self.textView.bounds.height
            
            // Check if we haven't reached the bottom
            if currentOffset < maxOffset {
                // Increment the scroll position
                let newOffset = CGPoint(x: 0, y: currentOffset + self.pixelsPerScroll)
                self.textView.setContentOffset(newOffset, animated: false)
            } else {
                // Optional: stop the timer when reaching the bottom
                self.scrollTimer?.invalidate()
            }
        }
    }

    
    private func stopAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func startRecordingTimer() {
        elapsedSeconds = 0
        videoTimer.text = "00:00"
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.videoTimer.text = self.formatTime(self.elapsedSeconds)
        }
    }

    // Add this function to stop the timer
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        elapsedSeconds = 0
        videoTimer.text = "00:00"
    }
    
    private func displayKeynote() {
         // Remove existing preview controller if any
         previewController?.willMove(toParent: nil)
         previewController?.view.removeFromSuperview()
         previewController?.removeFromParent()
         
         guard let keynoteURL = selectedKeynoteURL else { return }
         
         // Create new preview controller
         let previewVC = QLPreviewController()
         previewVC.dataSource = self
         previewVC.view.frame = showingKeynote.bounds
         addChild(previewVC)
         showingKeynote.addSubview(previewVC.view)
         previewVC.didMove(toParent: self)
         
         previewController = previewVC
     }
    
    }

    
       


extension PerformanceScreenVC: AVCaptureFileOutputRecordingDelegate {
    func setUpCaptureSession() {
        captureSession.sessionPreset = .high
    }
    
    func setUpDevice() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Error: Unable to find front camera.")
            return
        }
        currentCamera = device
    }
    
    func setUpInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            
            // Add audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                captureSession.addInput(audioInput)
            }
            
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
        } catch {
            print("Error setting up input and output: \(error.localizedDescription)")
        }
    }
    
    func setUpPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        
        if let previewLayer = cameraPreviewLayer {
            previewLayer.frame = cameraView.bounds
            cameraView.layer.addSublayer(previewLayer)
        }
    }
    
    func startRunningCaptureSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to: \(fileURL)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        print("Successfully saved video to: \(outputFileURL)")
        
        // Create thumbnail from video
        let asset = AVAsset(url: outputFileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            // Add new video to array
            video.append(Video(showImage: thumbnailImage, videoURL: outputFileURL))
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showVideo", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo",
           let showVideoVC = segue.destination as? VideoCVCell {
            showVideoVC.videoURL = self.videoURL
        }
    }
}


extension PerformanceScreenVC : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1 // Since you're showing one Keynote file
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedKeynoteURL! as NSURL // Your keynoteURL needs to be converted to NSURL
    }
}
