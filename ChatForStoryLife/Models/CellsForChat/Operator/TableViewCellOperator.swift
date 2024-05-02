import UIKit

class TableViewCellOperator: UITableViewCell {

    //@IBOutlet weak var nameOperator: UILabel!
    @IBOutlet weak var textMessageOperator: UILabel!
    @IBOutlet weak var timestampOperator: UILabel!
    
    public func setOperatorMessage(m: GetMessage) {
        //self.nameOperator.text = m.sender
        self.textMessageOperator.text = m.content
        self.timestampOperator.text = formatMessageTime(m.created)
    }
}
