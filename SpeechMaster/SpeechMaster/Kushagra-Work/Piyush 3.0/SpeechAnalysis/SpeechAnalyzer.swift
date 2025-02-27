import Foundation
import Speech
import AVFoundation

class SpeechAnalyzer {
    private let script = HomeViewModel.shared.uploadedScriptText
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
    
    private var detectionCount = 0
    private var detectionTexts: [String] = []
    private var detectionStartTime: Date?
    private var isCurrentlyDetecting = false
    private var nonRemovableDetections: [(word: String, timestamp: TimeInterval)] = []
    
    init() {
        self.audioEngine = AVAudioEngine()
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    }
    
    func startRecording() async throws {
        try await requestPermissions()
        
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.mixWithOthers, .allowBluetooth])
        try session.setPreferredIOBufferDuration(0.005)
        try session.setPreferredSampleRate(44100)
        try session.setActive(true)
        
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
        
        // Initialize recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Setup recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                
                // If there's transcription, remove current detections
                if !transcribedText.isEmpty {
                    self.detectionTexts.removeAll()
                }
                
                self.processRecognitionResult(result)
            }
        }
        
        // Setup audio engine and tap
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            
            // Feed buffer to speech recognizer
            self.recognitionRequest?.append(buffer)
            
            // Process audio levels for filler word detection
            let channelData = buffer.floatChannelData?.pointee
            let frameLength = Int(buffer.frameLength)
            
            var sumOfSquares: Float = 0.0
            let sampleStride = 16
            
            for i in stride(from: 0, to: frameLength, by: sampleStride) {
                let sample = channelData?[i] ?? 0
                sumOfSquares += sample * sample
            }
            
            let rms = sqrt(sumOfSquares / Float(frameLength/sampleStride))
            self.currentVolume = rms
            
            // Process audio level for filler word detection
            self.processAudioLevel(rms)
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
        
        // Reset detection state
        isCurrentlyDetecting = false
        detectionStartTime = nil
        
        let duration = Date().timeIntervalSince(startTime ?? Date())
        
        // Process final results
        let fillerWords = processFillerWords()
        let missingWords = findMissingWords()
        let pronunciationErrors = findPronunciationErrors()
        
        return SpeechAnalysisResult(
            totalDuration: duration,
            expectedDuration: calculateExpectedDuration(),
            fillerWords: fillerWords,
            missingWords: missingWords,
            pronunciationErrors: pronunciationErrors,
            averageWordsPerMinute: calculateWordsPerMinute(),
            scriptWordCount: calculateScriptWordCount(),
            spokenWordCount: calculateSpokenWordCount()
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
    
    private func processAudioLevel(_ rms: Float) {
        if rms > 0.009 {
            if !isCurrentlyDetecting {
                detectionStartTime = Date()
                isCurrentlyDetecting = true
                detectionCount += 1
            }
        } else {
            if isCurrentlyDetecting {
                if let startTime = detectionStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    let timestamp = startTime.timeIntervalSince1970
                    
                    // Add to nonRemovableDetections if no transcription
                    nonRemovableDetections.append((word: "um", timestamp: timestamp))
                }
                isCurrentlyDetecting = false
                detectionStartTime = nil
            }
        }
    }
    
    // Helper methods for analysis
    private func processFillerWords() -> [SpeechAnalysisResult.FillerWord] {
        // Group filler words by type and count occurrences
        var fillerWordDict: [String: [TimeInterval]] = [:]
        
        for (word, timestamp) in nonRemovableDetections {
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
        let scriptWords = script.lowercased().split(separator: " ")
        let spokenWords = transcribedText.lowercased().split(separator: " ")
        
        var missingWords: [SpeechAnalysisResult.MissingWord] = []
        
        for (index, word) in scriptWords.enumerated() {
            if !spokenWords.contains(word) {
                let context = getContext(around: String(word), in: script, index: index)
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
        var pronunciationErrors: [SpeechAnalysisResult.PronunciationError] = []
        let missingWords = findMissingWords()
        
        // Get all words from transcription for comparison
        let transcribedWords = transcribedText.lowercased().split(separator: " ").map(String.init)
        let scriptWords = script.lowercased().split(separator: " ").map(String.init)
        
        for (word, timestamp) in wordTimestamps {
            // Skip if the word is in missing words list
            if missingWords.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                continue
            }
            
            // Find the best match in script words
            if let expectedWord = findBestMatch(for: word, in: scriptWords) {
                let similarity = calculateSimilarity(between: word, and: expectedWord)
                
                // Only add to pronunciation errors if similarity is 40% or less
                if similarity <= 0.4 {
                    pronunciationErrors.append(
                        SpeechAnalysisResult.PronunciationError(
                            word: expectedWord,
                            timestamp: timestamp,
                            actualPronunciation: word,
                            expectedPronunciation: expectedWord
                        )
                    )
                }
            }
        }
        
        return pronunciationErrors
    }
    
    // Helper function to find best matching word
    private func findBestMatch(for word: String, in wordList: [String]) -> String? {
        var bestMatch: String?
        var highestSimilarity: Double = 0
        
        for scriptWord in wordList {
            let similarity = calculateSimilarity(between: word, and: scriptWord)
            if similarity > highestSimilarity {
                highestSimilarity = similarity
                bestMatch = scriptWord
            }
        }
        
        return bestMatch
    }
    
    // Calculate similarity between two words using Levenshtein distance
    private func calculateSimilarity(between str1: String, and str2: String) -> Double {
        let distance = levenshteinDistance(between: str1, and: str2)
        let maxLength = Double(max(str1.count, str2.count))
        return 1.0 - (Double(distance) / maxLength)
    }
    
    // Levenshtein distance calculation
    private func levenshteinDistance(between str1: String, and str2: String) -> Int {
        let str1Array = Array(str1.lowercased())
        let str2Array = Array(str2.lowercased())
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Array.count + 1),
                          count: str1Array.count + 1)
        
        for i in 0...str1Array.count {
            matrix[i][0] = i
        }
        
        for j in 0...str2Array.count {
            matrix[0][j] = j
        }
        
        for i in 1...str1Array.count {
            for j in 1...str2Array.count {
                if str1Array[i-1] == str2Array[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(
                        matrix[i-1][j] + 1,    // deletion
                        matrix[i][j-1] + 1,    // insertion
                        matrix[i-1][j-1] + 1   // substitution
                    )
                }
            }
        }
        
        return matrix[str1Array.count][str2Array.count]
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
    
    private func calculateExpectedDuration() -> Double {
        // Calculate expected duration based on script length
        let wordCount = script.split(separator: " ").count
        let expectedWordsPerMinute = 150.0 // Average speaking pace
        return Double(wordCount) / (expectedWordsPerMinute / 60)
    }
    
    private func calculateWordsPerMinute() -> Double {
        let spokenWordCount = transcribedText.split(separator: " ").count
        let duration = Date().timeIntervalSince(startTime ?? Date())
        return Double(spokenWordCount) / (duration / 60)
    }
    
    private func calculateScriptWordCount() -> Int {
        return script.split(separator: " ").count
    }
    
    private func calculateSpokenWordCount() -> Int {
        return transcribedText.split(separator: " ").count
    }
}
