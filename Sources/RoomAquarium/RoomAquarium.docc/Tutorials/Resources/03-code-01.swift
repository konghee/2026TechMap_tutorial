import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    // 뷰가 세션을 들고 있어야 화면이 떠 있는 동안 트래킹이 유지됩니다.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // 가상 카메라 대신 후면 카메라 영상을 배경으로 씁니다(패스스루).
            content.camera = .spatialTracking

            // 진짜 사물이 해마를 가리는 오클루전과, 바닥에 지는 그림자를 켭니다.
            // 씬 재구성이 되는 LiDAR 기기에서만 실제로 켜집니다.
            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )
            if let unavailable {
                print("이 기기에서 쓸 수 없는 기능: \(unavailable.sceneUnderstanding)")
            }

            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview {
    AquariumView()
}
