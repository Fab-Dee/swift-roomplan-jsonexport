import Foundation
import RoomPlan

fileprivate class GenericSurfaceModel : Encodable {
    let category: String
    
    
    init(category: String) {
        self.category = category
    }
}

fileprivate struct RoomModel : Encodable {
    let surfaces: [GenericSurfaceModel]
}

fileprivate func toModel(_ surface: CapturedRoom.Surface) -> GenericSurfaceModel {
    switch surface.category {
    case .door:
        return GenericSurfaceModel(category: "door")
    case .opening:
        return GenericSurfaceModel(category: "opening")
    case .wall:
        return GenericSurfaceModel(category: "wall")
    case .window:
        return GenericSurfaceModel(category: "window")
    default:
        return GenericSurfaceModel(category: "unknown")
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
