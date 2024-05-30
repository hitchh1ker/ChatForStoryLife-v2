import UIKit
import MobileCoreServices

class LoadFile: NSObject {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func downloadAndSaveFile(fileURL: String) {
        guard let url = URL(string: fileURL) else {
            print("Ошибка в URL: \(fileURL)")
            return
        }
        
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location else {
                if let error = error {
                    print("Ошибка скачивания: \(error)")
                } else {
                    print("Локация скачивания пуста")
                }
                return
            }
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [location])
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = .fullScreen
                self.viewController?.present(documentPicker, animated: true, completion: nil)
            }
        }.resume()
    }
}

extension LoadFile: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Документы выбраны: \(urls)")
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Выбор отменен")
    }
}
