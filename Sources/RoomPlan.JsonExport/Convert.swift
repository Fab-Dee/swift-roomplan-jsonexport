import Foundation
import RoomPlan
import simd

fileprivate struct V3Model : Encodable {
    let x: Float
    let y: Float
    let z: Float
}

fileprivate typealias MatrixModel = [Float]

fileprivate struct CurveModel : Encodable {
    let startAngle: Double
    let endAngle: Double
    let radius: Float
}

fileprivate typealias EdgesModel = [Bool]

fileprivate class GenericSurfaceModel : Encodable {
    let category: String
    let id: String
    let confidence: String
    let scale: V3Model
    let transform: MatrixModel
    let curve: CurveModel?
    let edges: EdgesModel
    
    init(_ category: String, _ id: String, _ confidence: String,
         _ scale: V3Model, _ transform: MatrixModel, _ curve: CurveModel?,
         _ edges: EdgesModel) {
        self.category = category
        self.id = id
        self.confidence = confidence
        self.scale = scale
        self.transform = transform
        self.curve = curve
        self.edges = edges
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

fileprivate func toModel (_ matrix: simd_float4x4) -> MatrixModel {
    let (c1, c2, c3, c4) = matrix.columns
    return [
        c1.x, c1.y, c1.z, c1.w,
        c2.x, c2.y, c2.z, c2.w,
        c3.x, c3.y, c3.z, c3.w,
        c4.x, c4.y, c4.z, c4.w
    ]
}

fileprivate func toModel (_ curve: CapturedRoom.Surface.Curve) -> CurveModel {
    CurveModel(startAngle: curve.startAngle.value,
               endAngle: curve.endAngle.value,
               radius: curve.radius)
}

fileprivate func toModel (_ edges: Set<CapturedRoom.Surface.Edge>) -> EdgesModel {
    [
        edges.contains(.top),
        edges.contains(.right),
        edges.contains(.bottom),
        edges.contains(.left)
    ]
}

fileprivate func toModel(_ surface: CapturedRoom.Surface) -> GenericSurfaceModel {
    let id = toModel(surface.identifier)
    let confidence = toModel(surface.confidence)
    let scale = toModel(surface.dimensions)
    let transform = toModel(surface.transform)
    let curve = surface.curve != nil ? toModel(surface.curve!) : nil
    let edges = toModel(surface.completedEdges)
    
    func makeGeneric(of category: String) -> GenericSurfaceModel {
        GenericSurfaceModel(category, id, confidence, scale,
                            transform, curve, edges)
    }
    
    switch surface.category {
    case .door:
        return makeGeneric(of: "door")
    case .opening:
        return makeGeneric(of: "opening")
    case .wall:
        return makeGeneric(of: "wall")
    case .window:
        return makeGeneric(of: "window")
    default:
        return makeGeneric(of: "unknown")
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
