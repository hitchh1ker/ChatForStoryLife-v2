import UIKit

class StartController: UIViewController {
    
    private var device: String = "testAuthDevice3"
    
    private var countUnread: Int = 0
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        getUnreadCount()
    }
    
    private func getUnreadCount() {
        let url = URL(string: Consts.urlGetUnreadMessage)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка сервера:", error)
                return
            }
            
            guard let data = data else {
                print("Ответ сервера пуст")
                return
            }
            
            do {
                let dataCount = try JSONDecoder().decode(UnreadCountResponse.self, from: data)
                self.countUnread = dataCount.count
                
                DispatchQueue.main.async {
                    if self.countUnread == 0 {
                        self.countLabel.isHidden = true
                    } else {
                        self.countLabel.isHidden = false
                        self.countLabel.text = "\(self.countUnread)"
                    }
                }
            } catch {
                print("Ошибка JSON:", error)
            }
        }.resume()
    }
    
    func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 58/255.0, green: 38/255.0, blue: 143/255.0, alpha: 1.0)
        
        navigationItem.title = "Меню"
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titlePositionAdjustment = UIOffset(horizontal: -100, vertical: 0)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @IBAction func showChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatController") as! ViewController
        present(vc, animated:  true)
        
        
        let url = URL(string: Consts.urlReadMessage)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
        
        URLSession.shared.dataTask(with: request).resume()
        getUnreadCount()
    }
}
