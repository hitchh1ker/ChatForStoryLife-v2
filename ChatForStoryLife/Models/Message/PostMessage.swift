import Foundation
import UIKit

public class PostMessage : Codable {
    
    public var message: String
    public var supportinfo: String
    public var attachments: [PostAttachment]
    
    init(message: String, supportinfo: String, attachments: [PostAttachment]) {
        self.message = message
        self.supportinfo = supportinfo
        self.attachments = attachments
    }
}
