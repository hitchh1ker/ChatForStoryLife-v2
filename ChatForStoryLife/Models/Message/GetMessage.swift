import Foundation
import UIKit

public class GetMessage : Codable {
    public var content: String
    public var sender: String
    public var created: Int
    public var attachments: [GetAttachment]?
    
    init(content: String, sender: String, created: Int, attachments: [GetAttachment]) {
        self.content = content
        self.sender = sender
        self.created = created
        self.attachments = attachments
    }
}
