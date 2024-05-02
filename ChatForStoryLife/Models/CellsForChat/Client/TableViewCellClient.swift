import UIKit

class TableViewCellClient: UITableViewCell {
   //@IBOutlet weak var nameClient: UILabel!
   @IBOutlet weak var timestampClient: UILabel!
   @IBOutlet weak var textMessageClient: UILabel!
    
    public func setClientMessage(m: GetMessage) {
        //self.nameClient.text = m.sender
        self.textMessageClient.text = m.content
        self.timestampClient.text = formatMessageTime(m.created)
    }
}
