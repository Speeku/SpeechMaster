//
//  CompareCollectionViewCell.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit
class CompareCollectionViewCell: UICollectionViewCell,UITableViewDelegate,UITableViewDataSource{
    
    var progressOfSession : [Progress] = [
        Progress(name: "Session 1", fillerWords: 20, missingWords: 10, pace: 123, pronunciation: 1),
        Progress(name: "Session 2", fillerWords: 40, missingWords: 10, pace: 100, pronunciation: 5),
        Progress(name: "Session 3", fillerWords: 50, missingWords: 10, pace: 170, pronunciation: 4),
        Progress(name: "Session 4", fillerWords: 100, missingWords: 12, pace: 140, pronunciation: 6),
        
    ]
    var left : Progress?
    var right : Progress?
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    let afterClicking = UIImage(systemName: "chevron.down")
    let beforeClicking = UIImage(systemName: "chevron.right")
    var stateOfButtonPrevious : Bool = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DataController.shared.sessionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = DataController.shared.sessionsArray[indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row with animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Hide the table view and reset button image
        // and animate the button
        UIView.animate(withDuration: 0.3) {
            tableView.isHidden = true
            
            // Reset appropriate button image based on which table view was selected
            // case if something is selected from the table view and table
            // view hides so to return the button back to its normal >
            if tableView == self.TableView1 {
                self.leftButton.setImage(self.beforeClicking, for: .normal)
            } else {
                self.rightButton.setImage(self.beforeClicking, for: .normal)
            }
        }
        let selectedText = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
        if tableView.tag == 1{
            stateOfButtonPrevious = false
            left = progressOfSession[indexPath.row]
            previous.text = selectedText
            TableView1.isHidden = true
            print("left used")
        }
        
        if tableView.tag == 2{
            stateOfButtonCurrent = false
            right = progressOfSession[indexPath.row]
            TableView2.isHidden = true
            current.text = selectedText
            print("right used")
        }
        if let leftProgress = left, let rightProgress = right {
                setData(leftProgress: leftProgress, rightProgress: rightProgress)
            }
        
    }
    func setData(leftProgress : Progress,rightProgress : Progress){

            // Table view 1
        // when data change so it animates
        UIView.animate(withDuration: 2){
            self.fillerP1.progress = CGFloat(leftProgress.fillerWords) / 100
            self.missingP1.progress = CGFloat(leftProgress.missingWords) / 100
            self.paceP1.progress = CGFloat(leftProgress.pace) / 200
            self.pronunciationP1.progress = CGFloat(leftProgress.pronunciation) / 100
            self.overallP1.progress = CGFloat(leftProgress.overall) / 100
            
            // Table view 2
            self.fillerP2.progress = CGFloat(rightProgress.fillerWords) / 100
            self.missingP2.progress = CGFloat(rightProgress.missingWords) / 100
            self.paceP2.progress = CGFloat(rightProgress.pace) / 200
            self.prounciationP2.progress = CGFloat(rightProgress.pronunciation) / 100
            self.overrallP2.progress = CGFloat(rightProgress.overall) / 100
            
        }
        updateColor(leftProgress: fillerP1, rightProgress: fillerP2)
        updateColor(leftProgress: missingP1, rightProgress: missingP2)
        updateColor(leftProgress: pronunciationP1, rightProgress: prounciationP2)
        self.paceP1.progressColor = (leftProgress.pace < 80 || rightProgress.pace > 150) ? .systemRed : .systemBlue
        self.paceP2.progressColor = (rightProgress.pace < 80 || leftProgress.pace > 150) ? .systemRed : .systemBlue
        self.overallP1.progressColor = (leftProgress.overall<rightProgress.overall) ? .systemRed : .systemBlue
        self.overrallP2.progressColor = (rightProgress.overall<leftProgress.overall) ? .systemRed : .systemBlue
        
           

        
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
        var table = [TableView1, TableView2]
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
        var button = [leftButton, rightButton]
            button.forEach { button in
            button?.setImage(beforeClicking, for: .normal)
            button?.tintColor = .label
        }
    }

    func setupInitialState() {
        // button when not clicked
        var button = [leftButton, rightButton]
        button.forEach { button in
            button?.tintColor = .label
            button?.setImage(beforeClicking, for: .normal)
        }
        
        // label ui
        var ui = [previous, current]
            ui.forEach { label in
            label?.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        // table view intially hidden
        TableView1.isHidden = true
        TableView2.isHidden = true
    }
}
