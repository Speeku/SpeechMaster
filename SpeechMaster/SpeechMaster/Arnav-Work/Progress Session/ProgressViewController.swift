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
                          UITableViewDataSource,UICollectionViewDelegateFlowLayout, UIContextMenuInteractionDelegate {
    
    
    let gifImage = UIImage.gifImageWithName("man")
    
    
    var sessions : [Sessions] = [
        Sessions(name: "Session 1", date: "10.01.2025"),
        Sessions(name: "Session 2", date: "12.01.2025"),
        Sessions(name: "Session 3", date: "14.01.2025"),
        Sessions(name: "Session 4", date: "15.01.2025")
        
    ]
    
    var qna : [QnA] = [
        QnA(name: "Q/A 1", date: "10.01.2025"),
        QnA(name: "Q/A 2", date: "12.01.2025"),
        QnA(name: "Q/A 3", date: "13.01.2025"),
        QnA(name: "Q/A 4", date: "15.01.2025")
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
            
            if let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? cellTableViewCell{
                cell.topicName = sessions[indexPath.row].name
                cell.dateName = sessions[indexPath.row].date
                cell.setup()
               // reheraseB.titleLabel?.text = "Reherase Again"
                updateButtonName()
                return cell
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as? cellTableViewCell{
                cell.topicName = qna[indexPath.row].name
                cell.dateName = qna[indexPath.row].date
                cell.setup()
              //  reheraseB.titleLabel?.text = "Practice Q/A"
                updateButtonName()
                return cell
            }
        }
        print("Default Called")
        return UITableViewCell()
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
                
                
                pageControll.currentPage = indexPath.row
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Ensure that the scrollView is your collection view
        if scrollView == collectionView {
            let pageWidth = collectionView.bounds.width // Width of the collection view
            let currentPage = Int((collectionView.contentOffset.x + (0.5 * pageWidth)) / pageWidth)
            
            // Set the page control's current page to match the collection view's current page
            pageControll.currentPage = currentPage
        }
    }
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
        // actions defined
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                print("Edit Tapped")
                self.performSegue(withIdentifier: "TextViewController", sender :self)
            }
            
            let regenerate = UIAction(title: "Regenerate", image: UIImage(systemName: "arrow.2.circlepath.circle")) { _ in
                print("Regenerate Tapped")
            }
            
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("Share Tapped")
            }
            
            // Return the menu
            return UIMenu(title: "", children: [edit, regenerate, share])
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segemtedControlOutlet: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reheraseB: UIButton!
    
    @IBOutlet weak var pageControll: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCollectionView()
        updateTableView()
        round()
        updateLongPress()
       
      
        
    }
    func updateLongPress(){
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        textView.addInteraction(contextMenuInteraction)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("Used")
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) //
    }
    
    func updateButtonName(){
        if segemtedControlOutlet.selectedSegmentIndex == 0{
            reheraseB.setTitle("Rehearse Again", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        }else{
            reheraseB.setTitle("Practice Q&A", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @IBAction func unwindCancel(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func rehearseButtonTap(_ sender: Any) {
        if segemtedControlOutlet.selectedSegmentIndex == 0{
            performSegue(withIdentifier: "toPerformance", sender: nil)
        }else{
            performSegue(withIdentifier: "toQ&A", sender: nil)
        }
    }

    }



