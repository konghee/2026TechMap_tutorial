# ``RoomAquarium``

RealityKit과 Reality Composer Pro로 아이패드 방 안에 아쿠아리움을 만드는
튜토리얼입니다.

## Overview

RealityKit을 처음 접하는 사람을 위한 4개 챕터짜리 실습 튜토리얼입니다.
Reality Composer Pro로 3D 씬을 조립하는 것에서 시작해, SwiftUI의
`RealityView`로 불러오고, 카메라 패스스루로 실제 방에 배치하고,
마지막에는 커스텀 컴포넌트와 System으로 해마 떼가 헤엄쳐 다니게 만듭니다.

전체를 관통하는 주제는 **RCP와 코드의 경계**입니다. WWDC24 세션
[Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)와
그 공식 샘플이 보여주는 구조를 그대로 따릅니다.

- 모양·배치·연출과 그 타이밍은 **RCP**가 저작합니다.
- 여러 개를 관리하고 매 프레임 상태를 굴리는 일은 **코드**가 맡습니다.
- 둘은 비헤이비어(코드 → RCP)와 알림(RCP → 코드) 두 방향으로 대화합니다.

Chapter 1~2는 시뮬레이터만으로 완주할 수 있고, Chapter 3의 카메라
패스스루부터 실기기(iPad)가 필요합니다.

- 요구 환경: Xcode 26 기준 작성 · 배포 대상 iOS/iPadOS 18 이상
- 완성 프로젝트와 에셋: [konghee/SpatialComputing](https://github.com/konghee/SpatialComputing)

## Topics

### 튜토리얼

- <doc:/tutorials/RoomAquarium>
