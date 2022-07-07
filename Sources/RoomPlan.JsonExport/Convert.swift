import Foundation
import RoomPlan

fileprivate class GenericSurfaceModel : Encodable {
    let category: String
    let confidence: String
    
    init(_ category: String, _ confidence: String) {
        self.category = category
        self.confidence = confidence
    }
}

fileprivate struct RoomModel : Encodable {
    let surfaces: [GenericSurfaceModel]
}

fileprivate func toModel(_ confidence: CapturedRoom.Confidence) -> String {
    switch confidence {
    case .high: return "high"
    case .medium: return "medium"
    case .low: return "low"
    default: return "unknown"
    }
}

fileprivate func toModel(_ surface: CapturedRoom.Surface) -> GenericSurfaceModel {
    let confidence = toModel(surface.confidence)
    switch surface.category {
    case .door:
        return GenericSurfaceModel("door", confidence)
    case .opening:
        return GenericSurfaceModel("opening", confidence)
    case .wall:
        return GenericSurfaceModel("wall", confidence)
    case .window:
        return GenericSurfaceModel("window", confidence)
    default:
        return GenericSurfaceModel("unknown", confidence)
    }
}

fileprivate func toModel(_ room: CapturedRoom) -> RoomModel {
    let allSurfaces = room.walls + room.doors + room.openings + room.windows
    return RoomModel(surfaces: allSurfaces.map(toModel))
}


extension CapturedRoom {
    
    func encodeToJson() -> Data? {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let model = toModel(self)
        
        return try? encoder.encode(model)
    }
    
}
