import Foundation
import Speech
import AVFoundation

class SpeechAnalyzer {
    //private let script: Script
    private let ds = HomeViewModel.shared
    private var audioEngine: AVAudioEngine
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer
    
    private var recordingURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var startTime: Date?
    
    private var transcribedText: String = ""
    private var detectedFillerWords: [(word: String, timestamp: TimeInterval)] = []
    private var wordTimestamps: [(word: String, timestamp: TimeInterval)] = []
    
    private let fillerWords = Set(["um", "uh", "like", "you know", "sort of", "kind of"])
    
    private var audioMeterTimer: Timer?
    private var currentVolume: Float = 0.0
    private var recentFillerWords: [(word: String, timestamp: TimeInterval)] = []
    private let recentFillerWordsTimeWindow: TimeInterval = 5.0 // Last 5 seconds
    
    init() {
        self.audioEngine = AVAudioEngine()
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    }
    
    func startRecording() async throws {
        // Request permission
        try await requestPermissions()
        
        // Setup audio session
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try AVAudioSession.sharedInstance().setActive(true)
        
        // Setup recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("speech_recording.m4a")
        
        // Configure audio recorder
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
        audioRecorder?.record()
        
        // Enable audio metering
        audioRecorder?.isMeteringEnabled = true
        
        // Start monitoring audio levels
        audioMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.audioRecorder?.updateMeters()
            self?.currentVolume = self?.getCurrentVolume() ?? 0.0
        }
        
        // Start speech recognition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.processRecognitionResult(result)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        startTime = Date()
    }
    
    func stopRecording() async throws -> SpeechAnalysisResult {
        audioMeterTimer?.invalidate()
        audioMeterTimer = nil
        recentFillerWords.removeAll()
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        audioRecorder?.stop()
        
        let duration = Date().timeIntervalSince(startTime ?? Date())
        
        // Analyze results
        return await analyzeRecording()
    }
    
    private func analyzeRecording() async -> SpeechAnalysisResult {
        // Calculate expected duration based on script length
        let wordCount = ds.getScriptText(for: ds.currentScriptID).split(separator: " ").count
        let expectedWordsPerMinute = 150.0 // Average speaking pace
        let expectedDuration = Double(wordCount ?? 0) / (expectedWordsPerMinute / 60)
        
        // Process filler words
        let fillerWordResults = processFillerWords()
        
        // Find missing words
        let missingWords = findMissingWords()
        
        // Analyze pronunciation (simplified version)
        let pronunciationErrors = findPronunciationErrors()
        
        // Calculate words per minute
        let spokenWordCount = transcribedText.split(separator: " ").count
        let duration = Date().timeIntervalSince(startTime ?? Date())
        let wordsPerMinute = Double(spokenWordCount) / (duration / 60)
        
        return SpeechAnalysisResult(
            totalDuration: duration,
            expectedDuration: expectedDuration,
            fillerWords: fillerWordResults,
            missingWords: missingWords,
            pronunciationErrors: pronunciationErrors,
            averageWordsPerMinute: wordsPerMinute,
            scriptWordCount: wordCount,
        spokenWordCount: spokenWordCount
        )
    }
    
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        transcribedText = result.bestTranscription.formattedString
        
        // Process timestamps
        for segment in result.bestTranscription.segments {
            let timestamp = segment.timestamp
            let word = segment.substring.lowercased()
            
            wordTimestamps.append((word, timestamp))
            
            if fillerWords.contains(word) {
                detectedFillerWords.append((word, timestamp))
                recentFillerWords.append((word, Date().timeIntervalSince1970))
            }
        }
    }
    
    // Helper methods for analysis
    private func processFillerWords() -> [SpeechAnalysisResult.FillerWord] {
        // Group filler words and their timestamps
        var fillerWordDict: [String: [TimeInterval]] = [:]
        
        for (word, timestamp) in detectedFillerWords {
            fillerWordDict[word, default: []].append(timestamp)
        }
        
        return fillerWordDict.map { word, timestamps in
            SpeechAnalysisResult.FillerWord(
                word: word,
                count: timestamps.count,
                timestamps: timestamps
            )
        }
    }
    
    private func findMissingWords() -> [SpeechAnalysisResult.MissingWord] {
        // Simple word matching (can be improved with more sophisticated algorithms)
        let scriptWords = ds.getScriptText(for: ds.currentScriptID).lowercased().split(separator: " ")
        let spokenWords = transcribedText.lowercased().split(separator: " ")
        
        var missingWords: [SpeechAnalysisResult.MissingWord] = []
        
        for (index, word) in scriptWords.enumerated() {
            if !spokenWords.contains(word) {
                let context = getContext(around: String(word), in: ds.getScriptText(for: ds.currentScriptID), index: index)
                missingWords.append(SpeechAnalysisResult.MissingWord(
                    word: String(word),
                    expectedIndex: index,
                    context: context
                ))
            }
        }
        
        return missingWords
    }
    
    private func findPronunciationErrors() -> [SpeechAnalysisResult.PronunciationError] {
        // This is a simplified version. In a real app, you'd want to use
        // a pronunciation dictionary or ML model for better accuracy
        var errors: [SpeechAnalysisResult.PronunciationError] = []
        
        // Example implementation (you'd want to enhance this)
        for (word, timestamp) in wordTimestamps {
            // Add your pronunciation checking logic here
            // This is just a placeholder
            if word.count > 3 && Bool.random() { // Simulate finding errors
                errors.append(SpeechAnalysisResult.PronunciationError(
                    word: word,
                    timestamp: timestamp,
                    actualPronunciation: word,
                    expectedPronunciation: word
                ))
            }
        }
        
        return errors
    }
    
    private func getContext(around word: String, in text: String, index: Int) -> String {
        let words = text.split(separator: " ")
        let start = max(0, index - 2)
        let end = min(words.count, index + 3)
        return words[start..<end].joined(separator: " ")
    }
    
    private func requestPermissions() async throws {
        // Request speech recognition authorization
        var authStatus = SFSpeechRecognizer.authorizationStatus()
        if authStatus == .notDetermined {
            authStatus = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
        }
        
        guard authStatus == .authorized else {
            throw NSError(domain: "SpeechRecognition", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"])
        }
        
        // Request microphone authorization
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if audioStatus == .notDetermined {
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }
            guard granted else {
                throw NSError(domain: "Microphone", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Microphone access not granted"])
            }
        }
    }
    
    func getCurrentVolume() -> Float {
        audioRecorder?.updateMeters()
        let normalizedValue = (audioRecorder?.averagePower(forChannel: 0) ?? -160.0) + 160.0
        // Convert to 0-1 range
        return max(0.0, min(1.0, normalizedValue / 160.0))
    }
    
    func getRecentFillerWords() -> [String] {
        let currentTime = Date().timeIntervalSince1970
        // Filter filler words from last 5 seconds
        recentFillerWords = recentFillerWords.filter { 
            currentTime - $0.timestamp < recentFillerWordsTimeWindow 
        }
        return recentFillerWords.map { $0.word }
    }
    
    func getCurrentWordCount() -> Int {
        // Return the current word count from the latest transcription
        return transcribedText.split(separator: " ").count
    }
} 
