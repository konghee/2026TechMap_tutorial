# 스크린샷 캡처 체크리스트

`Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources/`에서 **본문이 실제로 참조하는
이미지는 50장**이고, 그중 **43장은 촬영이 끝났습니다. 남은 것은 7장**입니다.

**같은 파일명으로 덮어쓰면** 튜토리얼에 바로 반영됩니다. placeholder 이미지 안에는
파일명과 설명이 적혀 있으니, 열어 보고 그대로 찍으면 됩니다.

> 폴더에는 PNG가 71장 있지만 21장은 Chapter 4와 Chapter 3 세 번째 섹션이 빠지면서
> 참조가 끊긴 것들입니다. 되살릴 때를 대비해 남겨 두었을 뿐이니 **찍지 마세요.**
> 아래 "참조가 끊긴 이미지"에 목록이 있습니다.

## 남은 7장

| 파일 | 챕터 | 무엇을 찍나 |
|---|---|---|
| `02-section2` | 2 | RCP 타임라인 편집기와 애니메이션 액션 (섹션 대표 컷) |
| `02-s2-result` | 2 | 코드 수정 없이 헤엄치는 해마 |
| `02-section3` | 2 | RCP 오디오 라이브러리 인스펙터 (섹션 대표 컷) |
| `02-s3-step3` | 2 | Audio Library의 resources 목록에 `WhaleCry.usdz`가 등록된 인스펙터 |
| `03-s1-result` | 3 | **실기기** — 방 배경 위에 해마가 떠 있는 화면 |
| `03-section2` | 3 | 탭에 반응하는 해마 (섹션 대표 컷) |
| `03-s2-result` | 3 | 탭해서 몸을 돌리는 해마 (시뮬레이터로도 가능) |

`03-s1-result` 한 장만 실기기가 필요하고, 나머지는 RCP 화면과 시뮬레이터로 끝납니다.

## 촬영 규격

- **크기**: placeholder와 같은 **900 × 560**(가로세로비 45:28)에 맞추면 레이아웃이 흔들리지
  않습니다. 더 큰 해상도로 찍고 같은 비율로 크롭하는 편이 선명합니다.
- **Xcode / RCP 화면**: 관련 패널만 크롭하세요. 전체 화면을 넣으면 텍스트가 읽히지 않습니다.
  포커스가 필요한 필드는 선택 상태로 두면 파란 테두리가 시선을 잡아 줍니다.
- **시뮬레이터**: iPad Air 11-inch (M4), iOS 26.5 기준. `Cmd+S`로 스크린샷.
- **실기기**: 전원+볼륨업. 방이 지저분하면 캡처가 산만해집니다.
- **다크/라이트**: 하나로 통일하세요. Xcode는 다크, 시뮬레이터 실행 화면은 상관없습니다.
- **용량**: 이미 올라간 것 중 `toc-intro`(6.8MB), `03-section1`(7.4MB), `ch2-card`(3.5MB)는
  많이 큽니다. 새로 찍는 것은 긴 변 1800px 정도로 줄여서 넣으세요.

## 촬영 순서 팁

남은 컷은 **Chapter 2 → Chapter 3** 순서로, RCP 씬을 쌓아 가며 찍는 게 가장 효율적입니다.
`02-s2-result`(헤엄치는 해마)를 먼저 확보한 뒤 오디오를 붙이면 `02-section3`과
`02-s3-step3`이 한 자리에서 나옵니다.

`03-s2-result`는 시뮬레이터로도 되지만, `03-s1-result`를 찍으러 실기기를 꺼낸 김에
같이 찍으면 두 컷의 톤이 맞습니다.

---

## 이미 촬영된 43장

되찍을 일이 있을 때만 참고하세요.

### 목차 (4/4 ✅ 완료)

| 파일 | 상태 |
|---|---|
| `toc-intro` | ✅ |
| `ch1-card` | ✅ |
| `ch2-card` | ✅ |
| `ch3-card` | ✅ |

> `ch4-card`도 촬영은 안 돼 있지만, Chapter 4가 목차에서 빠져 **참조가 없습니다.**
> 되살릴 때만 필요합니다.

### Chapter 1 — Scene 조립하기 (16/16 ✅ 완료)

> 섹션 순서: ① 프로젝트·패키지 준비 → ② RCP 씬 조립 → ③ RealityView 로딩

`01-intro` · `01-section1` · `01-s1-step1`~`step7` · `01-section2` ·
`01-s2-step1`~`step4` · `01-section3` · `01-s3-result`

> `01-section3`과 `01-s3-result`가 **같은 파일**입니다(1206×2622, 215KB).
> 섹션 대표 컷과 결과 컷을 다르게 하고 싶다면 둘 중 하나를 다시 찍으세요.

### Chapter 2 — 살아 움직이게 하기 (15/19)

> 섹션 순서: ① 파티클 → ② 타임라인·비헤이비어 → ③ 오디오 재료
> 이 챕터는 **코드 캡처가 하나도 없습니다.** 전부 RCP 화면입니다.

| 파일 | 상태 |
|---|---|
| `02-intro` | ✅ |
| `02-section1` | ✅ |
| `02-s1-step1`~`step4` | ✅ |
| `02-section2` | ⬜ **남음** |
| `02-s2-step1` · `step2` · `step3` · `step3b` | ✅ |
| `02-s2-step4` · `step4b` · `step4c` | ✅ |
| `02-s2-result` | ⬜ **남음** |
| `02-section3` | ⬜ **남음** |
| `02-s3-step1` · `step2` | ✅ |
| `02-s3-step3` | ⬜ **남음** |

### Chapter 3 — 내 방에 놓기 (8/11)

> 섹션 순서: ① 패스스루 → ② RCP 저작 탭 연출
> 세 번째 섹션(Notification 왕복)은 현재 빠져 있습니다.

| 파일 | 상태 |
|---|---|
| `03-intro` | ✅ |
| `03-section1` | ✅ |
| `03-s1-step1` | ✅ |
| `03-s1-result` | ⬜ **남음 · 실기기** |
| `03-section2` | ⬜ **남음** |
| `03-s2-step1`~`step5` | ✅ |
| `03-s2-result` | ⬜ **남음** |

---

## 참조가 끊긴 이미지 (찍지 마세요)

Chapter 4 삭제와 Chapter 3 세 번째 섹션 삭제로 본문에서 참조가 사라진 21장입니다.
파일은 되살릴 때를 위해 남겨 두었습니다.

- **Chapter 3 세 번째 섹션**: `03-section3`(다이어그램) · `03-s3-step1` · `03-s3-result`
- **Chapter 1 옛 스텝**: `01-s2-step5` · `01-s2-step6`
- **Chapter 3 옛 스텝**: `03-s1-step2`
- **Chapter 4 전체**: `ch4-card` · `04-intro` · `04-section1`~`section4` ·
  `04-s1-result` · `04-s2-step1` · `04-s2-result` · `04-s3-step1` · `04-s3-result` ·
  `04-s4-step1`~`step3` · `04-s4-result`

`04-section1`·`04-section2`·`03-section3` 세 장은 스크린샷이 아니라
`Tools/MakeDiagrams.swift`가 그린 다이어그램이라 그대로 재사용할 수 있습니다.

## 교체 후 확인

```bash
# 1. 참조 무결성
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

# 2. 아직 남은 placeholder가 몇 장인지 (900x560이면 placeholder)
cd Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
for f in *.png; do
  sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null \
    | awk -v n="$f" '/pixelWidth/{w=$2}/pixelHeight/{h=$2}END{if(w==900&&h==560)print n}'
done

# 3. 미리보기로 눈 확인
swift package --disable-sandbox preview-documentation --target RoomAquarium
# http://localhost:8080/tutorials/roomaquarium
```

위 1번의 "고아"에는 참조가 끊긴 21장이 그대로 뜹니다. 정상입니다.
**"누락"은 반드시 "없음"이어야 합니다** — 누락이 뜨면 그건 진짜 오류입니다.

## placeholder 다시 만들기

스텝을 추가·삭제해서 새 placeholder가 필요해지면 `Tools/`의 생성기를 씁니다.

```bash
cd Tools
swiftc -O MakePlaceholder.swift -o makeph   # 최초 1회만
python3 sync-placeholder-list.py            # 본문의 @Image에서 목록 재추출
./generate-placeholders.sh                  # 목록 전체 재생성

# 한 장만 필요할 때
./makeph ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources \
  "02-section2|RCP 타임라인 편집기와 애니메이션 액션"
```

> **주의**: `generate-placeholders.sh`는 목록에 있는 이름을 **전부 다시 그립니다.**
> 이미 찍어 둔 43장을 덮어쓰게 되니, 지금 시점에서 전체 재생성은 쓰지 마세요.
> 필요한 한 장만 `./makeph`로 만드는 편이 안전합니다.

`sync-placeholder-list.py`의 `HANDMADE` 집합에 등록된 이름
(`03-section3`, `04-section1`, `04-section2`)은 재생성에서 제외됩니다.
