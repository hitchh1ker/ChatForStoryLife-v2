import UIKit

class TableViewChat: UITableView, UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableViewCellClient(style: .default, reuseIdentifier: "cell")
        cell.messageClient.text = "I client"
        return cell
    }
    
    func viewDidLoad() {
            
            self.rowHeight = UITableView.automaticDimension
            self.estimatedRowHeight = 44.0
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.delegate = self
            self.dataSource = self
        
        }
}
