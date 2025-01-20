//
//  DemoViewController.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit

class DemoViewController: UIViewController,UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UITableViewDelegate,
                          UITableViewDataSource {
     let gifImage = UIImage.gifImageWithName("goblin")
    

    var sessions : [Session] = [
        Session(name: "Session 1"),
        Session(name: "Session 2"),
        Session(name: "Session 3"),
        Session(name: "Session 4")
    ]
    
    var qna : [QnA] = [
        QnA(name: "Q/A 1"),
        QnA(name: "Q/A 2"),
        QnA(name: "Q/A 3"),
        QnA(name: "Q/A 4")
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segemtedControlOutlet.selectedSegmentIndex == 0{
            return sessions.count
        }else{
            return qna.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segemtedControlOutlet.selectedSegmentIndex == 0{
            
                let cell  = UITableViewCell()
                cell.textLabel?.text = sessions[indexPath.row].name
            reheraseB.titleLabel?.text = "Reherase Again"
                return cell
            }else{
                let cell = UITableViewCell()
                cell.textLabel?.text = qna[indexPath.row].name
                reheraseB.titleLabel?.text = "Practice Q/A"
                return cell
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressCollectionViewCell", for: indexPath) as? ProgressCollectionViewCell{
                print("Sucesss")
                cell.title1.text = "Audience\nEngagement"
                cell.topicName1.text = "CyberSecurity"
                cell.title1Percent.text = "50%"
                cell.updateCircle1(percentage: 0.5, progresscolor: .orange)
                
                // step2
                cell.title2.text = "Overall\nImprovement"
                cell.topicName2.text = "CyberSecurity"
                cell.title2percent.text = "40%"
                cell.updateCircle2(percentage: 0.4, progresscolor: .green)
                cell.image.image = gifImage
                return cell
            }
        }
            if indexPath.row == 1{
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompareCollectionViewCell", for: indexPath) as? CompareCollectionViewCell{
                    print("Yeah")
                    return cell
                }
            }
            else{
                print("Failed")
                return UICollectionViewCell()
            }
        return UICollectionViewCell()
    }
    

   
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segemtedControlOutlet: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reheraseB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCollectionView()
        updateTableView()
        round()
        // Do any additional setup after loading the view.
    }
    func updateCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let progressNib = UINib(nibName: "ProgressCollectionViewCell", bundle: nil)
        let compareNib = UINib(nibName: "CompareCollectionViewCell", bundle: nil)
        collectionView.register(compareNib, forCellWithReuseIdentifier: "CompareCollectionViewCell")
        collectionView.register(progressNib, forCellWithReuseIdentifier: "ProgressCollectionViewCell")
        
    }
    
    func round(){
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        segemtedControlOutlet.layer.cornerRadius = 10
        segemtedControlOutlet.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        reheraseB.layer.cornerRadius = 10
        reheraseB.clipsToBounds = true
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
    }
    func updateTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            
            
            performSegue(withIdentifier: "PopOverViewController", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PopOverViewController" {
            if let pop = segue.destination as? PopOverViewController {
                if let textView = sender as? UITextView {
                    
                    pop.popoverPresentationController?.sourceView = textView
                    pop.popoverPresentationController?.sourceRect = textView.bounds
                    pop.popoverPresentationController?.permittedArrowDirections = .down
                    pop.preferredContentSize = CGSize(width: 300, height: 300)
                
                }
            }
        }
    }

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
        }
    }

    
    
    
    
    
    
    
    


