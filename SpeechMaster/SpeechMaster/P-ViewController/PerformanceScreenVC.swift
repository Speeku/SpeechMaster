import UIKit
import AVFoundation
import Speech

class PerformanceScreenVC: UIViewController {
    
    var script = "A string is a series of characters, such as that forms a collection. Strings in Swift are Unicode correct and locale insensitive, and are designed to be efficient. The String type bridges with the Objective-C class NSString and offers interoperability with C functions that works with strings."
    
    var scriptLine: [String] = []
    var currentLineIndex = 0
    var timer: Timer?

    var captureSession = AVCaptureSession()
    var videoOutput = AVCaptureMovieFileOutput()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCamera: AVCaptureDevice?
    var isRecording = false
    var videoURL: URL?
    
    var speechRecognizer: SFSpeechRecognizer?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine = AVAudioEngine()
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var startRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCaptureSession()
        setUpDevice()
        setUpInputOutput()
        setUpPreviewLayer()
        startRunningCaptureSession()
        
        // Prepare script for line-by-line comparison
        scriptLine = script.components(separatedBy: ". ").filter { !$0.isEmpty }
        textView.text = script // Initial text
        textView.isEditable = false
        textView.isScrollEnabled = true
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        if isRecording {
            // Stop recording
            videoOutput.stopRecording()
            isRecording = false
            sender.setTitle("Start Recording", for: .normal)
        } else {
            // Start recording
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoURL = outputFileURL // Save the output URL
            videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
            isRecording = true
            sender.setTitle("Stop Recording", for: .normal)
        }
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
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(videoOutput)
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
        captureSession.startRunning()
    }
  
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showReport", let previewVC = segue.destination as? reportScreenVC {
//            previewVC.videoURL = self.videoURL
//        }
//    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        // Save the video URL for passing to the next view controller
        self.videoURL = outputFileURL
        performSegue(withIdentifier: "showReport", sender: nil)
    }
}

