import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    // 화면이 유지되는 동안 같은 트래킹 세션을 사용하기 위해 @State로 저장합니다.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // 가상 카메라 대신 후면 카메라 영상을 배경으로 씁니다.
            content.camera = .spatialTracking

            // 진짜 사물이 해마를 가리는 occlusion과, shadow를 켭니다.
            // 기기가 지원하지 않는 기능은 조용히 빠지므로, 콘솔에 남겨 둡니다.
            if let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            ) {
                print("지원되지 않는 기능:", unavailable.sceneUnderstanding)
            }

            do {
                let scene = try await Entity(named: "Scene",
                                             in: aquariumContentBundle)
                content.add(scene)
            } catch {
                // 이름이 틀렸거나 번들을 못 찾으면 여기로 옵니다.
                print("Scene 로드 실패:", error)
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
    }
}

#Preview {
    AquariumView()
}
