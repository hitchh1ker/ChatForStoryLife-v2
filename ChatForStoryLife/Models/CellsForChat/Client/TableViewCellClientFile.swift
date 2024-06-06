import UIKit

class TableViewCellClientFile: UITableViewCell {
    
    @IBOutlet weak var nameFile: UILabel!
    @IBOutlet weak var timestampClient: UILabel!
    
    private var loadFile: LoadFile?
    private var fileURL: String = ""
    
    private var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setFileMessage(m: GetMessage, a: GetAttachment, viewController: UIViewController) {
        nameFile.text = a.name
        timestampClient.text = formatMessageTime(m.created)
        self.viewController = viewController
        fileURL = a.url
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        
        if let parentVC = parentViewController {
            loadFile = LoadFile(viewController: parentVC)
            loadFile?.downloadAndSaveFile(fileURL: fileURL)
        } else {
            print("Родительский контроллер пуст")
        }
        
        
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
