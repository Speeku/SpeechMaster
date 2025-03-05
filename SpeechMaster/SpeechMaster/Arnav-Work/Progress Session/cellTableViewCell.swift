

import UIKit

class cellTableViewCell: UITableViewCell {

    // cell outlets
    
    @IBOutlet weak var titleName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    var topicName : String?
    var dateName : String?
    func setup(){
        titleName.text = topicName ??  "No Name"
        date.text = dateName ?? Date().description
    }
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
