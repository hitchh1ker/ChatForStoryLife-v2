import Foundation
import UIKit

public class PostAttachment : Codable {
    public var name: String
    public var type: String
    public var data: String
    
    init(name: String, type: String, data: String) {
        self.name = name
        self.type = type
        self.data = data
    }
}
