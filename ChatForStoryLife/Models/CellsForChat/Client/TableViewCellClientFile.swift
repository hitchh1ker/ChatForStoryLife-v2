import UIKit

class TableViewCellClientFile: UITableViewCell {
    
    @IBOutlet weak var nameFile: UILabel!
    
    @IBOutlet weak var timestampClient: UILabel!
    
    private var fileURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(downloadFile))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func downloadFile() {
        guard let fileURLString = fileURL, let fileURL = URL(string: fileURLString) else {
            print("Ошибка в ссылке URL")
            return
        }
        URLSession.shared.downloadTask(with: fileURL) { (location, response, error) in
            guard let location = location else {
                if let error = error {
                    print("Ошибка при скачивании файла: \(error)")
                } else {
                    print("Ошибка при скачивании файла")
                }
                return
            }
            
            guard let projectDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to access project directory")
                return
            }

            let downloadsDirectory = projectDirectory.appendingPathComponent("Downloads")

            do {
                try FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create downloads directory:", error)
                return
            }

            let destinationURL = downloadsDirectory.appendingPathComponent(fileURL.lastPathComponent)
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                print("Файл успешно скачан по пути: \(destinationURL)")
                
            } catch {
                print("Ошибка при сохранении файла: \(error)")
            }
        }.resume()
    }
    
    func setFileMessage(m: GetMessage, a: GetAttachment){
        nameFile.text = a.name
        timestampClient.text = formatMessageTime(m.created)
        fileURL = a.url
    }
}
