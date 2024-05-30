import UIKit

class TableViewCellOperatorFile: UITableViewCell {
    
    @IBOutlet weak var nameFile: UILabel!
    
    @IBOutlet weak var timestampOper: UILabel!
    
    private var fileURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setFileMessage(m: GetMessage, a: GetAttachment){
        nameFile.text = a.name
        timestampOper.text = formatMessageTime(m.created)
        fileURL = a.url
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        print("test")
    }
    
}
