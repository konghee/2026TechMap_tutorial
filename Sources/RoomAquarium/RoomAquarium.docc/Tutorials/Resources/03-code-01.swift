import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    // 화면이 유지되는 동안 같은 트래킹 세션을 사용하기 위해 @State로 저장합니다.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            do {
                let scene = try await Entity(named: "Scene",
                                             in: aquariumContentBundle)
                content.add(scene)
            } catch {
                // 이름이 틀렸거나 번들을 못 찾으면 여기로 옵니다.
                print("Scene 로드 실패:", error)
            }
        }
    }
}

#Preview {
    AquariumView()
}
