import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {

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

            // 복제 루프가 사라졌습니다. 몇 마리를 어디에 놓을지는 이제
            // RCP의 SpawnPoint 마커가 정하고, SpawnPointSystem이 실행합니다.
            // 이 뷰가 하는 일은 씬을 불러오는 것뿐입니다.
        }
        .modifier(SimulatorCameraControls())
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // 복제본에는 비헤이비어가 따라오지 않습니다. RCP의 비헤이비어는
                    // `</Root/Seahorse>` 같은 **경로**로 대상을 잡는데, 복제본은
                    // 그 경로에 없기 때문입니다. 복제본을 탭하면
                    // applyTapForBehaviors()가 false를 돌려주고 아무 일도 안 납니다.
                    //
                    // 그때는 원본에게 탭을 대신 넘깁니다. 타임라인이 쏘는
                    // Notification은 어차피 씬 전체에 뿌려지므로 결과는 같습니다.
                    if value.entity.applyTapForBehaviors() == false,
                       let prototype = value.entity.scene?.findEntity(named: "Seahorse") {
                        _ = prototype.applyTapForBehaviors()
                    }
                }
        )
        .onReceive(notificationTrigger) { output in
            // 주의: `SourceEntity`는 **타임라인을 재생한 엔티티**이지,
            // Notification 액션에서 지정한 Target이 아닙니다. RCP가 비헤이비어의
            // 대상을 `/Root`로 잡기 때문에 우리 씬에서는 항상 `Root`가 옵니다.
            // 그래서 여기서는 씬만 꺼내 쓰고, 실제 대상은 씬에서 다시 찾습니다.
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
