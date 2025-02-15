import UIKit

class reportScreenVC: UIViewController {
    let ds = DataController.shared
    var scriptId: UUID?  // Add this property to store the script ID
    
    @objc private func saveAndDismiss() {
        let alert = UIAlertController(title: "Save Session", message: "Enter a name for this session", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Session Name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let sessionName = alert.textFields?.first?.text, !sessionName.isEmpty else {
                // Show error if session name is empty
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a session name", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            // Create new report and session
            let newReport = Report(id: UUID(), 
                                 missingWords: missingWords, 
                                 fillerWords: fillers, 
                                 pace: pace, 
                                 pitch: pitch, 
                                 originality: originality, 
                                 pronunciationScore: 10)
            
            let newSession = PracticeSession(id: UUID(), 
                                           scriptId: self.scriptId ?? UUID(), // Use the passed scriptId or create new one
                                           recordingURL: "", 
                                           createdAt: Date(), 
                                           title: sessionName, 
                                           hasKeynote: true, 
                                           reportId: newReport.id)
            
            // Save the session using DataController
            self.ds.addSession(newSession)
            
            // Show success message
            let successAlert = UIAlertController(title: "Success", message: "Session saved successfully!", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // Pop to the root of the navigation stack after user acknowledges
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(successAlert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func SaveButtonTapped(_ sender: Any) {
        
        saveAndDismiss()
    }
    
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
    }
    func createLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                
          
                
                // Define the items and groups for each section
                switch sectionIndex {
                case 0: return self.createMotivationalQuotesSection()
                case 1: return self.createVideoCellSection()
                case 2: return self.createSummaryCellSection()
                case 3: return self.createFillersCellSection()
                case 4: return self.createMissingWordsCellSection()
                case 5: return self.createPaceCellSection()
                case 6: return self.createPronunciationCellSection()
                case 7: return self.createPitchCellSection()
                case 8: return self.createOriginalityCellSection()
                
                default: return nil
                }
            }
        }
    
 
    
}






extension reportScreenVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func createVideoCellSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(200)) // Adjust height for video
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 0,
            trailing: 3)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            return NSCollectionLayoutSection(group: group)
        }
        
    func createSummaryCellSection() -> NSCollectionLayoutSection {
           let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(85)) // Adjust height for labels
       
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)

           return NSCollectionLayoutSection(group: group)
       }
    
    func createFillersCellSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(90)) // Adjust height for 3 labels
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            return NSCollectionLayoutSection(group: group)
        }
    
    func createMissingWordsCellSection() -> NSCollectionLayoutSection {
           let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(90)) // Adjust height for 3 labels
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
           return NSCollectionLayoutSection(group: group)
       }
    
    func createPaceCellSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(500)) // Adjust height for graph
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            return NSCollectionLayoutSection(group: group)
        }
    
    func createPronunciationCellSection() -> NSCollectionLayoutSection {
           let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(350)) // Buttons, label, UIView
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
           return NSCollectionLayoutSection(group: group)
       }
    
    func createPitchCellSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(320)) // Graph for pitch
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            return NSCollectionLayoutSection(group: group)
        }
    
    func createOriginalityCellSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
        
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(150)) // Originality text
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 8,
            bottom: 3,
            trailing: 8)
            return NSCollectionLayoutSection(group: group)
        }
    
    func createMotivationalQuotesSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
    
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(
        top: 3,
        leading: 8,
        bottom: 3,
        trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(100)) // Originality text
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = NSDirectionalEdgeInsets(
        top: 3,
        leading: 8,
        bottom: 3,
        trailing: 8)
        return NSCollectionLayoutSection(group: group)
        
    }
    
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 9
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MotivationalQuotesCell", for: indexPath) as! motivatingQuotesCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCVCell
            if !video.isEmpty {
                let userVideo = video[indexPath.item]
                cell.updateVideo(with: userVideo)
            }
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCell", for: indexPath) as! SummaryCVCell
            cell.updateSummary(with: summary)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FillerCell", for: indexPath) as! FillersCVCell
            let userFillers = fillers//indexPath.item]
            cell.updateFillers(with: userFillers)
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MissingWordCell", for: indexPath) as! MissingWordsCVCell
            let userMissingWords = missingWords//[indexPath.item]
            cell.updateMissingWords(with: userMissingWords)
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaceCell", for: indexPath) as! PaceCVCell
            let userPace = pace
            cell.updatePace(with: userPace)
            
            return cell
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PronunciationCell", for: indexPath) as! PronunciationCVCell
            return cell
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PitchCell", for: indexPath) as! PitchCVCell
            let userPitch = pitch
            cell.updatePitch(with: userPitch)
            return cell
        case 8:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OriginalityCell", for: indexPath) as! OriginalityCVCell
            let userOriginality = originality//[indexPath.item]
            cell.updateOriginality(with: userOriginality)
            return cell
        
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3: // Filler Words cell
            
            performSegue(withIdentifier: "toFillerDetails", sender: nil)
        case 4: // Missing Words cell
            performSegue(withIdentifier: "toMissingWordDetails", sender: nil)
        default:
            break
        }
    }
    }
