import UIKit

class TableViewCellClient: UITableViewCell {

   @IBOutlet weak var timestampClient: UILabel!
   @IBOutlet weak var textMessageClient: UILabel!
    
    public func setClientMessage(m: GetMessage) {

        self.textMessageClient.text = m.content
        self.timestampClient.text = formatMessageTime(m.created)
    }
}
