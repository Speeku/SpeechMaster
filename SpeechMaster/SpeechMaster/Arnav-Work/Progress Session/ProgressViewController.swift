//
//  DemoViewController.swift
//  app1
//
//  Created by Arnav Chauhan on 14/01/25.
//

import UIKit
import Supabase // {{Add Supabase import}}

class ProgressViewController: UIViewController,UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UITableViewDelegate,
                          UITableViewDataSource,
                          UICollectionViewDelegateFlowLayout,
                              UIContextMenuInteractionDelegate,
                              ScriptEditDelegate {
    
    // Add property to use singleton
    private let dataSource = HomeViewModel.shared
    var scriptId: UUID = HomeViewModel.shared.currentScriptID// Add scriptId property
    
    
    
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
                cell.dateName = sessions[indexPath.row].createdAt.formatted(date : .long ,time : .shortened)
                cell.setup()
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? cellTableViewCell {
                let qnaSessions = dataSource.getQnASessions(for: scriptId)
                let session = qnaSessions[indexPath.row]
                
                // Format the date
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .medium
//                dateFormatter.timeStyle = .short
//                let formattedDate = dateFormatter.string(from: session.createdAt)
                
                cell.topicName = session.title
                cell.dateName = session.createdAt.formatted(date: .long, time: .shortened)
                cell.setup()
                
                return cell
            }
        }
        return UITableViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let cellBackgroundColor = isDarkMode ? UIColor(white: 0.22, alpha: 1.0) : .systemBackground
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallProgressCell", for: indexPath) as! OverallProgressCell
            
            // Configure cell for both light and dark mode
            cell.layer.cornerRadius = 10
            cell.contentView.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.contentView.clipsToBounds = true
            
            // Force correct background color
            cell.backgroundColor = cellBackgroundColor
            cell.contentView.backgroundColor = cellBackgroundColor
            
            // Ensure the cell fills the entire width of the collection view
            cell.contentView.frame = cell.bounds
            
            // Set data and load improvement data
            cell.dataSource = dataSource
            cell.scriptId = scriptId
            cell.loadImprovementData() // Call the async method to load real data
            return cell
        }
        
        if indexPath.row == 1 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompareCollectionViewCell", for: indexPath) as? CompareCollectionViewCell {
                // Configure cell for both light and dark mode
                cell.layer.cornerRadius = 10
                cell.contentView.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.contentView.clipsToBounds = true
                
                // Force correct background color for main cell only, NOT for content view
                cell.backgroundColor = cellBackgroundColor
                // DO NOT set contentView.backgroundColor to allow elements to keep their styling
                
                // Ensure the cell fills the entire width of the collection view
                cell.contentView.frame = cell.bounds
                
                return cell
            }
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
            
            
//            let regenerate = UIAction(title: "Regenerate", image: UIImage(systemName: "arrow.2.circlepath.circle")) { _ in
//                print("Regenerate Tapped")
//            }
//            
//            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
//                print("Share Tapped")
//            }
            
            // Return the menu
            return UIMenu(title: "", children: [edit])
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editVC = segue.destination as? ScriptEditViewController {
            editVC.editScriptText = scriptText
            editVC.delegate = self
        }
    }
    
    // ScriptEditDelegate implementation
    func scriptDidUpdate(newText: String) {
        scriptText = newText
        textView.text = newText
        
        // Update the script in data source
        dataSource.setScriptText(for: scriptId, text: newText)
        
        // Refresh the collection view to show updated progress
        collectionView.reloadData()
        
        // Update any other UI elements that depend on the script text
        updateCollectionView()
    }
    
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
        textView.text = scriptText
        // Configure navigation bar properly
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = scriptTitle
        
        // Ensure back button is visible
        navigationItem.hidesBackButton = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // Set tags for the section headers for dark mode support
        if let stackView = self.view.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            if let scriptLabel = stackView.arrangedSubviews.first(where: { ($0 as? UILabel)?.text == "Script" }) as? UILabel {
                scriptLabel.tag = 100
            }
            if let progressLabel = stackView.arrangedSubviews.first(where: { ($0 as? UILabel)?.text == "Progress" }) as? UILabel {
                progressLabel.tag = 101
            }
        }
        
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
        
        // Apply dark mode support
        setupDarkModeSupport()
        
        print(dataSource.getScriptTitle(for: scriptId))
        //self.title = dataSource.getScriptTitle(for: scriptId)
    }
    
    // Support for dark mode
    private func setupDarkModeSupport() {
        // Apply colors based on the current trait collection
        applyDarkModeColors(for: traitCollection)
        
        // Update the button style
        reheraseB.setTitleColor(.white, for: .normal)
        reheraseB.backgroundColor = .systemBlue
        reheraseB.layer.cornerRadius = 15
    }
    
    // Apply appropriate colors based on the trait collection
    private func applyDarkModeColors(for traitCollection: UITraitCollection) {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Main view background - keep it pure black
        self.view.backgroundColor = isDarkMode ? .black : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        
        // Script header label
        if let scriptLabel = self.view.viewWithTag(100) as? UILabel ?? 
           self.view.subviews.first(where: { $0 is UIStackView })?.subviews.first(where: { $0 is UILabel && ($0 as! UILabel).text == "Script" }) as? UILabel {
            scriptLabel.textColor = isDarkMode ? .white : .black
        }
        
        // Progress header label
        if let progressLabel = self.view.viewWithTag(101) as? UILabel ?? 
           self.view.subviews.first(where: { $0 is UIStackView })?.subviews.first(where: { ($0 as? UILabel)?.text == "Progress" }) as? UILabel {
            progressLabel.textColor = isDarkMode ? .white : .black
        }
        
        // Script text view background - make it dark gray for contrast
        textView.backgroundColor = isDarkMode ? UIColor(white: 0.12, alpha: 1.0) : .white
        textView.textColor = isDarkMode ? .white : .black
        
        // Stack view background (main content area)
        if let stackView = self.view.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            stackView.backgroundColor = isDarkMode ? .black : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        
        // Table view background - make it slightly lighter gray
        tableView.backgroundColor = isDarkMode ? UIColor(white: 0.17, alpha: 1.0) : .systemBackground
        
        // Bottom container view
        if let bottomView = self.view.subviews.last as? UIView, bottomView.subviews.first is UIButton {
            bottomView.backgroundColor = isDarkMode ? .black : .systemBackground
        }
        
        // Collection view background - use the exact same color as the cells
        collectionView.backgroundColor = isDarkMode ? UIColor(white: 0.22, alpha: 1.0) : .systemBackground
        
        // Update segmented control background
        segemtedControlOutlet.backgroundColor = isDarkMode ? UIColor(white: 0.25, alpha: 1.0) : nil
    }
    
    // Override trait collection did change to update colors when dark mode changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Only update if the user interface style changed (dark/light mode)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Apply styling from first implementation
            applyDarkModeColors(for: traitCollection)
            
            // Apply styling from second implementation
            round()
            
            // Update empty state view colors
            if let backgroundView = tableView.backgroundView {
                let isDarkMode = traitCollection.userInterfaceStyle == .dark
                backgroundView.backgroundColor = isDarkMode ? UIColor(white: 0.17, alpha: 1.0) : .systemBackground
                if let label = emptyStateLabel {
                    label.textColor = isDarkMode ? .lightGray : .gray
                }
            }
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
        
        // Ensure the collection view itself has corner radius
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        
        // Set the exact background color that matches the cells
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        collectionView.backgroundColor = isDarkMode ? UIColor(white: 0.22, alpha: 1.0) : .systemBackground
        
        // Remove any additional spacing or padding that might cause gaps
        collectionView.contentInsetAdjustmentBehavior = .never
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0 // No space between cells
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero // No insets
            
            // Set collection view height
            let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 218)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh script text from data source
        if let script = dataSource.scripts.first(where: { $0.id == scriptId }) {
            scriptText = script.scriptText
            textView.text = scriptText
        }
        
        // Ensure navigation bar is visible and configured correctly
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        // Update table view data
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the collection view's page width exactly matches its frame width
        // This prevents partial cells from being visible during page transitions
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            layout.invalidateLayout()
        }
        
        // Make sure to update cells to fill the entire width
        for cell in collectionView.visibleCells {
            cell.contentView.frame = cell.bounds
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
    
    func round() {
        // Style collection and table view
        segemtedControlOutlet.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        reheraseB.layer.cornerRadius = 10
        reheraseB.clipsToBounds = true
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        
        // Style for dark mode compatibility
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Update text view for dark mode
        textView.backgroundColor = isDarkMode ? UIColor(white: 0.12, alpha: 1.0) : .white
        textView.textColor = isDarkMode ? .white : .black
        
        // Collection view and table view backgrounds - make collection view (progress section) lighter
        collectionView.backgroundColor = isDarkMode ? UIColor(white: 0.22, alpha: 1.0) : .systemBackground
        tableView.backgroundColor = isDarkMode ? UIColor(white: 0.17, alpha: 1.0) : .systemBackground
        
        // Update segmented control for better visibility in dark mode
        if isDarkMode {
            segemtedControlOutlet.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            segemtedControlOutlet.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            segemtedControlOutlet.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        }
        
        // Update the rehearse button with better styling
        reheraseB.backgroundColor = .systemBlue
        reheraseB.setTitleColor(.white, for: .normal)
        
        // Make empty state label use appropriate colors
        if let emptyLabel = emptyStateLabel {
            emptyLabel.textColor = isDarkMode ? .lightGray : .gray
        }
        
        // Update section headers for dark mode
        updateSectionHeadersForDarkMode(isDarkMode)
    }
    
    // Add this method to handle section header colors
    private func updateSectionHeadersForDarkMode(_ isDarkMode: Bool) {
        if let scriptLabel = view.viewWithTag(100) as? UILabel {
            scriptLabel.textColor = isDarkMode ? .white : .black
        }
        
        if let progressLabel = view.viewWithTag(101) as? UILabel {
            progressLabel.textColor = isDarkMode ? .white : .black
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func updateButtonName() {
        if segemtedControlOutlet.selectedSegmentIndex == 0 {
            reheraseB.setTitle("Rehearse Again", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            let sessions = dataSource.getSessions(for: scriptId)
            if sessions.isEmpty{
                display = "No Practice Sessions"
            }else{
                tableView.backgroundView?.isHidden = !sessions.isEmpty
            }
            // Set message for practice sessions
        } else {
            reheraseB.setTitle("Practice Q&A", for: .normal)
            reheraseB.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            if qnaSessions.isEmpty{
                display = "No Q&A Sessions Available"
            }else{
                tableView.backgroundView?.isHidden = !qnaSessions.isEmpty
                
            }
            // Set message for Q&A sessions
        }
        
        // Update visibility based on whether there are sessions
        
        
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
            
            // Use Task to handle async call
            Task {
                var report: PerformanceReport?
                do {
                    report = try await dataSource.getPerformanceReport(for: practiceSession.id)
                } catch {
                    print("Error fetching performance report: \(error)")
                }
                
                // Create a session object with the fetched report
                let session = Session(from: practiceSession, report: report)
                
                // Update UI on the main thread
                await MainActor.run {
                    let detailsVC = SessionDetailsViewController(session: session)
                    self.navigationController?.pushViewController(detailsVC, animated: true)
                }
            }
        } else {
            let qnaSessions = dataSource.getQnASessions(for: scriptId)
            if qnaSessions.isEmpty {
                print("No QnA sessions to display")
                return
            }else{
                let selectedSession = qnaSessions[indexPath.row]
                
                // Get questions for this session
                let questions = dataSource.getQuestions(for: selectedSession.id)
                print("Loading report for session: \(selectedSession.title)")
                print("Found \(questions.count) questions for session ID: \(selectedSession.id)")
                
                // Create and configure QuestionAnswerList
                if let questionListVC = UIStoryboard(name: "QuestionAndAnswers", bundle: nil)
                    .instantiateViewController(withIdentifier: "QuestionAnswerList") as? QuestionAnswerList {
                    
                    // Pass the questions to QuestionAnswerList and mark as viewing existing session
                    questionListVC.qna_dataController.questions = questions
                    questionListVC.isViewingExistingSession = true
                    
                    // Push the view controller
                    navigationController?.pushViewController(questionListVC, animated: true)
                }
            }
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
            // Set color based on current mode
            let isDarkMode = traitCollection.userInterfaceStyle == .dark
            label.textColor = isDarkMode ? .lightGray : .gray
            label.font = .systemFont(ofSize: 16)
            
            // Set background color of the empty state view to match the table view
            if isDarkMode {
                view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            }
            
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
        
        // Implement this method to ensure cells fill the width of the collection view
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Return the exact size of the collection view to ensure full-width cells
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        
    }
    

