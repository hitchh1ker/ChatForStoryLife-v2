import UIKit

class TableViewCellClientImage: UITableViewCell {
    
    @IBOutlet weak var imageAttachement: UIImageView!
    @IBOutlet weak var timestampClient: UILabel!
    
    public func setImageMessage(m: GetMessage, a: GetAttachment) {
        loadImage(from: a.url) { image in
            DispatchQueue.main.async {
                self.imageAttachement.image = image
            }
        }
        self.timestampClient.text = formatMessageTime(m.created)
    }
}
