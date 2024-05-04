import UIKit

class TableViewCellOperatorImage: UITableViewCell {
    

    @IBOutlet weak var ImageAttachment: UIImageView!
    
    @IBOutlet weak var timestampOper: UILabel!
    public func setImageMessage(m: GetMessage, a: GetAttachment) {
        loadImage(from: a.url) { image in
            DispatchQueue.main.async {
                self.ImageAttachment.image = image
            }
        }
        self.timestampOper.text = formatMessageTime(m.created)
    }
}
