import Foundation
import RoomPlan

extension CapturedRoom {

    fileprivate func toJson() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }
    
    public func exportJson(to url: URL) throws {
        if let json = self.toJson() {
            try json.write(to: url)
        }
    }
    
}
