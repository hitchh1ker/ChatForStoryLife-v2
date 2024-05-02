import UIKit
import Starscream

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate, UIDocumentPickerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessage: UITextField!
    
    private var device: String = "testAuthDevice3"
    
    private var messages: [GetMessage] = []
    
    private var attachmentsForSend: [PostAttachment] = []
    
    private var socket: WebSocket!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload),for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    @objc private func reload() {
        refreshControl.beginRefreshing()
        let url = URL(string: "https://dev.andalex.biz/sklad/api/support/message?Page=1&Count=15")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                print("Ошибка сервера:", error)
                return
            }
            guard let data = data else {
                print("Ответ сервера пуст")
                return
            }
            do {
                let messageArray = try JSONDecoder().decode([GetMessage].self, from: data)
                self.messages.removeAll()
                for message in messageArray {
                    let content = message.content
                    let sender = message.sender
                    let created = message.created
                    var attachments: [GetAttachment] = []
                    
                    if let messageAttachments = message.attachments {
                        for attachment in messageAttachments {
                            let url = attachment.url
                            let type = attachment.type
                            let name = attachment.name
                            let attachment = GetAttachment(url: url, name: name, type: type)
                            attachments.append(attachment)
                        }
                    }
                    
                    let newMessage = GetMessage(content: content, sender: sender, created: created, attachments: attachments)
                    self.messages.append(newMessage)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !self.messages.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            } catch {
                print("Ошибка JSON:", error)
            }
        }.resume()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavBar()
        setupTableView()
        connectWebSocket()
        
        self.tableView.addSubview(refreshControl)
        reload()
        
    }
    func connectWebSocket(){
        let url = URL(string: "wss://dev.andalex.biz/sklad/api/support/chat")!
        var request = URLRequest(url: url)
        request.addValue(device, forHTTPHeaderField: "Device-Uid")
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
        
        tableView.register(UINib(nibName: "TableViewCellClient", bundle: nil), forCellReuseIdentifier: "TableViewCellClient")
        tableView.register(UINib(nibName: "TableViewCellClientImage", bundle: nil), forCellReuseIdentifier: "TableViewCellClientImage")
        tableView.register(UINib(nibName: "TableViewCellClientFile", bundle: nil), forCellReuseIdentifier: "TableViewCellClientFile")
        tableView.register(UINib(nibName: "TableViewCellOperator", bundle: nil), forCellReuseIdentifier: "TableViewCellOperator")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages.reversed()[indexPath.row]
        if message.sender == "CLIENT" {
            
            if message.attachments!.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClient", for: indexPath) as? TableViewCellClient else {
                    fatalError("Ошибка с ячейкой TableViewCellClient")
                }
                cell.setClientMessage(m: message)
                return cell
            } else {
                if message.attachments![0].type == "I" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClientImage", for: indexPath) as? TableViewCellClientImage else {
                        fatalError("Ошибка с ячейкой TableViewCellClientImage")
                    }
                    cell.setImageMessage(m: message, a: message.attachments![0])
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellClientFile", for: indexPath) as? TableViewCellClientFile else {
                        fatalError("Ошибка с ячейкой TableViewCellClientFile")
                    }
                    cell.setFileMessage(m: message, a: message.attachments![0])
                    cell.selectionStyle = .blue
                    return cell
                }
            }
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellOperator", for: indexPath) as? TableViewCellOperator else {
                fatalError("Ошибка с ячейкой TableViewCellOperator")
            }
            cell.setOperatorMessage(m: message)
            return cell
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket is connected:", headers)
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected:", reason, code)
        case .text(let string):
            print("Received text:", string)
            DispatchQueue.main.async {
                self.reload()
            }
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
            print("WebSocker закрыл подключение:")
        }
    }
    
    @IBAction func addAttachment(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        let attachmentName = url.lastPathComponent
        var attachmentType: String
        
        if url.pathExtension.lowercased() == "png" || url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
            attachmentType = "I"
        } else if url.pathExtension.lowercased() == "txt" || url.pathExtension.lowercased() == "docx" {
            attachmentType = "D"
        } else {
            print("Этот файл не поддерживается")
            return
        }
        guard let attachmentData = try? Data(contentsOf: url) else {
            print("Ошибка чтения данных")
            return
        }
        let data = attachmentData.base64EncodedString()
        let attachment = PostAttachment(name: attachmentName, type: attachmentType, data: data)
        attachmentsForSend.append(attachment)
    }
    @IBAction func sendMessage(_ sender: Any) {
        if let messageText = textMessage.text, !messageText.isEmpty {
            let messagePOST = PostMessage(message: messageText, supportinfo: "", attachments: [])
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
        if textMessage.text!.isEmpty && !attachmentsForSend.isEmpty {
            for attachment in attachmentsForSend {
                let messagePOST = PostMessage(message: "", supportinfo: "", attachments: [attachment])
                do {
                    let jsonData = try JSONEncoder().encode(messagePOST)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print(jsonString)
                        socket.write(string: jsonString)
                    } else {
                        print("Ошибка при кодировании вложения:", attachment)
                    }
                } catch {
                    print("Ошибка при кодировании сообщения с вложением:", error)
                }
            }
            attachmentsForSend = []
        }
    }
}
