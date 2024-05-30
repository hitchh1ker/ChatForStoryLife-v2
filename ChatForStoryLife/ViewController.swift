import UIKit
import Starscream

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textMessage: UITextField!
    
    private var device: String = "testAuthDevice3"
    private var messages: [GetMessage] = []
    private var attachmentsForPost: [PostAttachment] = []
    private var socket: WebSocket!
    private let refreshControl = UIRefreshControl()
    private var count: Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        setupNavBar()
        setupTableView()
        connectWebSocket()
        fetchMessages()
    }
    
    func connectWebSocket() {
        let url = URL(string: "wss://dev.andalex.biz/sklad/api/support/chat")!
        var request = URLRequest(url: url)
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
        request.timeoutInterval = 5
        socket = WebSocket(request: request, certPinner: FoundationSecurity(), compressionHandler: nil)
        socket.delegate = self
        socket.connect()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: tableView.bounds.height, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "TableViewCellClient", bundle: nil), forCellReuseIdentifier: "TableViewCellClient")
        tableView.register(UINib(nibName: "TableViewCellClientImage", bundle: nil), forCellReuseIdentifier: "TableViewCellClientImage")
        tableView.register(UINib(nibName: "TableViewCellClientFile", bundle: nil), forCellReuseIdentifier: "TableViewCellClientFile")
        tableView.register(UINib(nibName: "TableViewCellOperator", bundle: nil), forCellReuseIdentifier: "TableViewCellOperator")
        tableView.register(UINib(nibName: "TableViewCellOperatorFile", bundle: nil), forCellReuseIdentifier: "TableViewCellOperatorFile")
        tableView.register(UINib(nibName: "TableViewCellOperatorImage", bundle: nil), forCellReuseIdentifier: "TableViewCellOperatorImage")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 58/255.0, green: 38/255.0, blue: 143/255.0, alpha: 1.0)
        
        navigationItem.title = "Помощь"
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titlePositionAdjustment = UIOffset(horizontal: -100, vertical: 0)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func reload() {
        refreshControl.beginRefreshing()
        count += count + 15
        fetchMessages()
        refreshControl.endRefreshing()
    }
    
    private func fetchMessages() {
        let url = URL(string: "https://dev.andalex.biz/sklad/api/support/message?Page=1&Count=\(count)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, error: error)
        }.resume()
    }
    
    private func handleResponse(data: Data?, error: Error?) {
        guard let data = data else {
            print("Ответ сервера пуст")
            return
        }
        do {
            let messageArray = try JSONDecoder().decode([GetMessage].self, from: data)
            self.updateMessages(with: messageArray)
        } catch {
            print("Ошибка JSON:", error)
        }
    }
    private func updateMessages(with messageArray: [GetMessage]) {
        self.messages = messageArray.map { message in
            let attachments = message.attachments?.map { attachment in
                return GetAttachment(url: attachment.url, name: attachment.name, type: attachment.type)
            } ?? []
            return GetMessage(content: message.content, sender: message.sender, created: message.created, attachments: attachments)
        }
        
        DispatchQueue.main.async {
            self.messages.reverse()
            self.tableView.reloadData()
        }
    }
    
    private func scrollToBottom() {
        if !self.messages.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.sender == "CLIENT" {
            if message.attachments?.isEmpty ?? true {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClient", for: indexPath) as? TableViewCellClient else {
                    fatalError("Ошибка с ячейкой TableViewCellClient")
                }
                cell.setClientMessage(m: message)
                return cell
            } else {
                if message.attachments?.first?.type == "I" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClientImage", for: indexPath) as? TableViewCellClientImage else {
                        fatalError("Ошибка с ячейкой TableViewCellClientImage")
                    }
                    cell.setImageMessage(m: message, a: message.attachments!.first!)
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClientFile", for: indexPath) as? TableViewCellClientFile else {
                        fatalError("Ошибка с ячейкой TableViewCellClientFile")
                    }
                    cell.setFileMessage(m: message, a: message.attachments!.first!, viewController: self)
                    cell.selectionStyle = .blue
                    return cell
                }
            }
        } else {
            if message.attachments?.isEmpty ?? true {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellOperator", for: indexPath) as? TableViewCellOperator else {
                    fatalError("Ошибка с ячейкой TableViewCellOperator")
                }
                cell.setOperatorMessage(m: message)
                return cell
            } else {
                if message.attachments?.first?.type == "I" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellOperatorImage", for: indexPath) as? TableViewCellOperatorImage else {
                        fatalError("Ошибка с ячейкой TableViewCellOperatorImage")
                    }
                    cell.setImageMessage(m: message, a: message.attachments!.first!)
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellOperatorFile", for: indexPath) as? TableViewCellOperatorFile else {
                        fatalError("Ошибка с ячейкой TableViewCellOperatorFile")
                    }
                    cell.setFileMessage(m: message, a: message.attachments!.first!)
                    return cell
                }
            }
        }
    }
    func alert(Title: String, Message: String) {
        let alertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addAttachment(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            if urls.count > 5 {
                self.alert(Title: "Максимум 5 файлов", Message: "Максимальное количество файлов для отправки: 5")
                return
            }
            
            let fileName = url.lastPathComponent
            let fileExtension = url.pathExtension
            let type = checkType(ext: fileExtension)
            if type == "U" {
                self.alert(Title: "Файл не поддерживается", Message: "Выбранный файл не поддерживается")
                return
            }
            
            if let fileData = try? Data(contentsOf: url) {
                let base64String = fileData.base64EncodedString()
                let attachment = PostAttachment(name: fileName, type: type, data: base64String)
                attachmentsForPost.append(attachment)
            }
        }
    }
    
    func checkType(ext: String) -> String {
        switch ext {
        case "jpg", "png", "jpeg":
            return "I"
        case "doc", "docx", "pdf", "txt":
            return "D"
        default:
            return "U"
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let messageText = textMessage.text, !messageText.isEmpty {
            sendMessage(text: messageText, attachments: [])
        }
        
        if textMessage.text!.isEmpty && !attachmentsForPost.isEmpty {
            sendAttachments()
        }
    }
    
    private func sendMessage(text: String, attachments: [PostAttachment]) {
        let messagePOST = PostMessage(message: text, supportinfo: "", attachments: attachments)
        do {
            let jsonData = try JSONEncoder().encode(messagePOST)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                socket.write(string: jsonString)
                textMessage.text = ""
            }
        } catch {
            print("Ошибка при кодировании сообщения:", error)
        }
    }
    
    private func sendAttachments() {
        for attachment in attachmentsForPost {
            sendMessage(text: "", attachments: [attachment])
        }
        attachmentsForPost = []
    }
    
    private func handleIncomingMessage(_ string: String) {
        guard let jsonData = string.data(using: .utf8) else {
            print("Ошибка преобразования данных в формат JSON")
            return
        }
        if let response = try? JSONDecoder().decode(GetMessageSocket.self, from: jsonData) {
            let sender = "CLIENT"
            let messageContent = response.data.message
            let attachments = response.data.attachments?.map { attachment in
                return GetAttachment(url: attachment.url, name: attachment.name, type: attachment.type)
            } ?? []
            
            let currentDate = Int(Date().timeIntervalSince1970)
            
            let newMessage = GetMessage(content: messageContent, sender: sender, created: currentDate, attachments: attachments)
            messages.append(newMessage)
        }
        else if let responseOperator = try? JSONDecoder().decode(GetOperatorMessageSocket.self, from: jsonData) {
            let sender = "OPERATOR"
            let messageContent = responseOperator.message
            let attachments: [GetAttachment] = []
            
            let currentDate = Int(Date().timeIntervalSince1970)
            
            let newMessage = GetMessage(content: messageContent, sender: sender, created: currentDate, attachments: attachments)
            messages.append(newMessage)
        } else {
            print("Ошибка при обработке входящего сообщения: данные не соответствуют ожидаемому формату")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
        
    }
}
extension ViewController: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket подключён:", headers)
        case .disconnected(let reason, let code):
            print("WebSocket отключён:", reason, code)
        case .text(let string):
            print("Полученные данные::", string)
            handleIncomingMessage(string)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            print("Ошибка WebSocket:", error as Any)
            break
        case .binary(_):
            break
        case .peerClosed:
            print("WebSocket закрыл подключение:")
        }
    }
}
