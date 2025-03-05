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
        // Deselect the row with animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Hide the table view and reset button image
        UIView.animate(withDuration: 0.3) {
            tableView.isHidden = true
            
            if tableView == self.TableView1 {
                self.leftButton.setImage(self.beforeClicking, for: .normal)
            } else {
                self.rightButton.setImage(self.beforeClicking, for: .normal)
            }
        }
        
        let sessions = dataSource.getSessions(for: scriptId)
        let selectedSession = sessions[indexPath.row]
        let selectedText = selectedSession.title
        
        if tableView.tag == 1 {
            stateOfButtonPrevious = false
            left = dataSource.getPerformanceReport(for: selectedSession.id)
            previous.text = selectedText
            TableView1.isHidden = true
        }
        
        if tableView.tag == 2 {
            stateOfButtonCurrent = false
            right = dataSource.getPerformanceReport(for: selectedSession.id)
            TableView2.isHidden = true
            current.text = selectedText
        }
        
        if let leftReport = left, let rightReport = right {
            setData(leftReport: leftReport, rightReport: rightReport)
        }
    }
    
    func setData(leftReport: PerformanceReport, rightReport: PerformanceReport) {
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
            
            // Update overall score colors based on comparison
            self.overallP1.progressColor = (leftOverallScore < rightOverallScore) ? .systemRed : .systemBlue
            self.overrallP2.progressColor = (rightOverallScore < leftOverallScore) ? .systemRed : .systemBlue
        }
        
        updateColor(leftProgress: fillerP1, rightProgress: fillerP2)
        updateColor(leftProgress: missingP1, rightProgress: missingP2)
        updateColor(leftProgress: pronunciationP1, rightProgress: prounciationP2)
        
        // Update pace colors based on words per minute
        self.paceP1.progressColor = (leftReport.wordsPerMinute < 80 || leftReport.wordsPerMinute > 150) ? .systemRed : .systemBlue
        self.paceP2.progressColor = (rightReport.wordsPerMinute < 80 || rightReport.wordsPerMinute > 150) ? .systemRed : .systemBlue
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
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableViews()
        setupButtons()
        tableViewConstriants()
        setupInitialState()
        flipProgressView()
    
    }
  
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
}
