import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    var body: some View {
        RealityView { content in
            // RCP에서 저장한 "Scene"을 불러옵니다.
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
