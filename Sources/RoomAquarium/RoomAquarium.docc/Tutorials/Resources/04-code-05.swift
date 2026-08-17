import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    private static let seahorseCount = 8

    @State private var trackingSession = SpatialTrackingSession()

    private let notificationTrigger = NotificationCenter.default
        .publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

    var body: some View {
        RealityView { content in
            #if !targetEnvironment(simulator)
            content.camera = .spatialTracking

            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )
            if let unavailable {
                print("이 기기에서 쓸 수 없는 기능: \(unavailable.sceneUnderstanding)")
            }
            #endif

            guard let scene = try? await Entity(named: "Scene",
                                                in: realityKitContentBundle) else { return }
            content.add(scene)

            if let template = scene.findEntity(named: "Seahorse") {
                let parent = template.parent
                template.removeFromParent()

                for _ in 0..<Self.seahorseCount {
                    let seahorse = template.clone(recursive: true)
                    seahorse.position = Self.scatter()
                    parent?.addChild(seahorse)
                    // 여기서 끝입니다. SeahorseComponent가 복제본에 딸려 왔고,
                    // 씬에 추가되는 순간 SeahorseSystem이 DidAdd를 받아
                    // 런타임 컴포넌트를 알아서 만들어 줍니다.
                    // "각자 다른 성격을 뽑아라"는 문장이 이 뷰에는 없습니다.
                }
            }
        }
        .modifier(SimulatorCameraControls())
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
        .onReceive(notificationTrigger) { output in
            // 주의: `SourceEntity`는 **타임라인을 재생한 엔티티**이지,
            // Notification 액션에서 지정한 Target이 아닙니다. RCP가 비헤이비어의
            // 대상을 `/Root`로 잡기 때문에 우리 씬에서는 항상 `Root`가 옵니다.
            // 그래서 여기서는 씬만 꺼내 쓰고, 실제 대상은 씬에서 다시 찾습니다.
            // 애플 공식 샘플도 똑같이 합니다.
            guard let sourceEntity = output.userInfo?["RealityKit.NotificationTrigger.SourceEntity"] as? Entity,
                  let name = output.userInfo?["RealityKit.NotificationTrigger.Identifier"] as? String
            else { return }

            switch name {
            case "SeahorseStartled":
                setStateOnAllSeahorses(in: sourceEntity.scene, newState: .startled)
            case "SeahorseCalmed":
                setStateOnAllSeahorses(in: sourceEntity.scene, newState: .idle)
            default:
                break
            }
        }
    }

    /// 원점을 중심으로 한 도넛(안쪽은 비움) 위의 임의 지점을 고릅니다.
    private static func scatter() -> SIMD3<Float> {
        let radius = Float.random(in: 0.3...0.8)
        let angle = Float.random(in: 0..<(2 * .pi))
        return [radius * sin(angle), Float.random(in: -0.2...0.5), radius * cos(angle)]
    }
}

/// 씬 안의 모든 해마에게 새 상태를 전달합니다.
///
/// 알림이 개별 해마가 아니라 씬 루트에서 오기 때문에, 탭 한 번에 주변 해마가
/// 다 같이 놀라는 모양이 됩니다. 무리가 함께 반응하는 편이 보기에도 자연스럽습니다.
@MainActor
private func setStateOnAllSeahorses(in scene: RealityKit.Scene?, newState: SeahorseState) {
    guard let scene else { return }

    for seahorse in scene.performQuery(EntityQuery(where: .has(SeahorseRuntimeComponent.self))) {
        seahorse.components[SeahorseRuntimeComponent.self]?.setState(newState: newState)
    }
}

private struct SimulatorCameraControls: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(simulator)
        content.realityViewCameraControls(.orbit)
        #else
        content
        #endif
    }
}

#Preview {
    AquariumView()
}
