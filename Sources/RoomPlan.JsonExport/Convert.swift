import Foundation
import RoomPlan

fileprivate class GenericSurfaceModel : Encodable {
    let category: String
    let id: String
    let confidence: String
    
    init(_ category: String, _ id: String, _ confidence: String) {
        self.category = category
        self.id = id
        self.confidence = confidence
    }
}

fileprivate struct RoomModel : Encodable {
    let surfaces: [GenericSurfaceModel]
}

fileprivate func toModel (_ uuid: UUID) -> String {
    uuid.uuidString
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
    let id = toModel(surface.identifier)
    let confidence = toModel(surface.confidence)
    switch surface.category {
    case .door:
        return GenericSurfaceModel("door", id, confidence)
    case .opening:
        return GenericSurfaceModel("opening", id, confidence)
    case .wall:
        return GenericSurfaceModel("wall", id, confidence)
    case .window:
        return GenericSurfaceModel("window", id, confidence)
    default:
        return GenericSurfaceModel("unknown", id, confidence)
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
