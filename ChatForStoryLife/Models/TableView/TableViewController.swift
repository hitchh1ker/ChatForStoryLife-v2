//
//  UITableView.swift
//  ChatForStoryLife
//
//  Created by Максим Шамов on 09.04.2024.
//

import UIKit;

class UITableViewController: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    func viewDidLoad() {
            
            self.rowHeight = UITableView.automaticDimension
            self.estimatedRowHeight = 44.0
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.delegate = self
            self.dataSource = self
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Вернуть количество строк в вашей таблице
            return 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Создать и настроить ячейку таблицы
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = "Your cell text"
            return cell
        }
}

