import Foundation
import UIKit

struct MessageDataSocket : Decodable {
    
    let message: String
    let attachments: [GetAttachment]?
    
}
