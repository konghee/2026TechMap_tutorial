# 스크린샷 캡처 체크리스트

`Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources/`의 PNG 64장 중 **61장이 placeholder**입니다
(다이어그램 3장 — `03-section3`, `04-section1`, `04-section2` — 은 코드로 그려 완성 상태입니다).
**같은 파일명으로 덮어쓰면** 튜토리얼에 바로 반영됩니다. 각 placeholder 이미지 안에도
파일명과 설명이 적혀 있으니, 열어 보고 그대로 찍으면 됩니다.

## 촬영 규격

- **크기**: placeholder와 같은 **900 × 560**(가로세로비 45:28)에 맞추면 레이아웃이 흔들리지 않습니다.
  더 큰 해상도로 찍고 같은 비율로 크롭하는 편이 선명합니다.
- **Xcode / RCP 화면**: 관련 패널만 크롭하세요. 전체 화면을 넣으면 텍스트가 읽히지 않습니다.
  포커스가 필요한 필드는 선택 상태로 두면 파란 테두리가 시선을 잡아 줍니다.
- **시뮬레이터**: iPad Air 11-inch (M4), iOS 26.5 기준. `Cmd+S`로 스크린샷.
- **실기기**: 전원+볼륨업. 방이 지저분하면 캡처가 산만해집니다.
- **다크/라이트**: 하나로 통일하세요. Xcode는 다크, 시뮬레이터 실행 화면은 상관없습니다.

## 캡처 순서 팁

**Chapter 2의 `02-s2-step4`(On Added To Scene 비헤이비어)를 먼저 찍어 두세요.**
Chapter 4에서 해마를 복제하면 이 비헤이비어가 무력해지는데, 본문 흐름상 RCP에서
지울 필요는 없지만 화면 구성이 달라질 수 있습니다.

RCP 화면은 챕터 순서대로 씬을 쌓아 가며 찍는 게 가장 효율적입니다. 한 번 지나간
상태(예: Chapter 1의 `Floor`)는 Chapter 3에서 삭제하므로 되돌리기 어렵습니다.

---

## 목차 (5장)

| 파일 | 무엇을 찍나 |
|---|---|
| `toc-intro` | 아이패드 화면 속 방 안에 떠 있는 가상 아쿠아리움 (표지용, 가장 예쁜 컷) |
| `ch1-card` | RCP 뷰포트에 배치된 아쿠아리움 씬 |
| `ch2-card` | 기포 파티클이 올라오는 씬 |
| `ch3-card` | 실제 방에 AR로 배치된 아쿠아리움 |
| `ch4-card` | 방 안을 떠다니는 해마 여러 마리 |

## Chapter 1 — Building the Scene (17장)

> 섹션 순서: ① 프로젝트·패키지 준비 → ② RCP 씬 조립 → ③ RealityView 로딩

| 파일 | 무엇을 찍나 |
|---|---|
| `01-intro` | RCP 뷰포트에 배치된 아쿠아리움 씬 |
| `01-section1` | Xcode 프로젝트 내비게이터에 추가된 `RealityKitContent` 패키지 |
| `01-s1-step1` | 새 프로젝트 생성 화면, iOS 탭 **App** 템플릿 선택 상태 |
| `01-s1-step2` | General > Minimum Deployments = iOS 18.0 |
| `01-s1-step3` | **Xcode > Open Developer Tool > Reality Composer Pro** 메뉴가 열린 상태 |
| `01-s1-step4` | RCP 새 프로젝트 저장 다이얼로그, 이름 필드에 `RealityKitContent` |
| `01-s1-step5` | 앱 타깃 General > Frameworks, Libraries, and Embedded Content 목록 |
| `01-s1-step6` | `import RealityKitContent` 자동완성 팝업 + 빌드 성공 표시 |
| `01-section2` | RCP 계층 패널과 뷰포트 |
| `01-s2-step1` | `.rkassets` 폴더에 `seahorse.usdz`와 `WhaleCry.usdz`가 들어간 모습 |
| `01-s2-step2` | 계층 패널의 `Root` 엔티티, 탭 제목이 `Scene.usda` |
| `01-s2-step3` | `Seahorse` 선택 상태의 Transform 인스펙터 (Scale 0.01, Y 0.5, Z −0.5) |
| `01-s2-step4` | 납작하게 눌린 원기둥 `Floor`가 뷰포트에 보이는 상태 |
| `01-s2-step5` | Collision + Input Target 인스펙터 **(중요)** — 초록 와이어프레임이 해마 몸을 감싼 게 보이게 |
| `01-s2-step6` | `Root` 아래 `Seahorse`, `Floor`가 정리된 계층 |
| `01-section3` | 시뮬레이터에 표시된 아쿠아리움 씬 |
| `01-s3-result` | 시뮬레이터에서 드래그로 회전 중인 씬 |

## Chapter 2 — Bringing It to Life (16장)

> 섹션 순서: ① 파티클 → ② 타임라인·비헤이비어 → ③ 오디오 재료
> 이 챕터는 **코드 캡처가 하나도 없습니다.** 전부 RCP 화면입니다.

| 파일 | 무엇을 찍나 |
|---|---|
| `02-intro` | 기포가 올라오는 아쿠아리움 씬 |
| `02-section1` | RCP 파티클 이미터 인스펙터 전체 |
| `02-s1-step1` | `Seahorse`에 Particle Emitter 추가 직후 (기본값으로 입자가 뿜어져 나오는 상태) |
| `02-s1-step2` | Emitter Shape `Cylinder`, Birth Rate `20` |
| `02-s1-step3` | Acceleration Y `1`, Opacity Over Life `Gradual Fade In Out` |
| `02-s1-step4` | 시뮬레이터에서 해마를 따라 올라가는 기포 |
| `02-section2` | RCP 타임라인 편집기와 액션 목록 |
| `02-s2-step1` | `Seahorse` 인스펙터에 **Animation Library**가 이미 붙어 있는 모습 |
| `02-s2-step2` | 하단 **Timelines** 탭, `SwimLoop` 타임라인 생성 |
| `02-s2-step3` | Animation 액션의 Target=`Seahorse`, Loop 켜진 인스펙터 |
| `02-s2-step4` | **Behaviors** 컴포넌트, On Added To Scene → `SwimLoop` **(중요)** |
| `02-s2-result` | 코드 수정 없이 헤엄치는 해마 |
| `02-section3` | RCP 오디오 라이브러리 인스펙터 |
| `02-s3-step1` | `.rkassets` 폴더의 `WhaleCry.usdz` |
| `02-s3-step2` | `Seahorse`에 **Audio Library** 컴포넌트를 추가하는 순간 |
| `02-s3-step3` | Audio Library의 resources 목록에 `WhaleCry.usdz`가 등록된 인스펙터 |

## Chapter 3 — Placing It in Your Room (12장)

> 섹션 순서: ① 패스스루 → ② RCP 저작 탭 연출 → ③ Notification 왕복

| 파일 | 무엇을 찍나 |
|---|---|
| `03-intro` | 실제 방에 배치된 AR 아쿠아리움 |
| `03-section1` | 카메라 패스스루로 본 방 (월드 원점 개념 설명용) |
| `03-s1-step1` | Build Settings에서 `INFOPLIST_KEY_NSCameraUsageDescription` 값이 보이는 상태 |
| `03-s1-step2` | RCP에서 `Floor` 엔티티를 선택하고 삭제하려는 순간 |
| `03-s1-result` | **실기기** — 방 배경 위에 해마가 떠 있는 화면 |
| `03-section2` | 탭에 반응하는 해마 |
| `03-s2-step1` | `TapSeahorse` 타임라인 — Emphasize(Spin)와 Play Audio가 **서로 다른 트랙**에 놓인 게 보이게 **(중요)** |
| `03-s2-step2` | Behaviors에 On Tap → `TapSeahorse`가 추가된 인스펙터 (기존 On Added To Scene도 같이 보이면 좋음) |
| `03-s2-result` | 탭해서 몸을 돌리는 해마 (시뮬레이터로도 가능) |
| `03-section3` | **완성됨** — `Tools/MakeDiagrams.swift` |
| `03-s3-step1` | 타임라인의 Notification 액션 두 개 — 이름과 시각(`0`, `1.9`)이 읽히게 **(중요)** |
| `03-s3-result` | 탭 직후 "해마가 놀랐어요!" 배지가 뜬 화면 |

## Chapter 4 — Many of Them (14장)

> 섹션 순서: ① 복제하면 안 움직임 → ② 설정/런타임 컴포넌트 + System → ③ RCP에서 성격 조절
> → ④ 마릿수와 자리도 RCP로

| 파일 | 무엇을 찍나 |
|---|---|
| `04-intro` | 방 안을 떠다니는 해마 여러 마리 |
| `04-section1` | **완성됨** — `Tools/MakeDiagrams.swift` |
| `04-s1-result` | 해마 8마리가 흩어져 있지만 **아무도 안 움직이는** 화면. 기포만 나옴 |
| `04-section2` | **완성됨** — `Tools/MakeDiagrams.swift` |
| `04-s2-step1` | **RCP 인스펙터에 나타난 `SeahorseComponent`와 노브 목록 (이 챕터의 하이라이트)** — Swift로 선언한 프로퍼티가 그대로 UI가 된 게 보이게 |
| `04-s2-result` | 해마들이 각자 다른 박자로 실제로 떠다니는 화면 |
| `04-section3` | RCP 인스펙터에서 노브를 조절하는 모습 |
| `04-s3-step1` | `swimSpeed`를 `0.3`으로 바꾸는 순간의 인스펙터 |
| `04-s3-result` | 노브를 바꿔 성격이 달라진 해마들 (앞 컷과 확실히 달라 보이게) |
| `04-section4` | RCP 계층에서 마커를 선택한 상태 + 뷰포트에서 그 자리에 해마가 모여 있는 실행 화면. 둘을 나란히 붙이면 가장 잘 읽힙니다 |
| `04-s4-step1` | **+ 버튼 → Transform** 메뉴가 열린 상태, 또는 이름을 `SpawnPoint_Left`로 바꾼 직후의 계층 패널 |
| `04-s4-step2` | **인스펙터의 `SpawnPoint` 컴포넌트 (이 섹션의 하이라이트)** — `count` / `scatterRadius` / `prototypeName` 세 칸이 다 보이게, `count`는 `5` 입력 상태 |
| `04-s4-step3` | 마커 주변에 해마가 무리 지어 떠 있는 실행 화면. 원본 한 마리가 원점 쪽에 따로 있는 게 보이면 더 좋습니다 |
| `04-s4-result` | 완성된 아쿠아리움 (실기기 패스스루 컷이면 가장 좋습니다) |

> `04-s4-step2`를 찍기 전에 **Cmd+B로 한 번 빌드하고 RCP를 껐다 켜야** Add Component
> 목록에 `SpawnPoint`가 나타납니다.

---

## 다이어그램 — 촬영할 필요 없습니다

스크린샷으로 안 되는 3장은 `Tools/MakeDiagrams.swift`가 CoreGraphics로 그립니다. **이미 완성돼 있습니다.**

| 파일 | 내용 |
|---|---|
| `03-section3` | 타임라인 Notification 액션 → 코드 수신부 (같은 색끼리 짝) |
| `04-section1` | 원점을 비워둔 도넛 배치, 반경 치수와 범례 |
| `04-section2` | 설정 컴포넌트 / System / 런타임 컴포넌트의 관계 |

문구나 색을 고치려면:

```bash
cd Tools
xcrun --toolchain XcodeDefault swiftc -O MakeDiagrams.swift -o makediagrams
./makediagrams ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
```

> `generate-placeholders.sh`는 이 3장을 건드리지 않습니다.
> `sync-placeholder-list.py`의 `HANDMADE` 집합에 등록돼 있기 때문입니다.

## 교체 후 확인

```bash
# 1. 참조 무결성 (누락/고아 0이어야 함)
cd Sources/RoomAquarium/RoomAquarium.docc && python3 - <<'PY'
import re, pathlib
res = pathlib.Path("Tutorials/Resources")
imgs = set()
for t in pathlib.Path(".").rglob("*.tutorial"):
    imgs |= set(re.findall(r'@Image\(\s*source:\s*"([^"]+)"', t.read_text()))
png = {p.stem for p in res.glob("*.png")}
print("누락:", sorted(imgs - png) or "없음")
print("고아:", sorted(png - imgs) or "없음")
PY

# 2. 미리보기로 눈 확인
swift package --disable-sandbox preview-documentation --target RoomAquarium
# http://localhost:8080/tutorials/roomaquarium
```

아직 안 찍은 컷이 남았는지 보려면, placeholder 특유의 어두운 남색 패널이 미리보기에 보이는지
훑어보면 됩니다.

## placeholder 다시 만들기

스텝을 추가·삭제해서 새 placeholder가 필요해지면 `Tools/`의 생성기를 씁니다.

```bash
cd Tools
swiftc -O MakePlaceholder.swift -o makeph   # 최초 1회만
python3 sync-placeholder-list.py            # 본문의 @Image에서 목록 재추출
./generate-placeholders.sh                  # 목록 전체 재생성

# 한 장만 필요할 때
./makeph ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources \
  "04-s2-step1|여기에 무엇을 찍을지 설명"
```

`sync-placeholder-list.py`가 본문에서 목록을 직접 뽑기 때문에, 목록을 손으로 고칠 일이
없고 위 "교체 후 확인"의 고아/누락 검사도 자동으로 0이 유지됩니다.
