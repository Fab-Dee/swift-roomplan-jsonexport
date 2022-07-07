import Foundation
import RoomPlan

extension CapturedRoom {

    public func exportJson(to url: URL) throws {
        if let json = self.encodeToJson() {
         try json.write(to: url)
        }
    }
    
}
