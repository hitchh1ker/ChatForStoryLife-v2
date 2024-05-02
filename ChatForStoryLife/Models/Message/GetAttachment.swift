import Foundation

public class GetAttachment : Codable {
    public var url: String
    public var name: String
    public var type: String
    
    init(url: String, name: String, type: String) {
        self.url = url
        self.name = name
        self.type = type
    }
}
