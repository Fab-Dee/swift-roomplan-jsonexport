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

fileprivate func makeDoor() -> GenericSurfaceModel {
    GenericSurfaceModel(category: "door")
}

fileprivate func makeOpening() -> GenericSurfaceModel {
    GenericSurfaceModel(category: "opening")
}

fileprivate func makeWall() -> GenericSurfaceModel {
    GenericSurfaceModel(category: "wall")
}

fileprivate func makeWindow() -> GenericSurfaceModel {
    GenericSurfaceModel(category: "window")
}

fileprivate func makeUnknownSurface() -> GenericSurfaceModel {
    GenericSurfaceModel(category: "unknown")
}

fileprivate func toModel(_ surface: CapturedRoom.Surface) -> GenericSurfaceModel {
    switch surface.category {
    case .door: return makeDoor()
    case .opening: return makeDoor()
    case .wall: return makeWall()
    case .window: return makeWindow()
    default: return makeUnknownSurface()
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
