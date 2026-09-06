import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {

    // 화면이 유지되는 동안 같은 트래킹 세션을 사용하기 위해 @State로 저장합니다.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Scene",
                                             in: aquariumContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview {
    AquariumView()
}
