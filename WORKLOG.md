# 작업 기록 — 2026-08-17

RoomAquarium 튜토리얼을 **애플이 WWDC24 세션 10102에서 권장하는 구조**로 전면 개정한 세션의 기록입니다.
레퍼런스 앱을 먼저 완성해 실제로 동작을 확인한 뒤, 거기서 나온 코드와 발견으로 문서를 다시 썼습니다.

관련 파일:

- 이 문서 — 무엇을 왜 바꿨는지
- `README.md` — 프로젝트 개요와 빌드 방법
- `CAPTURE-CHECKLIST.md` — 남은 스크린샷 61장 목록
- `~/.claude/plans/roomaquarium-fuzzy-pie.md` — 원래 세운 계획과 단계별 실측 로그

---

## 1. 무엇이 문제였나

기존 튜토리얼은 RealityKit 앱을 **"RCP는 에셋 창고, Swift가 전부 조종"** 하는 구조로 가르쳤습니다.
애플 공식 샘플이 보여주는 구조는 반대입니다 — **"RCP가 저작하고 Swift는 반응한다."**

| 축 | 애플 | 개정 전 RoomAquarium |
|---|---|---|
| 커스텀 코드 위치 | RCP 패키지 안 | 앱 타깃 |
| 컴포넌트 설계 | 설정(Codable) + 런타임 **2개로 분리** | 하나에 설정·상태 혼합 |
| 런타임 상태 생성 | System이 `ComponentEvents.DidAdd` 구독 | 뷰에서 수동 `components.set()` |
| 상호작용 배선 | RCP Behaviors → Timeline → Notification → Swift | Swift `.gesture` → 함수 호출 |
| 탭 전달 | `entity.applyTapForBehaviors()` | 수동 클로저 |
| 충돌 도형 | **RCP에서 저작** | Swift `ShapeResource.generateBox` |

---

## 2. Phase A — 레퍼런스 앱 완성

작업 대상: `/Users/jeonghee/Desktop/WWDC24_RCP`

RCP 쪽(타임라인 이름 정리, Collision/Input Target, OnTap 비헤이비어, Notification 액션)은
직접 GUI에서 작업하고, Swift는 이쪽에서 썼습니다.

**바뀐 파일**

- `RealityKitContent/Sources/RealityKitContent/SeahorseComponent.swift` — 한 파일에 세 타입
  (`SeahorseComponent` 설정 / `SeahorseRuntimeComponent` 상태 / `SeahorseSystem`).
  애플의 `HeroPlantComponent.swift`와 같은 구성입니다.
- `ContentView.swift` — 씬 로드 + `applyTapForBehaviors()` + Notification 수신만 남김
- `WWDC24_RCPApp.swift` — 컴포넌트·시스템 등록

**막혔던 세 가지** (전부 에러 없이 조용히 실패하는 종류였습니다)

1. **해마가 안 움직임** — 등록을 `RealityView` 클로저에서 해서 `DidAdd`를 놓침 → `App.init()`으로 이동
2. **상태가 안 바뀜** — `SourceEntity`가 액션 Target이 아니라 `Root`였음 → 씬에서 다시 찾도록 수정
3. **탭이 안 먹음** — Collider extent를 미터로 착각해 `0.12` 입력, 실제 필요값은 로컬 `12`

시뮬레이터 로그로 확인한 최종 동작:

```
[진단] SeahorseSystem.init 호출됨
[진단] DidAdd 이벤트 도착: Seahorse
[진단] 런타임 생성: Seahorse swimSpeed=0.300000
[진단] 알림 수신: SeahorseStartled  →  상태 전환: idle -> startled
[진단] 알림 수신: SeahorseCalmed    →  상태 전환: startled -> idle
```

---

## 3. 실측으로 알아낸 것

문서에 적힌 함정 설명은 전부 여기서 나온 것입니다. iPad Air 11" (M4) / iOS 26.5 시뮬레이터 기준.

### RealityKit · RCP

| 사항 | 결과 |
|---|---|
| 컴포넌트·시스템 등록 위치 | `App.init()`이어야 함. `RealityView` 클로저는 늦어서 `DidAdd`를 놓침 |
| `Notification`의 `SourceEntity` | 액션 Target이 아니라 **타임라인을 재생한 엔티티**(우리 씬에서는 항상 `Root`) |
| RCP 타임라인과 `AnimationLibraryComponent` | 타임라인은 **이름으로 조회되지 않음.** `animations["SwimLoop"]`은 `nil` |
| `library.animations.map(_:)` | **크래시**(`EXC_BREAKPOINT`). 키 조회만 안전 |
| `clone(recursive:)` | 컴포넌트는 따라오지만 **비헤이비어는 안 따라옴** |
| `ComponentEvents.DidAdd` | 복제본에서도 정상 발동 (8마리 확인) |
| `QueryPredicate` 조합 | `&&`, `||`, 전위 `!` 전부 iOS에 있음. "A는 있고 B는 없는" 조건에 씀 |
| RCP Collision extent 단위 | 미터가 아니라 **엔티티 로컬 단위**. scale 0.01이면 로컬 12 = 12cm |
| `import RealityKit` + `import SwiftUI` | `some Scene`이 모호해짐 → `some SwiftUI.Scene` |
| `RealityKitCustomComponent` 스키마 | 빌드 시 `realitytool create-schema`가 전체 기본값을 생성. RCP는 바꾼 값만 sparse 저장 |

### 복제 실험

원본 1마리 + `clone(recursive:)` 3마리로 측정:

```
Seahorse: applyTap=true   애니메이션수=9  런타임=있음
Clone1:   applyTap=false  애니메이션수=9  런타임=있음
Clone2:   applyTap=false  애니메이션수=9  런타임=있음
Clone3:   applyTap=false  애니메이션수=9  런타임=있음
```

애플 나비(계속 날갯짓하는 그것)는 **두 축의 합성**입니다.

| 나비의 구성 | 정체 | 복제하면 |
|---|---|---|
| 날갯짓 반복 | RCP 타임라인(`loopCount = 0`) + `On Added To Scene` | **안 따라옴** |
| 공간 이동 | `EntityMoverComponent` + `EntityMoverSystem` | **따라옴** |

→ Chapter 4가 존재하는 이유가 여기서 나왔습니다. 복제본은 RCP가 준 **재료**는 물려받지만
**행동**은 잃습니다.

### DocC 구조 제약 — 이게 가장 컸습니다

**`@Step` 안에서는 첫 문단만 `content`, 둘째 블록만 `caption`으로 렌더링됩니다.
셋째 블록부터, 그리고 마크다운 표는 통째로 버려집니다.** 경고만 나오고 조용히 사라집니다.

발견 당시 **17개 스텝에서 내용이 유실**되고 있었습니다(개정 전 튜토리얼도 같은 문제).
표 4개와 다단락 설명 6곳이 실제로 렌더링되지 않았습니다.

- `@ContentAndMedia`는 다단락·리스트를 전부 보존합니다. 리치 콘텐츠는 여기로.
- 표는 리스트로 바꾸거나 섹션 도입부로 옮겼습니다.
- 긴 스텝은 나눴습니다.
- 결과: `Extraneous element` 경고 **17 → 0**

> 앞으로 스텝을 추가할 때는 **1 지시 문단 + 최대 1 보조 문단(또는 aside)** 규칙을 지키세요.

---

## 4. Phase B — 문서 개정

챕터 구조와 파일명(01~04)은 유지했습니다.

| 챕터 | 변경 |
|---|---|
| 1 | RCP 패키지를 "콘텐츠+코드가 사는 곳"으로 재프레이밍. **Collision/Input Target을 RCP에서 저작하는 스텝 추가**(로컬 단위 함정 경고 포함) |
| 2 | 파티클을 해마 자신에게 부착. 오디오를 "소리 재료 준비"로 재작성 → **챕터 전체가 코드 0줄** |
| 3 | 탭을 RCP 저작으로 교체(코드는 `applyTapForBehaviors()` 한 줄). 3번째 섹션에 **Notification 왕복** 신설 |
| 4 | 복제 실패 → 원인 규명 → 설정/런타임 컴포넌트 + System → **RCP에서 노브 조절**로 마무리 |

**이름 통일**

| 이전 | 이후 |
|---|---|
| `AquariumContents` / `aquariumContentsBundle` | `RealityKitContent` / `realityKitContentBundle` |
| `fish.usdz` / `Fish` | `seahorse.usdz` / `Seahorse` |
| `AtmospheresOcean.usdz` | `WhaleCry.usdz` |

**코드 리소스** 17개 (`02-code-01.swift`는 Ch2가 코드 0줄이 되어 삭제)

---

## 5. 다이어그램 3장

스크린샷으로 찍을 수 없어 `Tools/MakeDiagrams.swift`가 CoreGraphics로 그립니다.

| 파일 | 내용 |
|---|---|
| `03-section3` | 타임라인 Notification 액션 → 코드 수신부 (같은 색끼리 짝) |
| `04-section1` | 원점을 비워둔 도넛 배치, 반경 치수와 범례 |
| `04-section2` | 설정 컴포넌트 / System / 런타임 컴포넌트의 관계 |

```bash
cd Tools
xcrun --toolchain XcodeDefault swiftc -O MakeDiagrams.swift -o makediagrams
./makediagrams ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
```

> `swiftc`를 그냥 쓰면 실패합니다. PATH에 Swift 개발 스냅샷 툴체인이 걸려 있어
> stdlib를 못 찾기 때문에 `xcrun --toolchain XcodeDefault`가 필요합니다.

`sync-placeholder-list.py`의 `HANDMADE` 집합에 세 이름이 등록돼 있어
`generate-placeholders.sh`가 덮어쓰지 않습니다.

---

## 6. 도구 변경

| 파일 | 상태 |
|---|---|
| `Tools/sync-placeholder-list.py` | **신규** — 본문 `@Image`에서 placeholder 목록 자동 추출, `HANDMADE` 제외 처리 |
| `Tools/MakeDiagrams.swift` | **신규** — 다이어그램 3장 생성 |
| `Tools/generate-placeholders.sh` | 자동 생성으로 전환 (61장) |
| `Tools/MakePlaceholder.swift` | 그대로 |

---

## 7. 검증 결과

| 항목 | 결과 |
|---|---|
| DocC 빌드 | exit 0, 경고 0 |
| 참조 무결성 | 누락·고아 이미지/코드 전부 0 |
| 스텝 본문 누락 | 0 |
| 튜토리얼 코드 타입체크 | **16/16 통과** (iOS 26, Swift 6) — 9장에서 추가된 3개 포함 |
| iOS 18 호환 | **9/9 통과** (스텁 모듈로 검증) — 9장 추가분은 미검증 |
| 레퍼런스 앱 | 빌드 성공, 시뮬레이터 동작 확인, 실기 탭 확인 |
| placeholder 재생성 후 다이어그램 보존 | 3/3 |

---

## 8. 남은 일

- **스크린샷 61장 촬영.** `CAPTURE-CHECKLIST.md`에 챕터별 목록과 촬영 순서 팁이 있습니다.
  (Chapter 4 네 번째 섹션이 추가되면서 5장 늘었습니다 — 9장 참고)
- **실기기 확인**: Chapter 3의 패스스루(`content.camera = .spatialTracking`)와
  `SpatialTrackingSession`의 오클루전·그림자.
- Chapter 4 마지막 스텝이 언급하는 `scene.raycast(mask: .sceneUnderstanding)` 벽 회피는
  본문 코드에 포함하지 않았습니다. LiDAR 기기가 있어야 검증되기 때문입니다.

### 확인이 필요한 변경

레퍼런스 앱 `Scene.usda`의 Collider extent가 `(12, 25.7, 12)`에서
**`(3.29, 25.64, 10.50)`으로 바뀌어 있습니다.** 모델 실제 몸통 크기 그대로라 폭이 3.3cm뿐이라,
실기기에서 손가락으로 누르기 어려울 수 있습니다. 튜토리얼 본문은 여유 있게 `12`를 권합니다.
탭이 잘 안 맞으면 x·z를 키우세요.

---

## 9. 추가 개정 — Chapter 4 네 번째 섹션 "마릿수와 자리도 RCP로 넘기기"

WWDC23 세션 [10273](https://developer.apple.com/videos/play/wwdc2023/10273)을 공부하고,
거기 나오는 **PointOfInterest 패턴**(빈 엔티티를 표지로 두고 코드가 쿼리)을 반영했습니다.

### 왜 필요했나

개정된 Chapter 4는 "RCP에서 노브를 돌리면 코드 없이 성격이 바뀐다"로 끝났지만,
**마릿수(`seahorseCount = 8`)와 배치(`scatter()`)는 여전히 뷰에 하드코딩**돼 있었습니다.
문서가 관통 주제로 내건 "RCP가 저작하고 Swift는 반응한다"와 어긋나는 마지막 지점이었습니다.

세션 자체가 같은 순서를 밟습니다 — 먼저 하드코딩으로 보여주고, 그다음
"데이터가 경험을 이끌게 하자"며 마커+쿼리로 옮깁니다. 그래서 기존 섹션을 고치지 않고
**네 번째 섹션으로 덧붙이는** 구성을 택했습니다. 독자는 수동 방식으로 원리를 배운 뒤
데이터 주도 방식으로 넘어갑니다.

### 같이 고쳐진 결함

기존 Chapter 4는 `template.removeFromParent()` 후 복제본만 남깁니다. 그런데
**복제본은 비헤이비어를 물려받지 못하므로 탭이 아무 데서도 안 먹습니다.**
챕터 마지막 스텝이 약속하는 "아무나 탭하면 무리 전체가 놀란다"가 성립하지 않았습니다.

레퍼런스 앱에서 실측했습니다 (`count = 5`, iPhone 17 Pro / iOS 26.5 시뮬레이터):

```
[진단] Seahorse_SpawnPoint_Left_0 applyTap=false
[진단] Seahorse_SpawnPoint_Left_1 applyTap=false
[진단] Seahorse_SpawnPoint_Left_2 applyTap=false
[진단] Seahorse_SpawnPoint_Left_3 applyTap=false
[진단] Seahorse_SpawnPoint_Left_4 applyTap=false
```

새 섹션은 원본을 씬에 그대로 두므로 원본 탭이 살아 있고, 복제본 탭은 폴백으로
원본에 넘깁니다. 알림은 씬 전체에 뿌려지므로 결과는 동일합니다.

### 추가된 파일

| 파일 | 내용 |
|---|---|
| `04-code-06.swift` | `SpawnPointComponent` / `SpawnPointRuntimeComponent` / `SpawnPointSystem` |
| `04-code-07.swift` | `RoomAquariumApp` — SpawnPoint 등록 2줄 추가 |
| `04-code-08.swift` | `AquariumView` — 복제 루프 삭제, 탭 폴백 추가 |

이미지 4장 추가: `04-section4`, `04-s4-step1`, `04-s4-step2`, `04-s4-step3`, `04-s4-result`
(`04-s3-result`는 alt 문구만 바뀌어 그대로 유지).

### 설계 결정 두 가지

**복제본을 마커의 자식으로 넣습니다.** 그래서 `roamRadius`·`innerRadius`가 원점이 아니라
마커 중심으로 걸립니다. 마커를 원점에 두면 기존 도넛과 동일하고, 여러 개 두면 도넛이
여러 개 생깁니다. `04-section1` 다이어그램은 "각 마커의 영역"으로 읽으면 그대로 유효합니다.
본문에 주의 문단을 넣었습니다.

**런타임 컴포넌트를 "도장"으로도 씁니다.** `update`가 매 프레임 도니까
"이미 처리했다" 표시가 없으면 무한 증식합니다. 런타임 컴포넌트의 쓰임새가
상태 저장만이 아니라는 걸 보여주는 자연스러운 예라 본문에서 짚었습니다.

### 9장 검증 결과

| 항목 | 결과 |
|---|---|
| DocC 빌드 | exit 0, DocC 경고 0 (`Extraneous element` 없음) |
| 참조 무결성 | 누락·고아 이미지/코드 전부 0 |
| `04-code-06` 타입체크 | 통과 (`04-code-03`과 합쳐서, iOS 26 / Swift 6) |
| `04-code-07`·`04-code-08` 타입체크 | 통과 (스텁 `RealityKitContent` 모듈, `-parse-as-library`) |
| placeholder | 61장 재생성, 다이어그램 3장 보존 |

> `.build` 잠금은 켜져 있는 `preview-documentation` 서버(22시간째)가 잡고 있습니다.
> 검증은 `--scratch-path`로 별도 경로에서 돌렸습니다. 서버는 건드리지 않았으니
> `localhost:8080`을 새로고침하면 새 섹션이 바로 보입니다.

### 레퍼런스 앱 반영

`/Users/jeonghee/Desktop/WWDC24_RCP`에 같은 코드가 들어가 있고 시뮬레이터에서 확인했습니다.
`Scene.usda`에 본보기 마커 `SpawnPoint_Left` 하나가 손으로 저작돼 있습니다
(`RealityAssetsCompile` 통과 확인).
