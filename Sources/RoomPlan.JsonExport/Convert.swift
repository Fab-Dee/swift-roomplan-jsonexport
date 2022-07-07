import Foundation
import RoomPlan
import simd

fileprivate struct V3Model : Encodable {
    let x: Float
    let y: Float
    let z: Float
}

fileprivate class GenericSurfaceModel : Encodable {
    let category: String
    let id: String
    let confidence: String
    let scale: V3Model
    
    init(_ category: String, _ id: String, _ confidence: String, _ scale: V3Model) {
        self.category = category
        self.id = id
        self.confidence = confidence
        self.scale = scale
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

fileprivate func toModel (_ v3: simd_float3) -> V3Model {
    V3Model(x: v3.x, y: v3.y, z: v3.z)
}

fileprivate func toModel(_ surface: CapturedRoom.Surface) -> GenericSurfaceModel {
    let id = toModel(surface.identifier)
    let confidence = toModel(surface.confidence)
    let scale = toModel(surface.dimensions)
    
    switch surface.category {
    case .door:
        return GenericSurfaceModel("door", id, confidence, scale)
    case .opening:
        return GenericSurfaceModel("opening", id, confidence, scale)
    case .wall:
        return GenericSurfaceModel("wall", id, confidence, scale)
    case .window:
        return GenericSurfaceModel("window", id, confidence, scale)
    default:
        return GenericSurfaceModel("unknown", id, confidence, scale)
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
