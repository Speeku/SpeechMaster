//
//  CompareCollectionViewCell.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit

class CompareCollectionViewCell: UICollectionViewCell,UITableViewDelegate,UITableViewDataSource{
    
    var progressOfSession : [Progress] = [
        Progress(name: "Session 1", fillerWords: 100, missingWords: 10, pace: 10, pronunciation: 1),
        Progress(name: "Session 2", fillerWords: 100, missingWords: 10, pace: 10, pronunciation: 5),
        Progress(name: "Session 3", fillerWords: 100, missingWords: 10, pace: 10, pronunciation: 4),
        Progress(name: "Session 4", fillerWords: 100, missingWords: 12, pace: 10, pronunciation: 6),
        
    ]
    var left : Progress?
    var right : Progress?
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    let afterClicking = UIImage(systemName: "arrowshape.right.fill")
    let beforeClicking = UIImage(systemName: "arrowshape.down.fill")
    var stateOfButton : Bool = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = sessions[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 1{
            stateOfButton = false
            left = progressOfSession[indexPath.row]
            previous.text = progressOfSession[indexPath.row].name
            previousTableView.isHidden = true
            print("left used")
        }
        
        if tableView.tag == 2{
            right = progressOfSession[indexPath.row]
            currentTableView.isHidden = true
            current.text = progressOfSession[indexPath.row].name
            print("right used")
        }
        if let leftProgress = left, let rightProgress = right {
                setData(leftProgress: leftProgress, rightProgress: rightProgress)
            }
        
    }
    func setData(leftProgress : Progress,rightProgress : Progress){

            // Table view 1
        UIView.animate(withDuration: 0.5){
            self.fillerP1.progress = min(max(Float(leftProgress.fillerWords) / 100, 0.0), 1.0)
            self.missingP1.progress = min(max(Float(leftProgress.missingWords) / 100, 0.0), 1.0)
            self.paceP1.progress = min(max(Float(leftProgress.pace) / 100, 0.0), 1.0)
            self.pronunciationP1.progress = min(max(Float(leftProgress.pronunciation) / 100, 0.0), 1.0)
            self.overallP1.progress = min(max(Float(leftProgress.overall) / 100, 0.0), 1.0)
            
            // Table view 2
            self.fillerP2.progress = min(max(Float(rightProgress.fillerWords) / 100, 0.0), 1.0)
            self.missingP2.progress = min(max(Float(rightProgress.missingWords) / 100, 0.0), 1.0)
            self.paceP2.progress = min(max(Float(rightProgress.pace) / 100, 0.0), 1.0)
            self.prounciationP2.progress = min(max(Float(rightProgress.pronunciation) / 100, 0.0), 1.0)
            self.overrallP2.progress = min(max(Float(rightProgress.overall) / 100, 0.0), 1.0)
            
        }
            //height of progress view
       
        
        
        
        
        
        
        
        
        
        
        
               // color
            updateProgressBarColors(leftValue: leftProgress.fillerWords, rightValue: rightProgress.fillerWords, leftProgressBar: fillerP1, rightProgressBar: fillerP2)
            updateProgressBarColors(leftValue: leftProgress.missingWords, rightValue: rightProgress.missingWords, leftProgressBar: missingP1, rightProgressBar: missingP2)
        updateProgressBarColors(leftValue: Int(leftProgress.pace), rightValue: Int(rightProgress.pace), leftProgressBar: paceP1, rightProgressBar: paceP2)
        updateProgressBarColors(leftValue: Int(leftProgress.pronunciation), rightValue: Int(rightProgress.pronunciation), leftProgressBar: pronunciationP1, rightProgressBar: prounciationP2)
        updateProgressBarColors(leftValue: Int(leftProgress.overall), rightValue: Int(rightProgress.overall), leftProgressBar: overallP1, rightProgressBar: overrallP2)
        

        
    }
    func updateProgressBarColors(leftValue: Int, rightValue: Int, leftProgressBar: UIProgressView, rightProgressBar: UIProgressView) {
        if leftValue > rightValue {
            leftProgressBar.tintColor = .red
            rightProgressBar.tintColor = .green
        } else if leftValue < rightValue {
            leftProgressBar.tintColor = .green
            rightProgressBar.tintColor = .red
        } else {
            leftProgressBar.tintColor = .gray
            rightProgressBar.tintColor = .gray
        }
    }

    func round(){
        fillerP1.layer.cornerRadius = 10
        fillerP2.layer.cornerRadius = 10
        
    }
    
    
    
    
    @IBOutlet weak var previous: UILabel!
    
    @IBOutlet weak var current: UILabel!
    
    @IBAction func previousB(_ sender: UIButton) {
        stateOfButton.toggle()
        if stateOfButton{
            previousTableView.isHidden = false
            leftButton.setImage(afterClicking, for: .normal)
            print("Image set")
        }else{
            previousTableView.isHidden = true
            leftButton.setImage(beforeClicking, for: .normal)
            print("Image previous")
        }
        
        //previousTableView.isHidden = !previousTableView.isHidden
    }
    
    @IBAction func currentB(_ sender: UIButton) {
        
        currentTableView.isHidden = !currentTableView.isHidden
    }
    
    @IBOutlet weak var previousTableView: UITableView!
  
    @IBOutlet weak var currentTableView: UITableView!
    
    //progress1
    
    @IBOutlet weak var fillerP1
    : UIProgressView!
    
    @IBOutlet weak var missingP1: UIProgressView!
    
    @IBOutlet weak var paceP1: UIProgressView!
    
    @IBOutlet weak var pronunciationP1: UIProgressView!
    
    @IBOutlet weak var overallP1: UIProgressView!
    
    // progress 2
    
    @IBOutlet weak var fillerP2: UIProgressView!
    @IBOutlet weak var missingP2: UIProgressView!
    @IBOutlet weak var paceP2: UIProgressView!
    @IBOutlet weak var prounciationP2: UIProgressView!
    @IBOutlet weak var overrallP2: UIProgressView!
    
    
    
    
    
    var sessions : [Session] = [
        Session(name: "Session 1"),
        Session(name: "Session 2"),
        Session(name: "Session 3"),
        Session(name: "Session 4")
    ]
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        previousTableView.delegate = self
        previousTableView.dataSource = self
        currentTableView.delegate = self
        currentTableView.dataSource = self
        previousTableView.isHidden = true
        currentTableView.isHidden = true
        
        //tag
        previousTableView.tag = 1
        currentTableView.tag = 2
    }
    
    
}
