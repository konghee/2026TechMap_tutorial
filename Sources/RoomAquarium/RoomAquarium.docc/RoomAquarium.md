# ``RoomAquarium``

RealityKit과 Reality Composer Pro로 아이패드 방 안에 아쿠아리움을 만드는
튜토리얼입니다.

## Overview

RealityKit을 처음 접하는 사람을 위한 3개 챕터짜리 실습 튜토리얼입니다.
Reality Composer Pro로 3D 씬을 조립하는 것에서 시작해, SwiftUI의
`RealityView`로 불러오고, 타임라인과 비헤이비어로 해마를 살아 움직이게 한 뒤,
마지막에는 카메라 패스스루로 실제 내 방에 띄우고 탭에 반응하게 만듭니다.

전체를 관통하는 주제는 **RCP와 코드의 경계**입니다. WWDC24 세션
[Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)와
그 공식 샘플이 보여주는 구조를 그대로 따릅니다.

- 모양·배치·움직임·소리, 그리고 그 타이밍은 **RCP**에서 만듭니다.
- 앱 화면에 띄우고, 카메라를 고르고, 사용자의 탭을 전달하는 일은 **코드**가 맡습니다.
- 코드가 탭을 넘기면(`applyTapForBehaviors()`) RCP에 만들어 둔 연출이 재생됩니다.
  그래서 연출을 바꿀 때 Xcode를 열 필요가 없습니다.

Chapter 1~2는 시뮬레이터만으로 완주할 수 있고, Chapter 3의 카메라
패스스루에서만 실기기(iPad)가 필요합니다.

- 요구 환경: Xcode 26 기준 작성 · 배포 대상 iOS/iPadOS 18 이상
- 에셋: 해마 모델은 [AR Quick Look Gallery](https://developer.apple.com/augmented-reality/quick-look/)에서,
  고래 울음소리는 Reality Composer Pro의 Asset Library에서 받습니다.

## Topics

### 튜토리얼

- <doc:/tutorials/RoomAquarium>
