# 스크린샷 체크리스트

`Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources/`에서 본문이 참조하는
이미지 **46장은 모두 촬영이 끝났습니다.** 남은 placeholder는 없습니다.

이 문서는 다시 찍거나 새 스텝을 추가할 때 참고하세요. **같은 파일명으로 덮어쓰면**
튜토리얼에 바로 반영됩니다. 영어판도 같은 이미지를 씁니다.

## 촬영 규격

- **비율**: 가로세로비가 제각각이어도 레이아웃은 깨지지 않지만, 한 섹션 안에서는 비슷하게
  맞추면 넘길 때 덜 흔들립니다.
- **크기**: 긴 변 **2400px 이하**로 줄여서 넣습니다(`sips -Z 2400 파일.png`). 원본 그대로
  넣으면 장당 3~7MB가 돼서 페이지가 느려집니다.
- **형식**: PNG. 표지·챕터 카드·Chapter 3 사진은 모서리가 투명한 기기 목업이라 JPEG로
  바꾸면 모서리가 칠해집니다.
- **Xcode / RCP 화면**: 관련 패널만 크롭하세요. 전체 화면을 넣으면 글자가 읽히지 않습니다.
  포커스가 필요한 필드는 선택 상태로 두면 파란 테두리가 시선을 잡아 줍니다.
- **시뮬레이터**: iPad Air 11-inch (M4) 기준. `Cmd+S`로 스크린샷.
- **실기기**: 전원+볼륨업.
- **다크/라이트**: 하나로 통일하세요.

## 현황

### 목차 (4/4)

`toc-intro` · `ch1-card` · `ch2-card` · `ch3-card`

### Chapter 1 — Scene 조립하기 (15/15)

`01-intro` · `01-section1` · `01-s1-step1`~`step7` · `01-section2` ·
`01-s2-step1` · `step2` · `step4` · `01-section3` · `01-s3-result`

> `01-section3`과 `01-s3-result`는 **같은 사진**입니다.

### Chapter 2 — 살아 움직이게 하기 (15/15)

`02-intro` · `02-section1` · `02-s1-step1`~`step4` ·
`02-s2-step1` · `step2` · `step3` · `step3b` · `step4` · `step4b` · `step4c` ·
`02-s3-step1` · `step2`

> 섹션 2·3에는 대표 이미지가 없습니다(본문에서 뺐습니다).

### Chapter 3 — 내 방에 놓기 (12/12)

`03-intro` · `03-section1` · `03-s1-step1` · `03-s1-result` ·
`03-section2` · `03-s2-step1`~`step6` · `03-s2-result`

> `03-section2`와 `03-s2-result`는 **같은 사진**입니다. 섹션 대표 컷과 결과 컷을 다르게
> 하고 싶다면 둘 중 하나를 다시 찍으세요.

## 참조가 끊긴 이미지 (찍지 마세요)

본문에서 참조하지 않지만 되살릴 때를 위해 남겨 둔 파일입니다.

- **Chapter 3 세 번째 섹션** (Notification 왕복, 삭제됨): `03-section3`(다이어그램) ·
  `03-s3-step1` · `03-s3-result`
- **Chapter 4 전체** (여러 마리로 늘리기, 삭제됨): `ch4-card` · `04-intro` ·
  `04-section1`~`section4` · `04-s1-result` · `04-s2-step1` · `04-s2-result` ·
  `04-s3-step1` · `04-s3-result` · `04-s4-step1`~`step3` · `04-s4-result`
- **옛 스텝**: `01-s2-step3`(Collision 스텝 — 지금은 Chapter 3의 `03-s2-step5`) ·
  `01-s2-step5` · `01-s2-step6` · `03-s1-step2`

`04-section1`·`04-section2`·`03-section3`은 스크린샷이 아니라 `Tools/MakeDiagrams.swift`가
그린 다이어그램입니다.

## 교체 후 확인

1. README의 "참조 무결성 검사"를 돌려 **누락이 0**인지 봅니다.
2. 미리보기로 눈으로 확인합니다.

   ```bash
   swift package --disable-sandbox preview-documentation --target RoomAquarium
   # http://localhost:8080/tutorials/roomaquarium
   ```
