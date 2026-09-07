# 작업 기록

RoomAquarium 튜토리얼 작업의 누적 기록입니다. **아래로 갈수록 오래된 기록**이고,
1~9장은 2026-08-17 전면 개정 세션, 10장부터가 그 이후입니다.

관련 파일:

- 이 문서 — 무엇을 왜 바꿨는지
- `README.md` — 프로젝트 개요와 빌드 방법
- `CAPTURE-CHECKLIST.md` — 남은 스크린샷 목록

## 지금 상태 한눈에 (2026-09-07 기준)

| | |
|---|---|
| 챕터 | **3개** (1 Scene 조립 · 2 살아 움직이게 · 3 내 방에 놓기) |
| 스텝 | 41개, 그중 34개가 이미지 전용 GUI 스텝 |
| 참조 이미지 | 50장 — **43장 촬영 완료, 7장 남음** |
| DocC 빌드 | 한국어·영어 **경고 0** |
| 실기기 미확인 | Chapter 3 패스스루의 오클루전·그림자 |

**빠져 있는 것**: Chapter 4 "여러 마리로 늘리기" 전체와 Chapter 3의 세 번째 섹션
"Notification 왕복". 10장을 보세요.

---

# 1~9장 — 2026-08-17 전면 개정

RoomAquarium 튜토리얼을 **애플이 WWDC24 세션 10102에서 권장하는 구조**로 전면 개정한 세션의 기록입니다.
레퍼런스 앱을 먼저 완성해 실제로 동작을 확인한 뒤, 거기서 나온 코드와 발견으로 문서를 다시 썼습니다.

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

작업 대상: 레퍼런스 앱 `WWDC24_RCP` (이 리포와 별개인 로컬 Xcode 프로젝트)

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

레퍼런스 앱 `WWDC24_RCP`에 같은 코드가 들어가 있고 시뮬레이터에서 확인했습니다.
`Scene.usda`에 본보기 마커 `SpawnPoint_Left` 하나가 손으로 저작돼 있습니다
(`RealityAssetsCompile` 통과 확인).

---

# 10. 2026-09-07 — Chapter 4·Chapter 3 세 번째 섹션 삭제 반영

`dbbf720`("ch4 삭제 및 ch3 section3 삭제")이 본문 `.tutorial` 두 파일만 지우고
나머지를 그대로 두어, 문서와 실제 상태가 크게 어긋나 있었습니다. 그 뒷정리입니다.

## 무엇이 어긋나 있었나

| 증상 | 실제 |
|---|---|
| 목차가 없는 챕터를 가리킴 | `RoomAquarium.tutorial`의 `@TutorialReference(tutorial: "doc:04-ManyOfThem")`가 남아 DocC가 `warning: '04-ManyOfThem' doesn't exist`를 냄. 사이트에 눌리지 않는 챕터 카드가 보였습니다 |
| 두 언어의 내용이 다름 | 영어 오버레이 `03-PlacingInYourRoom.tutorial`에 삭제된 세 번째 섹션이 그대로 남아, `/`는 2개 섹션·`/en`은 3개 섹션이었습니다 |
| `Extraneous element` 경고 7건 | 7장에 "경고 0"으로 적혀 있었지만 되살아나 있었습니다. ch1 6건 + ch3 1건, 스텝 본문이 조용히 잘려 나가는 중이었습니다 |
| 이름이 반쯤 바뀜 | ch1·ch3 본문은 `AquariumContent`, ch2 본문과 `01-code-03/04.swift`는 `RealityKitContent`. ch1 본문은 `aquariumContentBundle`을 설명하는데 코드 샘플은 `realityKitContentBundle`을 보여 주고 있었습니다 |
| 문서의 캡처 현황이 옛날 것 | README·체크리스트가 "61장 placeholder"라고 했지만 실제로는 **43장이 이미 촬영 완료**, 남은 건 8장이었습니다 |

## 고친 것

**목차 (한/영)** — Chapter 4 `@Chapter` 블록을 양쪽에서 제거했습니다.
Chapter 3 소개 문구에서도 "마지막에는 Timeline이 코드에게 알림을 보내는 반대
방향까지 배웁니다"를 뺐습니다. 그 섹션이 없기 때문입니다.

**영어 오버레이** — `03-PlacingInYourRoom.tutorial`에서 세 번째 섹션
"The Timeline Talks Back to Your Code"를 통째로 지워 한국어와 맞췄습니다.
섹션이 하나 빠졌으므로 `@Tutorial(time:)`을 45 → 30으로 낮췄습니다(한/영 모두).

**`Extraneous element` 7건** — 규칙은 여전히 **1 지시 문단 + 최대 1 보조 문단**이고,
실측해 보니 **aside(`> Note:`)는 세 번째 블록이어도 경고가 나지 않습니다.**
그래서 두 가지로 나눠 고쳤습니다.

| 위치 | 처리 |
|---|---|
| `01-s1-step5` · `01-s2-step1` · `01-s2-step2` | 이어지는 내용이라 앞 문단에 **합침** |
| `01-s1-step6` · `01-s1-step7` · `03-code-01` 스텝(한/영) | 부연이라 **`> Note:` / `> Tip:` aside로 전환** |

`01-s1-step7`의 번호 매긴 문제 해결 목록 4개는 리스트째로 버려지고 있었습니다.
`> Tip:` aside 안의 한 문단으로 풀어썼습니다.

**이름 통일** — 본문이 참조하는 코드 파일에서만 `RealityKitContent` →
`AquariumContent`, `realityKitContentBundle` → `aquariumContentBundle`로 맞췄습니다
(한국어 `01-code-03/04`, `03-code-01/02/03` · 영어 `03-code-01/02/03`).
ch2 본문의 `RealityKitContent` 2곳도 함께 고쳤습니다. 참조가 끊긴 파일
(`04-code-*`, `01-code-01`, `03-code-04`)은 **손대지 않았습니다.**

**ch2에 남아 있던 Chapter 4 언급 2곳** — 없는 챕터를 가리키므로 다시 썼습니다.
"Chapter 4에서 복제할 때" → "해마를 옮기거나 복제해도", 그리고 "코드 0줄" Note는
`clone(recursive:)`이 비헤이비어를 가져오지 않는다는 사실만 남겼습니다.

**랜딩 페이지 (한/영)** — "4개 챕터" / "four-chapter"를 3으로 고치고,
커스텀 컴포넌트·System으로 끝난다는 설명을 카메라 패스스루로 끝난다는 설명으로
바꿨습니다.

## 지우지 않은 것

Chapter 4와 Chapter 3 세 번째 섹션의 **리소스는 전부 남겨 두었습니다** —
PNG 21장과 Swift 10개입니다. 되살릴 여지를 두기 위한 것이고, 그 결과
참조 무결성 검사의 "고아" 항목이 0이 아닙니다. **정상입니다.**
README와 체크리스트에 그 사실과 목록을 적어 두었습니다.

다이어그램 3장(`03-section3`, `04-section1`, `04-section2`)도 그대로 있습니다.
되살릴 때 다시 그릴 필요가 없습니다.

## 캡처 현황 재측정

placeholder는 전부 900×560으로 생성되므로, 그 크기인 것만 세면 남은 장수를
정확히 알 수 있습니다.

```bash
cd Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
for f in *.png; do
  sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null \
    | awk -v n="$f" '/pixelWidth/{w=$2}/pixelHeight/{h=$2}END{if(w==900&&h==560)print n}'
done
```

결과: 본문이 참조하는 50장 중 **43장 촬영 완료**, 남은 7장은
`02-section2` · `02-s2-result` · `02-section3` · `02-s3-step3` ·
`03-s1-result` · `03-section2` · `03-s2-result`.
실기기가 필요한 건 `03-s1-result` 하나뿐입니다.
(`ch4-card`도 촬영 전이지만 Chapter 4가 빠지면서 참조가 사라졌습니다.)

발견 두 가지:

- `01-section3`과 `01-s3-result`가 **같은 파일**입니다(1206×2622, 215KB).
  의도한 것이 아니라면 둘 중 하나를 다시 찍어야 합니다.
- `toc-intro`(6.8MB) · `03-section1`(7.4MB) · `ch2-card`(3.5MB)가 상당히 큽니다.
  페이지 로딩에 부담이 되니 줄이는 편이 좋습니다.

> **`./generate-placeholders.sh`는 이제 위험합니다.** 목록에 있는 이름을 전부
> 다시 그리므로 **이미 찍은 43장을 덮어씁니다.** 한 장씩 `./makeph`를 쓰세요.
> README와 체크리스트 양쪽에 경고를 넣었습니다.

## 검증

| 항목 | 결과 |
|---|---|
| DocC 빌드 (한국어) | exit 0, **경고 0** |
| DocC 빌드 (영어 오버레이) | exit 0, **경고 0** |
| `04-ManyOfThem` 끊긴 참조 | 해소 |
| `Extraneous element` | **7 → 0** |
| 참조 무결성 — 누락 | 이미지 0, 코드 0 |
| 참조 무결성 — 고아 | 이미지 21, 코드 10 (**의도된 보존**) |

## 남은 일

- **스크린샷 7장.** `CAPTURE-CHECKLIST.md` 참고.
- **실기기 확인**: Chapter 3 패스스루의 오클루전·그림자. 현재 본문에서 실기기가
  필요한 곳은 여기 하나뿐입니다.
- **영어 번역**: 현재 랜딩 페이지와 Chapter 3만 번역돼 있습니다. Chapter 1·2는
  영어 빌드에서도 한국어 본문이 나옵니다.
- `01-section3` / `01-s3-result` 중복 이미지 정리.
- Chapter 4를 되살린다면: `dbbf720` 이전 커밋에서 `04-ManyOfThem.tutorial`과
  `03-PlacingInYourRoom.tutorial`을 꺼내고, 두 목차에 `@Chapter` 블록을 다시 넣고,
  ch2의 Chapter 4 언급을 원래대로 돌리면 됩니다. 리소스는 이미 다 있습니다.
