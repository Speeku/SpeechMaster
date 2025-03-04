//
//  DemoViewController.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit

class ProgressViewController: UIViewController,UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UITableViewDelegate,
                          UITableViewDataSource,
                          UICollectionViewDelegateFlowLayout,
                              UIContextMenuInteractionDelegate {
    
    // Add property to use singleton
    private let dataSource = HomeViewModel.shared
    var scriptId: UUID = HomeViewModel.shared.currentScriptID// Add scriptId property
    
    let gifImage = UIImage.gifImageWithName("man")
    
    
    //    var sessions : [Sessions] = [
    //        Sessions(name: "Session 1", date: "10.01.2025"),
    //        Sessions(name: "Session 2", date: "12.01.2025"),
    //        Sessions(name: "Session 3", date: "14.01.2025"),
    //        Sessions(name: "Session 4", date: "15.01.2025")
    //        
    //    ]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            return dataSource.getSessions(for: scriptId).count
        } else {
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            return qnaSessions.count  // Return 0 if empty, no placeholder needed
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            if let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? cellTableViewCell{
                let sessions = dataSource.getSessions(for: scriptId)
                cell.topicName = sessions[indexPath.row].title
                cell.dateName = sessions[indexPath.row].createdAt.description
                cell.setup()
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? cellTableViewCell {
                let qnaSessions = dataSource.getQnASessions(for: scriptId)
                let session = qnaSessions[indexPath.row]
                
                // Format the date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let formattedDate = dateFormatter.string(from: session.createdAt)
                
                cell.topicName = session.title
                cell.dateName = formattedDate
                cell.setup()
                
                // Debug print
                print("Displaying QnA session: \(session.title)")
                print("Created at: \(formattedDate)")
                print("Session ID: \(session.id)")
                
                return cell
            }
        }
        return UITableViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallProgressCell", for: indexPath) as? OverallProgressCell else {
                return UICollectionViewCell()
            }
            
            // Use this for testing
            cell.testWithSimpleValues() // or cell.testWithDummyData() if you want to use the full version
            
            return cell
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
            let pageWidth = self.collectionView.bounds.width // Width of the collection view
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextViewController",
           let destinationVC = segue.destination as? ScriptEditViewController {
            destinationVC.editScriptText = scriptText
        }}
    var scriptTitle : String = ""
    var scriptText : String = ""
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segemtedControlOutlet: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reheraseB: UIButton!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var memorizeButton: UIButton! // New button for memorization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure navigation bar properly
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = scriptTitle
        
        // Ensure back button is visible
        navigationItem.hidesBackButton = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // Initial setup
        updateCollectionView()
        round()
        updateButtonName()
        
        // Configure table view
        configureTableView()
        
        // Configure collection view
        configureCollectionView()
        
        // Other setup
        updateLongPress()
        HomeViewModel.shared.currentScriptID = scriptId
        
        //navigationBarItem
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add empty state message
        tableView.backgroundView = createEmptyStateView()
        
        // Setup memorize button
        //  setupMemorizeButton()
        
        // Register the cell class programmatically
        collectionView.register(OverallProgressCell.self, forCellWithReuseIdentifier: "OverallProgressCell")
        
        // Setup collection view layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Basic table view setup
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        
        // Make sure table view is visible
        tableView.isHidden = false
        tableView.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            // Set collection view height
            let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 250)
            heightConstraint.priority = .required // Make this required
            heightConstraint.isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure navigation bar is visible and configured correctly
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        // Update table view data
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set fixed heights
        let spacing: CGFloat = 16
        
        // Make sure table view doesn't overlap with button
        let tableViewBottom = reheraseB.frame.origin.y - spacing
        let tableViewTop = segemtedControlOutlet.frame.maxY + spacing
        let tableViewHeight = tableViewBottom - tableViewTop
        
        // Update table view frame
        tableView.frame = CGRect(
            x: tableView.frame.origin.x,
            y: tableViewTop,
            width: tableView.frame.width,
            height: tableViewHeight
        )
        
        // Update rehearse button width to make room for memorize button
        if memorizeButton != nil {
            // Adjust rehearse button width to be about 60% of available width
            let availableWidth = view.bounds.width - 40 // 20 points padding on each side
            let rehearseButtonWidth = availableWidth * 0.6
            
            reheraseB.frame = CGRect(
                x: 20,
                y: reheraseB.frame.origin.y,
                width: rehearseButtonWidth,
                height: reheraseB.frame.height
            )
        }
    }
    
    func updateLongPress(){
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        textView.addInteraction(contextMenuInteraction)
    }
    func updateCollectionView(){
        
        
        
        let progressNib = UINib(nibName: "ProgressCellCollectionViewCell", bundle: nil)
        let compareNib = UINib(nibName: "CompareCollectionViewCell", bundle: nil)
        collectionView.register(compareNib, forCellWithReuseIdentifier: "CompareCollectionViewCell")
        collectionView.register(progressNib, forCellWithReuseIdentifier: "ProgressCellCollectionViewCell")
        //        collectionView.register(progressNib, forCellWithReuseIdentifier: "ProgressCollectionViewCell")
        
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
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("Used")
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func updateButtonName() {
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            reheraseB.setTitle("Rehearse Again", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            display = "No Practice Sessions"  // Set message for practice sessions
        } else {
            reheraseB.setTitle("Practice Q&A", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            display = "No Q&A Sessions Available"  // Set message for Q&A sessions
        }
        
        // Update visibility based on whether there are sessions
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            let sessions = dataSource.getSessions(for: scriptId)
            tableView.backgroundView?.isHidden = !sessions.isEmpty
        } else {
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            tableView.backgroundView?.isHidden = !qnaSessions.isEmpty
        }
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
        updateButtonName()
        updateEmptyStateVisibility()
    }
    
    
    @IBAction func rehearseButtonTap(_ sender: Any) {
        if segemtedControlOutlet.selectedSegmentIndex == 0{
            performSegue(withIdentifier: "toPerformance", sender: nil)
        }else{
            performSegue(withIdentifier: "toQ&A", sender: nil)
        }
    }
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        
        /* tell the exact position of the page
         1) like sender.currentPage tell the position of the dot
         2) collection.frame.width tell the width of the cell
         
         ***    So,  if we are on page 0
         sender.currentPage = 0
         and width let say is 300
         so newXposition = 0*300 = 0 -> we are on page 0
         
         ***    if we are on page 1 and want to move 0
         so newXposition = 0*300 = 0
         
         .setContentOffset -> shift the collectionView to that position
         and since we are doing horizontal scrolling we wouldn't
         be changing y axis that's why y = 0
         
         */
        let newXposition = CGFloat(sender.currentPage) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: newXposition, y: 0), animated: true)
        
    }
    
    @IBAction func unwindToProgressViewController(segue: UIStoryboardSegue) {
        print("segue called from save button")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            let practiceSession = dataSource.getSessions(for: scriptId)[indexPath.row]
            let report = dataSource.getPerformanceReport(for: practiceSession.id)
            let session = Session(from: practiceSession, report: report)
            let detailsVC = SessionDetailsViewController(session: session)
            navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            if qnaSessions.isEmpty {
                print("No QnA sessions to display")
                return
            }
            // ... rest of your Q&A handling code ...
        }
    }
    
    // Add this as a property
    private var emptyStateLabel: UILabel?
    private var display: String = "" {
        didSet {
            emptyStateLabel?.text = display
        }
    }
    
    private func createEmptyStateView() -> UIView {
        let view = UIView()
        let label = UILabel()
        emptyStateLabel = label  // Store reference to label
        label.text = display
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    // Update the text like this:
    func updateEmptyStateVisibility() {
        if segemtedControlOutlet.selectedSegmentIndex == 1 {
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            if qnaSessions.isEmpty {
                display = "No Q&A Sessions Available"
            }
            tableView.backgroundView?.isHidden = !qnaSessions.isEmpty
        } else {
            let sessions = dataSource.getSessions(for: scriptId)
            if sessions.isEmpty {
                display = "No Sessions Available"
            }
            tableView.backgroundView?.isHidden = !sessions.isEmpty
        }
    }
    
    //    private func setupMemorizeButton() {
    //        // Create memorize button if it doesn't exist in storyboard
    //        if memorizeButton == nil {
    //            let button = UIButton(type: .system)
    //            button.translatesAutoresizingMaskIntoConstraints = false
    //            button.setTitle("Memorize", for: .normal)
    //            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    //            button.backgroundColor = .systemIndigo
    //            button.setTitleColor(.white, for: .normal)
    //            button.layer.cornerRadius = 10
    //            button.clipsToBounds = true
    //            
    //            view.addSubview(button)
    //            
    //            // Position beside rehearse button
    //            NSLayoutConstraint.activate([
    //                button.centerYAnchor.constraint(equalTo: reheraseB.centerYAnchor),
    //                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    //                button.leadingAnchor.constraint(equalTo: reheraseB.trailingAnchor, constant: 16),
    //                button.heightAnchor.constraint(equalTo: reheraseB.heightAnchor)
    //            ])
    //            
    //            button.addTarget(self, action: #selector(memorizeButtonTapped), for: .touchUpInside)
    //            memorizeButton = button
    //        }
    //    }
    
    //    @objc public func memorizeButtonTapped() {
    //        let memorizationVC = MemorizationViewController()
    //        memorizationVC.scriptId = scriptId
    //        memorizationVC.scriptTitle = scriptTitle
    //        navigationController?.pushViewController(memorizationVC, animated: true)
    //    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        if indexPath.row == 0 {
    //            return CGSize(width: 353, height: 218)
    //        }
    //        return CGSize(width: collectionView.bounds.width - 20, height: 100)
    //    }
    //    }
    
}

