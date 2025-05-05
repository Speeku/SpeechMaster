//
//  CompareCollectionViewCell.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit
class CompareCollectionViewCell: UICollectionViewCell,UITableViewDelegate,UITableViewDataSource{
    private let dataSource = HomeViewModel.shared
    let scriptId = HomeViewModel.shared.currentScriptID
    
    // Remove hardcoded progressOfSession array
    var left: PerformanceReport?
    var right: PerformanceReport?
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    let afterClicking = UIImage(systemName: "chevron.down")
    let beforeClicking = UIImage(systemName: "chevron.right")
    var stateOfButtonPrevious : Bool = false
    
    // Add initialization method to set up the cell for dark mode
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply only the main cell background color to match OverallProgressCell
        applyMainBackgroundColor()
        
        // Update text colors for visibility
        updateTextColors()
        
        setupTableViews()
        setupButtons()
        tableViewConstriants()
        setupInitialState()
        flipProgressView()
    }
    
    private func applyMainBackgroundColor() {
        // Apply ONLY the main cell background color to match OverallProgressCell
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Set the background color to a more distinct grey to appear as a section
        let greyColor = isDarkMode ? UIColor(white: 0.25, alpha: 1.0) : UIColor.systemGray5
        
        // Apply the grey color to both the cell and its contentView
        backgroundColor = greyColor
        contentView.backgroundColor = greyColor
        
        // Add a subtle border for better section appearance
        layer.borderWidth = 0.5
        layer.borderColor = isDarkMode ? UIColor.gray.cgColor : UIColor.systemGray3.cgColor
        
        // Apply corner radius to maintain appearance
        layer.cornerRadius = 10
        layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Apply only main background color
            applyMainBackgroundColor()
            
            // Update text colors for visibility
            updateTextColors()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sessions = dataSource.getSessions(for: scriptId)
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sessions = dataSource.getSessions(for: scriptId)
        cell.textLabel?.text = sessions[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sessions = dataSource.getSessions(for: scriptId)
        let selectedSession = sessions[indexPath.row]
        let selectedText = selectedSession.title
        
        Task {
            if tableView.tag == 1 {
                stateOfButtonPrevious = false
                do {
                    left = try await dataSource.getPerformanceReport(for: selectedSession.id)
                    
                    await MainActor.run {
                        print("left", left ?? "No report found for left session")
                        previous.text = selectedText
                        TableView1.isHidden = true
                        
                        // Check if we can update the comparison
                        if let leftReport = left, let rightReport = right {
                            setData(leftReport: leftReport, rightReport: rightReport)
                        }
                    }
                } catch {
                    print("Error fetching left performance report: \(error)")
                    
                    await MainActor.run {
                        previous.text = selectedText
                        TableView1.isHidden = true
                    }
                }
            }
            
            if tableView.tag == 2 {
                stateOfButtonCurrent = false
                do {
                    right = try await dataSource.getPerformanceReport(for: selectedSession.id)
                    
                    await MainActor.run {
                        print("right", right ?? "No report found for right session")
                        current.text = selectedText
                        TableView2.isHidden = true
                        
                        // Check if we can update the comparison
                        if let leftReport = left, let rightReport = right {
                            setData(leftReport: leftReport, rightReport: rightReport)
                        }
                    }
                } catch {
                    print("Error fetching right performance report: \(error)")
                    
                    await MainActor.run {
                        current.text = selectedText
                        TableView2.isHidden = true
                    }
                }
            }
        }
    }
    
    func setData(leftReport: PerformanceReport, rightReport: PerformanceReport) {
        // Apply enhanced styling to progress views
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let progressBgColor = isDarkMode ? UIColor(white: 0.25, alpha: 1.0) : UIColor.systemGray6
        let progressTrackColor = isDarkMode ? UIColor(white: 0.15, alpha: 1.0) : UIColor.systemGray5
        
        // Update progress view styling
        [fillerP1, missingP1, paceP1, pronunciationP1, overallP1, 
         fillerP2, missingP2, paceP2, prounciationP2, overrallP2].forEach { progressView in
            progressView?.backgroundColor = progressBgColor
            progressView?.trackColor = progressTrackColor
            progressView?.layer.cornerRadius = 8
            progressView?.clipsToBounds = true
        }
        
        // Animate progress updates
        UIView.animate(withDuration: 2) {
            // Calculate scores for left side
            let leftFillerScore = max(0, 100 - (Double(leftReport.fillerWords.count) * 5)) / 100
            let leftMissingScore = max(0, 100 - (Double(leftReport.missingWords.count) * 5)) / 100
            let leftPaceScore = min(100, Double(leftReport.wordsPerMinute)) / 200
            let leftPronunciationScore = max(0, 100 - (Double(leftReport.pronunciationErrors.count) * 5)) / 100
            let leftOverallScore = (leftFillerScore + leftMissingScore + leftPaceScore + leftPronunciationScore) / 4
            
            // Calculate scores for right side
            let rightFillerScore = max(0, 100 - (Double(rightReport.fillerWords.count) * 5)) / 100
            let rightMissingScore = max(0, 100 - (Double(rightReport.missingWords.count) * 5)) / 100
            let rightPaceScore = min(100, Double(rightReport.wordsPerMinute)) / 200
            let rightPronunciationScore = max(0, 100 - (Double(rightReport.pronunciationErrors.count) * 5)) / 100
            let rightOverallScore = (rightFillerScore + rightMissingScore + rightPaceScore + rightPronunciationScore) / 4
            
            // Left side progress
            self.fillerP1.progress = leftFillerScore
            self.missingP1.progress = leftMissingScore
            self.paceP1.progress = leftPaceScore
            self.pronunciationP1.progress = leftPronunciationScore
            self.overallP1.progress = leftOverallScore
            
            // Right side progress
            self.fillerP2.progress = rightFillerScore
            self.missingP2.progress = rightMissingScore
            self.paceP2.progress = rightPaceScore
            self.prounciationP2.progress = rightPronunciationScore
            self.overrallP2.progress = rightOverallScore
            
            // Update overall score colors based on comparison - use brighter colors in dark mode
            let goodColor = isDarkMode ? UIColor.systemBlue.withAlphaComponent(0.8) : UIColor.systemBlue
            let badColor = isDarkMode ? UIColor.systemRed.withAlphaComponent(0.8) : UIColor.systemRed
            
            self.overallP1.progressColor = (leftOverallScore < rightOverallScore) ? badColor : goodColor
            self.overrallP2.progressColor = (rightOverallScore < leftOverallScore) ? badColor : goodColor
        }
        
        updateColor(leftProgress: fillerP1, rightProgress: fillerP2)
        updateColor(leftProgress: missingP1, rightProgress: missingP2)
        updateColor(leftProgress: pronunciationP1, rightProgress: prounciationP2)
        
        // Update pace colors based on words per minute - use brighter colors in dark mode
        let goodColor = isDarkMode ? UIColor.systemBlue.withAlphaComponent(0.8) : UIColor.systemBlue
        let badColor = isDarkMode ? UIColor.systemRed.withAlphaComponent(0.8) : UIColor.systemRed
        
        self.paceP1.progressColor = (leftReport.wordsPerMinute < 80 || leftReport.wordsPerMinute > 150) ? badColor : goodColor
        self.paceP2.progressColor = (rightReport.wordsPerMinute < 80 || rightReport.wordsPerMinute > 150) ? badColor : goodColor
    }
    
    func updateColor(leftProgress : RoundedEndProgress, rightProgress : RoundedEndProgress){
        if(leftProgress.progress < rightProgress.progress){
            leftProgress.progressColor = .systemBlue
            rightProgress.progressColor = .systemRed
        }else if(leftProgress.progress>rightProgress.progress){
            leftProgress.progressColor = .systemRed
            rightProgress.progressColor = .systemBlue
        }else{
            leftProgress.progressColor = .systemBlue
            rightProgress.progressColor  = .systemBlue
        }
        leftProgress.setNeedsDisplay()
        rightProgress.setNeedsDisplay()
    }
    func roundProgressView(){
        fillerP1.layer.cornerRadius = 10
        fillerP2.layer.cornerRadius = 10
        
    }
    func flipProgressView(){
        fillerP1.transform = CGAffineTransform(scaleX: -1, y: 1)
        missingP1.transform = CGAffineTransform(scaleX: -1, y: 1)
        paceP1.transform = CGAffineTransform(scaleX: -1, y: 1)
        pronunciationP1.transform = CGAffineTransform(scaleX: -1, y: 1)
        overallP1.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    func tableViewConstriants() {
        
    
        [TableView1, TableView2].forEach { tableView in
            if tableView?.superview == nil {
                contentView.addSubview(tableView!)
            }
            tableView?.translatesAutoresizingMaskIntoConstraints = false
            tableView?.layer.cornerRadius = 8
            tableView?.layer.borderWidth = 0.5
            tableView?.layer.borderColor = UIColor.systemGray4.cgColor
            tableView?.backgroundColor = .systemBackground
        }
        
        
        guard previous.superview != nil, current.superview != nil else {
            print("Labels must be properly connected in Interface Builder")
            return
        }
        
        NSLayoutConstraint.activate([
            // TableView1 constraints
            TableView1.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 8),
            TableView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            TableView1.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            TableView1.heightAnchor.constraint(equalToConstant: 150),
            
            // TableView2 constraints
            TableView2.topAnchor.constraint(equalTo: current.bottomAnchor, constant: 8),
            TableView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            TableView2.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            TableView2.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
            
    
    @IBOutlet weak var previous: UILabel!
    
    @IBOutlet weak var current: UILabel!

    
    @IBAction func previousB(_ sender: UIButton) {
        stateOfButtonPrevious.toggle()
        if stateOfButtonPrevious{
            TableView1.isHidden = false
            leftButton.setImage(afterClicking, for: .normal)
            print("Image set")
        }else{
            TableView1.isHidden = true
            leftButton.setImage(beforeClicking, for: .normal)
            print("Image previous")
        }
        
    }
    var stateOfButtonCurrent :Bool = false
    @IBAction func currentB(_ sender: UIButton) {
        stateOfButtonCurrent.toggle()
        if stateOfButtonCurrent{
            TableView2.isHidden = false
            rightButton.setImage(afterClicking, for: .normal)
            print("Image set")
        }else{
            TableView2.isHidden = true
            rightButton.setImage(beforeClicking, for: .normal)
            print("Image previous")
        }
    }
    
    @IBOutlet weak var TableView1: UITableView!
  
    @IBOutlet weak var TableView2: UITableView!
    
    //progress1
    
    @IBOutlet weak var fillerP1
    : RoundedEndProgress!
    
    @IBOutlet weak var missingP1: RoundedEndProgress!
    
    @IBOutlet weak var paceP1: RoundedEndProgress!
    
    @IBOutlet weak var pronunciationP1: RoundedEndProgress!
    
    @IBOutlet weak var overallP1: RoundedEndProgress!
    
    // progress 2
    
    @IBOutlet weak var fillerP2: RoundedEndProgress!
    @IBOutlet weak var missingP2: RoundedEndProgress!
    @IBOutlet weak var paceP2: RoundedEndProgress!
    @IBOutlet weak var prounciationP2: RoundedEndProgress!
    @IBOutlet weak var overrallP2: RoundedEndProgress!
    
    
    
    
    
    
    
    private func setupTableViews() {
        let table = [TableView1, TableView2]
        table.forEach {
            tableView in
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.isHidden = true
            tableView?.clipsToBounds = true
        }
        TableView1.tag = 1
        TableView2.tag = 2
    }

    func setupButtons() {
        let button = [leftButton, rightButton]
            button.forEach { button in
            button?.setImage(beforeClicking, for: .normal)
            button?.tintColor = .label
        }
    }

    func setupInitialState() {
        // button when not clicked
        let button = [leftButton, rightButton]
        button.forEach { button in
            button?.tintColor = .label
            button?.setImage(beforeClicking, for: .normal)
        }
        
        // label ui
        let ui = [previous, current]
            ui.forEach { label in
            label?.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        // table view intially hidden
        TableView1.isHidden = true
        TableView2.isHidden = true
    }

    // Add a method to be called when the cell becomes visible
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply styling to the category labels in the compare view to make them more visible
        styleComparisonLabels()
    }

    private func styleComparisonLabels() {
        // Try to find all labels in the content view that contain comparison categories
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let categoryNames = ["Fillers", "Missing Words", "Pace", "Pronunciation", "Overall"]
        
        // Look for labels in the entire view hierarchy
        contentView.subviews.forEach { view in
            if let label = view as? UILabel, categoryNames.contains(where: { label.text?.contains($0) ?? false }) {
                // Apply enhanced styling to these category labels
                label.backgroundColor = isDarkMode ? UIColor(white: 0.3, alpha: 1.0) : UIColor.systemGray5
                label.textColor = isDarkMode ? .white : .black
                label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                
                // Add a subtle border for better visibility
                label.layer.borderWidth = 0.5
                label.layer.borderColor = isDarkMode ? UIColor.gray.cgColor : UIColor.darkGray.cgColor
            }
        }
    }

    private func updateTextColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Only update text colors for visibility - not backgrounds
        if let previousLabel = previous {
            previousLabel.textColor = isDarkMode ? .white : .black
        }
        
        if let currentLabel = current {
            currentLabel.textColor = isDarkMode ? .white : .black
        }
        
        // Update buttons text color only
        [leftButton, rightButton].forEach { button in
            button?.tintColor = isDarkMode ? .white : .label
        }
    }
}
