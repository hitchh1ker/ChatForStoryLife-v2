import UIKit

struct GetOperatorMessageSocket : Decodable {
    
    let message: String
    let result: String
    let time: Int
    let attachments: [GetAttachment]?
}
