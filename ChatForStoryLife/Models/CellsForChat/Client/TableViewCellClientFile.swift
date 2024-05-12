import UIKit

class TableViewCellClientFile: UITableViewCell {
    
    @IBOutlet weak var nameFile: UILabel!
    
    @IBOutlet weak var timestampClient: UILabel!
    
    private var fileURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setFileMessage(m: GetMessage, a: GetAttachment){
        nameFile.text = a.name
        timestampClient.text = formatMessageTime(m.created)
        fileURL = a.url
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        downloadFile(fileURL: fileURL)
    }
}
