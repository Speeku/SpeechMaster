import UIKit

class reportScreenVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
    }
    func createLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                
                
                
                // Define the items and groups for each section
                switch sectionIndex {
                case 0: return self.createVideoCellSection()
                case 1: return self.createSummaryCellSection()
                case 2: return self.createFillersCellSection()
                case 3: return self.createMissingWordsCellSection() 
                case 4: return self.createPaceCellSection()
                case 5: return self.createPronunciationCellSection()
                case 6: return self.createPitchCellSection()
                case 7: return self.createOriginalityCellSection()
                default: return nil
                }
            }
        }
    
}






extension reportScreenVC : UICollectionViewDataSource {
    
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
                                                  heightDimension: .absolute(120)) // Adjust height for labels
       
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
    
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 8
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCVCell
            let userVideo = video[indexPath.item]
            cell.updateVideo(with: userVideo)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCell", for: indexPath) as! SummaryCVCell
            let userSummary = summary[indexPath.item]
            cell.updateSummary(with: userSummary)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FillerCell", for: indexPath) as! FillersCVCell
            let userFillers = fillers[indexPath.item]
            cell.updateFillers(with: userFillers)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MissingWordCell", for: indexPath) as! MissingWordsCVCell
            let userMissingWords = missingWords[indexPath.item]
            cell.updateMissingWords(with: userMissingWords)
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaceCell", for: indexPath) as! PaceCVCell
            let userPace = pace[indexPath.item]
            cell.updatePace(with: userPace)
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PronunciationCell", for: indexPath) as! PronunciationCVCell
            return cell
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PitchCell", for: indexPath) as! PitchCVCell
            let userPitch = pitch[indexPath.item]
            cell.updatePitch(with: userPitch)
            return cell
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OriginalityCell", for: indexPath) as! OriginalityCVCell
            let userOriginality = originality[indexPath.item]
            cell.updateOriginality(with: userOriginality)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    
}
