import RealityKit
import Foundation

/// 해마를 풀어놓을 자리. **RCP 인스펙터에 그대로 노출됩니다.**
///
/// 빈 Transform 엔티티에 이 컴포넌트를 붙이면, 그 자리가 해마 서식지가 됩니다.
public struct SpawnPointComponent: Component, Codable {

    /// 이 자리에 풀어놓을 해마 수.
    public var count: Int = 3

    /// 마커를 중심으로 이만큼 반경 안에 흩뿌립니다 (m).
    public var scatterRadius: Float = 0.2

    /// 복제해 올 원본 엔티티의 이름. 씬 안에서 이 이름으로 찾습니다.
    public var prototypeName: String = "Seahorse"

    public init() {
    }
}

/// "이 마커는 이미 처리했다"는 도장.
///
/// `update`는 매 프레임 불립니다. 이 도장이 없으면 프레임마다 복제해서
/// 순식간에 수천 마리가 됩니다. `Codable`이 아니라 RCP에는 보이지 않습니다.
public struct SpawnPointRuntimeComponent: Component {

    /// 실제로 몇 마리를 넣었는지. 디버깅용입니다.
    internal var spawnedCount: Int = 0

    public init() {
    }
}

/// `SpawnPointComponent`가 붙은 엔티티를 찾아 그 자리에 해마를 복제해 넣습니다.
///
/// 딱 한 번만 일하고 그 뒤로는 아무것도 안 하는 시스템입니다.
@MainActor
public class SpawnPointSystem: System {

    /// 아직 도장을 안 찍은 마커만 고릅니다.
    ///
    /// `QueryPredicate`는 `&&`, `||`, `!`로 조합됩니다. "A는 붙었고 B는 안 붙은"이
    /// ECS에서 가장 자주 쓰는 모양입니다.
    private static let pendingMarkers = EntityQuery(
        where: .has(SpawnPointComponent.self) && !.has(SpawnPointRuntimeComponent.self)
    )

    public required init(scene: Scene) {
    }

    public func update(context: SceneUpdateContext) {
        // 순회 도중에 엔티티를 추가하고 컴포넌트를 붙이므로,
        // 쿼리 결과를 먼저 배열로 떠 놓고 시작합니다.
        let markers = Array(context.entities(matching: Self.pendingMarkers,
                                             updatingSystemWhen: .rendering))
        guard !markers.isEmpty else { return }

        for marker in markers {
            var runtimeComponent = SpawnPointRuntimeComponent()
            runtimeComponent.spawnedCount = populate(marker: marker)

            // 성공했든 실패했든 도장은 찍습니다. 원본을 못 찾은 마커를
            // 매 프레임 다시 시도하며 콘솔을 채울 이유가 없습니다.
            marker.components.set(runtimeComponent)
        }
    }

    /// 마커 하나를 채우고, 실제로 넣은 마릿수를 돌려줍니다.
    private func populate(marker: Entity) -> Int {
        guard let settings = marker.components[SpawnPointComponent.self],
              settings.count > 0 else { return 0 }

        guard let prototype = marker.scene?.findEntity(named: settings.prototypeName) else {
            print("[SpawnPoint] '\(marker.name)': 원본 '\(settings.prototypeName)'을 찾지 못했습니다.")
            return 0
        }

        for index in 0..<settings.count {
            let seahorse = prototype.clone(recursive: true)
            seahorse.name = "\(settings.prototypeName)_\(marker.name)_\(index)"

            // clone은 컴포넌트를 전부 복사합니다. 원본은 이 시점에 이미 살아
            // 헤엄치고 있어서 진행 중인 런타임 컴포넌트까지 딸려옵니다.
            //
            // 사실 그냥 둬도 결과는 같습니다 — addChild 하는 순간 DidAdd가 돌고
            // SeahorseSystem이 새것으로 덮어쓰니까요. 그런데도 떼어내는 이유는
            // 아래 진단 때문입니다. 떼어내야만 "런타임 컴포넌트가 있다"가
            // "시스템이 실제로 돌았다"의 증거가 됩니다.
            seahorse.components.remove(SeahorseRuntimeComponent.self)

            // 위치를 **먼저** 정하고 나서 씬에 넣습니다. 순서가 중요합니다.
            // initialize가 entity.position.y를 읽어 기준 높이로 삼는데,
            // 그 초기화는 addChild 하는 순간 일어납니다.
            seahorse.position = Self.scatterOffset(radius: settings.scatterRadius)

            marker.addChild(seahorse)

            if seahorse.components[SeahorseRuntimeComponent.self] == nil {
                print("[SpawnPoint] '\(seahorse.name)'에 런타임 컴포넌트가 붙지 않았습니다.")
            }
        }

        return settings.count
    }

    /// 마커 주변에 흩뿌릴 상대 위치를 하나 뽑습니다.
    private static func scatterOffset(radius: Float) -> SIMD3<Float> {
        guard radius > 0 else { return .zero }

        // 원 안에 고르게 뿌리려면 반지름에 sqrt를 씌워야 합니다.
        // 그냥 random(0...radius)로 하면 가운데로 몰립니다.
        let angle = Float.random(in: 0..<(2 * .pi))
        let distance = radius * sqrt(Float.random(in: 0...1))

        return SIMD3<Float>(cos(angle) * distance,
                            Float.random(in: -radius...radius) * 0.5,
                            sin(angle) * distance)
    }
}
