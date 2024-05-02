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
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
