// 스크린샷으로는 찍을 수 없는 다이어그램들을 코드로 그립니다.
//
//   xcrun --toolchain XcodeDefault swiftc -O MakeDiagrams.swift -o makediagrams
//   ./makediagrams ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
//
// 만들어지는 것:
//   03-section3.png  타임라인의 Notification 액션이 코드에 도착하는 흐름
//   04-section1.png  원점을 비워둔 도넛 배치 (위에서 내려다본 그림)
//   04-section2.png  설정 컴포넌트 / System / 런타임 컴포넌트의 관계
//
// 모두 900×560을 2배(1800×1120)로 렌더링해 레티나에서도 글자가 또렷합니다.
// placeholder 생성기가 이 파일들을 덮어쓰지 않도록,
// sync-placeholder-list.py 의 HANDMADE 집합에 세 이름이 등록돼 있습니다.

import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

// MARK: - 팔레트

func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
}

let bg       = rgb(255, 255, 255)
let ink      = rgb( 28,  32,  38)
let inkSoft  = rgb(104, 112, 124)
let rule     = rgb(206, 212, 220)
let faint    = rgb(226, 230, 236)

let rcpTint  = rgb(243, 245, 248)
let rcpEdge  = rgb(180, 188, 199)

let cfgTint  = rgb(232, 243, 254)          // 설정 컴포넌트 — 파랑
let cfgEdge  = rgb( 58, 138, 214)
let cfgText  = rgb( 21,  82, 140)

let stateTint = rgb(255, 243, 224)         // 런타임 컴포넌트 — 주황
let stateEdge = rgb(224, 148,  34)
let stateText = rgb(140,  86,   8)

let sysTint  = rgb( 44,  50,  60)          // System — 어두운 중립
let sysText  = rgb(255, 255, 255)

let violet   = rgb(124,  84, 214)          // SeahorseStartled
let violetBg = rgb(240, 235, 253)
let teal     = rgb( 15, 137, 138)          // SeahorseCalmed
let tealBg   = rgb(226, 244, 244)

let codeBg   = rgb( 30,  34,  42)
let codeInk  = rgb(226, 232, 240)
let codeDim  = rgb(138, 148, 164)

// MARK: - 캔버스

let W: CGFloat = 900
let H: CGFloat = 560
let SCALE: CGFloat = 2

enum Align { case left, center, right }

final class Canvas {
    let ctx: CGContext

    init() {
        guard let c = CGContext(data: nil,
                                width: Int(W * SCALE), height: Int(H * SCALE),
                                bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { fatalError("CGContext 생성 실패") }
        ctx = c
        ctx.scaleBy(x: SCALE, y: SCALE)
        ctx.setFillColor(bg)
        ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    }

    @discardableResult
    func text(_ s: String, x: CGFloat, y: CGFloat, size: CGFloat,
              color: CGColor, bold: Bool = false, mono: Bool = false,
              align: Align = .left) -> CGFloat {
        let name = mono ? (bold ? "Menlo-Bold" : "Menlo-Regular")
                        : (bold ? "AppleSDGothicNeo-Bold" : "AppleSDGothicNeo-Regular")
        let font = CTFontCreateWithName(name as CFString, size, nil)
        let attrs: [CFString: Any] = [kCTFontAttributeName: font,
                                      kCTForegroundColorAttributeName: color]
        guard let attr = CFAttributedStringCreate(nil, s as CFString, attrs as CFDictionary)
        else { return 0 }
        let line = CTLineCreateWithAttributedString(attr)
        let w = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        var dx = x
        if align == .center { dx = x - w / 2 }
        if align == .right  { dx = x - w }
        ctx.textPosition = CGPoint(x: dx, y: y)
        CTLineDraw(line, ctx)
        return w
    }

    func box(_ r: CGRect, fill: CGColor, stroke: CGColor? = nil,
             dashed: Bool = false, radius: CGFloat = 10, lineWidth: CGFloat = 1.5) {
        let p = CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
        ctx.addPath(p); ctx.setFillColor(fill); ctx.fillPath()
        if let stroke {
            ctx.saveGState()
            if dashed { ctx.setLineDash(phase: 0, lengths: [5, 4]) }
            ctx.addPath(p); ctx.setStrokeColor(stroke); ctx.setLineWidth(lineWidth); ctx.strokePath()
            ctx.restoreGState()
        }
    }

    func circle(center: CGPoint, radius: CGFloat, fill: CGColor? = nil,
                stroke: CGColor? = nil, dashed: Bool = false, lineWidth: CGFloat = 1.5) {
        let r = CGRect(x: center.x - radius, y: center.y - radius,
                       width: radius * 2, height: radius * 2)
        if let fill { ctx.setFillColor(fill); ctx.fillEllipse(in: r) }
        if let stroke {
            ctx.saveGState()
            if dashed { ctx.setLineDash(phase: 0, lengths: [6, 5]) }
            ctx.setStrokeColor(stroke); ctx.setLineWidth(lineWidth); ctx.strokeEllipse(in: r)
            ctx.restoreGState()
        }
    }

    func arrowHead(at p: CGPoint, dir: CGVector, color: CGColor, size: CGFloat = 8) {
        ctx.saveGState()
        ctx.translateBy(x: p.x, y: p.y)
        ctx.rotate(by: atan2(dir.dy, dir.dx))
        ctx.beginPath()
        ctx.move(to: .zero)
        ctx.addLine(to: CGPoint(x: -size, y: size * 0.5))
        ctx.addLine(to: CGPoint(x: -size, y: -size * 0.5))
        ctx.closePath()
        ctx.setFillColor(color); ctx.fillPath()
        ctx.restoreGState()
    }

    func polyline(_ pts: [CGPoint], color: CGColor, width: CGFloat = 1.8,
                  dashed: Bool = false, head: Bool = true) {
        guard pts.count >= 2 else { return }
        ctx.saveGState()
        if dashed { ctx.setLineDash(phase: 0, lengths: [5, 4]) }
        ctx.setStrokeColor(color); ctx.setLineWidth(width)
        ctx.setLineJoin(.round); ctx.setLineCap(.round)
        ctx.beginPath(); ctx.move(to: pts[0])
        for p in pts.dropFirst() { ctx.addLine(to: p) }
        ctx.strokePath()
        ctx.restoreGState()
        if head {
            let a = pts[pts.count - 2], b = pts[pts.count - 1]
            let d = CGVector(dx: b.x - a.x, dy: b.y - a.y)
            let len = max(hypot(d.dx, d.dy), 0.001)
            arrowHead(at: b, dir: CGVector(dx: d.dx / len, dy: d.dy / len), color: color)
        }
    }

    func title(_ t: String, _ sub: String) {
        text(t, x: 56, y: H - 62, size: 26, color: ink, bold: true)
        text(sub, x: 56, y: H - 88, size: 14, color: inkSoft)
        ctx.setStrokeColor(rule); ctx.setLineWidth(1)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: 56, y: H - 104))
        ctx.addLine(to: CGPoint(x: W - 56, y: H - 104))
        ctx.strokePath()
    }

    func footer(_ s: String) {
        text(s, x: W / 2, y: 30, size: 12, color: inkSoft, align: .center)
    }

    func write(_ name: String, to dir: URL) {
        let url = dir.appendingPathComponent(name + ".png")
        guard let image = ctx.makeImage(),
              let dest = CGImageDestinationCreateWithURL(
                url as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { fatalError("이미지 생성 실패: \(name)") }
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
        print("wrote \(name).png  (\(Int(W * SCALE))×\(Int(H * SCALE)))")
    }
}

// MARK: - 03-section3 · Notification 왕복

func drawNotificationFlow(to dir: URL) {
    let c = Canvas()
    c.title("\"언제\"는 RCP가, \"무엇을\"은 코드가",
            "타임라인에 놓은 Notification 액션이 그 시각에 앱으로 도착한다")

    // --- 타임라인 패널 ---
    let tl = CGRect(x: 56, y: 296, width: W - 112, height: 148)
    c.box(tl, fill: rcpTint, stroke: rcpEdge, radius: 8)
    c.text("TapSeahorse  타임라인", x: tl.minX + 16, y: tl.maxY - 26,
           size: 13, color: ink, bold: true)

    let t0 = tl.minX + 130            // 시각 0 의 x
    let t1 = tl.maxX - 150            // 시각 2.2 의 x (오른쪽에 라벨 자리를 남긴다)
    let span: CGFloat = 2.2
    func tx(_ t: CGFloat) -> CGFloat { t0 + (t / span) * (t1 - t0) }

    // 눈금 — 패널 위쪽에 둔다
    let rulerY = tl.maxY - 52
    for t in stride(from: CGFloat(0), through: 2.0, by: 0.5) {
        let x = tx(t)
        c.ctx.setStrokeColor(faint); c.ctx.setLineWidth(1)
        c.ctx.beginPath()
        c.ctx.move(to: CGPoint(x: x, y: rulerY - 4))
        c.ctx.addLine(to: CGPoint(x: x, y: tl.minY + 14))
        c.ctx.strokePath()
        c.text(String(format: "%.1f s", Double(t)), x: x, y: rulerY,
               size: 9.5, color: inkSoft, mono: true, align: .center)
    }

    // 트랙 3개
    let rowH: CGFloat = 22
    let rowY: [CGFloat] = [tl.maxY - 84, tl.maxY - 112, tl.maxY - 140]
    for (i, y) in rowY.enumerated() {
        c.text("Track \(i + 1)", x: tl.minX + 16, y: y + 7,
               size: 10.5, color: inkSoft, mono: true)
    }

    // Emphasize (spin)
    c.box(CGRect(x: tx(0.17), y: rowY[0], width: tx(1.17) - tx(0.17), height: rowH),
          fill: rgb(214, 226, 240), stroke: rgb(150, 174, 202), radius: 4, lineWidth: 1)
    c.text("Emphasize · Spin", x: tx(0.17) + 8, y: rowY[0] + 7,
           size: 10.5, color: rgb(46, 74, 108))

    // Play Audio
    c.box(CGRect(x: tx(0.17), y: rowY[1], width: tx(2.02) - tx(0.17), height: rowH),
          fill: rgb(214, 226, 240), stroke: rgb(150, 174, 202), radius: 4, lineWidth: 1)
    c.text("Play Audio · WhaleCry.usdz", x: tx(0.17) + 8, y: rowY[1] + 7,
           size: 10.5, color: rgb(46, 74, 108))

    // Notification 마커 — 라벨은 패널 안에 들어오도록 방향을 맞춘다
    func marker(_ t: CGFloat, _ label: String, _ color: CGColor,
                labelOnRight: Bool) -> CGPoint {
        let x = tx(t)
        c.box(CGRect(x: x - 5, y: rowY[2], width: 10, height: rowH), fill: color, radius: 3)
        c.text(label, x: labelOnRight ? x + 12 : x - 12, y: rowY[2] + 7,
               size: 10.5, color: color, mono: true, align: labelOnRight ? .left : .right)
        return CGPoint(x: x, y: rowY[2])
    }
    let mStart = marker(0.0, "SeahorseStartled", violet, labelOnRight: true)
    let mCalm  = marker(1.9, "SeahorseCalmed",  teal,   labelOnRight: true)

    // --- 코드 패널 ---
    let cp = CGRect(x: 56, y: 88, width: W - 112, height: 158)
    c.box(cp, fill: codeBg, radius: 8)
    c.text("AquariumView.swift", x: cp.minX + 20, y: cp.maxY - 24,
           size: 11, color: codeDim, mono: true)

    let lx = cp.minX + 20
    let lineY: [CGFloat] = [200, 178, 156, 134, 112, 94]
    c.text(".onReceive(notificationTrigger) { output in", x: lx, y: lineY[0],
           size: 11.5, color: codeInk, mono: true)
    c.text("    switch output.userInfo?[\"…Identifier\"] as? String {", x: lx, y: lineY[1],
           size: 11.5, color: codeInk, mono: true)
    c.text("    case \"SeahorseStartled\":", x: lx, y: lineY[2],
           size: 11.5, color: violet, mono: true)
    c.text("→  놀란 상태로", x: lx + 300, y: lineY[2], size: 11.5, color: codeDim)
    c.text("    case \"SeahorseCalmed\":", x: lx, y: lineY[3],
           size: 11.5, color: teal, mono: true)
    c.text("→  평소로", x: lx + 300, y: lineY[3], size: 11.5, color: codeDim)
    c.text("    }", x: lx, y: lineY[4], size: 11.5, color: codeInk, mono: true)
    c.text("}", x: lx, y: lineY[5], size: 11.5, color: codeInk, mono: true)

    // --- 마커 → 코드 패널 (겹치지 않게 패널 위 가장자리에서 끝낸다) ---
    for (m, color, t) in [(mStart, violet, "0.0 s"), (mCalm, teal, "1.9 s")] {
        c.polyline([CGPoint(x: m.x, y: m.y - 6), CGPoint(x: m.x, y: cp.maxY + 6)],
                   color: color, dashed: true)
        c.text(t, x: m.x + 10, y: (m.y + cp.maxY) / 2 - 4,
               size: 11, color: color, bold: true, mono: true)
    }
    c.text("같은 색끼리 짝", x: cp.midX, y: cp.maxY + 12,
           size: 11, color: inkSoft, align: .center)

    c.footer("연출을 0.5초 늦추고 싶으면 타임라인에서 액션을 끌어 옮기면 된다. 코드는 그대로다.")
    c.write("03-section3", to: dir)
}

// MARK: - 04-section1 · 도넛 배치

func drawDonut(to dir: URL) {
    let c = Canvas()
    c.title("원점을 비워둔 도넛 배치",
            "위에서 내려다본 그림 — 해마는 안쪽 원과 바깥 원 사이에서만 논다")

    let center = CGPoint(x: 292, y: 300)
    let pxPerM: CGFloat = 150 / 0.9          // roamRadius 0.9 m 를 150 px 로
    let rOuter = 0.9 * pxPerM
    let rSoft  = (0.9 - 0.25) * pxPerM
    let rInner = 0.25 * pxPerM

    c.circle(center: center, radius: rOuter, fill: rgb(247, 250, 253),
             stroke: cfgEdge, lineWidth: 2)
    c.circle(center: center, radius: rSoft, stroke: rgb(158, 190, 222),
             dashed: true, lineWidth: 1.5)
    c.circle(center: center, radius: rInner, fill: rgb(253, 235, 235),
             stroke: rgb(214, 122, 122), dashed: true, lineWidth: 1.5)

    // 해마 8마리 — 고정 배치라 매번 같은 그림이 나온다
    let seeds: [(CGFloat, CGFloat)] = [
        (0.35, 0.42), (1.05, 0.60), (1.85, 0.38), (2.60, 0.55),
        (3.35, 0.45), (4.10, 0.62), (4.90, 0.40), (5.70, 0.57),
    ]
    for (ang, rm) in seeds {
        let p = CGPoint(x: center.x + cos(ang) * rm * pxPerM,
                        y: center.y + sin(ang) * rm * pxPerM)
        c.circle(center: p, radius: 7, fill: stateEdge)
        c.circle(center: p, radius: 7, stroke: rgb(255, 255, 255), lineWidth: 2)
    }

    // 원점의 기기 — 이름표는 오른쪽 범례에 두어 그림 안이 깨끗하다
    c.box(CGRect(x: center.x - 12, y: center.y - 17, width: 24, height: 34),
          fill: sysTint, radius: 4)

    // 치수선 — 원 아래쪽에 두 줄로 쌓는다
    let bottom = center.y - rOuter
    let dim1 = bottom - 30
    let dim2 = bottom - 54
    c.ctx.setStrokeColor(faint); c.ctx.setLineWidth(1)
    c.ctx.beginPath()
    c.ctx.move(to: CGPoint(x: center.x, y: bottom - 4))
    c.ctx.addLine(to: CGPoint(x: center.x, y: dim2 - 6))
    c.ctx.strokePath()

    // 오른쪽에는 범례와 메모가 있으므로 치수선은 왼쪽으로 뽑는다.
    c.polyline([CGPoint(x: center.x, y: dim1), CGPoint(x: center.x - rOuter, y: dim1)],
               color: cfgEdge, width: 1.2)
    c.text("roamRadius  0.9 m", x: center.x - rOuter / 2, y: dim1 + 8,
           size: 11, color: cfgText, mono: true, align: .center)

    c.polyline([CGPoint(x: center.x, y: dim2), CGPoint(x: center.x - rInner, y: dim2)],
               color: rgb(196, 90, 90), width: 1.2)
    c.text("innerRadius  0.25 m", x: center.x - rInner - 12, y: dim2 - 4,
           size: 11, color: rgb(160, 60, 60), mono: true, align: .right)

    // --- 오른쪽 범례 ---
    let lx: CGFloat = 566
    var ly: CGFloat = 408

    func legend(_ swatch: CGColor, _ name: String, _ desc: String,
                dashed: Bool = false, square: Bool = false) {
        if square {
            c.box(CGRect(x: lx, y: ly - 1, width: 13, height: 15), fill: swatch, radius: 3)
        } else {
            c.circle(center: CGPoint(x: lx + 7, y: ly + 6), radius: 7,
                     fill: dashed ? nil : swatch, stroke: dashed ? swatch : nil,
                     dashed: dashed, lineWidth: 1.8)
        }
        c.text(name, x: lx + 26, y: ly + 9, size: 12.5, color: ink, bold: true, mono: true)
        c.text(desc, x: lx + 26, y: ly - 9, size: 11.5, color: inkSoft)
        ly -= 52
    }

    legend(sysTint,            "원점",          "앱을 켠 순간 기기가 있던 자리", square: true)
    legend(cfgEdge,            "roamRadius",    "0.9 m — 이 밖으로는 못 나간다")
    legend(rgb(158, 190, 222), "softMargin",    "0.25 m — 경계 전에 미리 돌아선다", dashed: true)
    legend(rgb(214, 122, 122), "innerRadius",   "0.25 m — 내 얼굴 자리, 비워 둔다", dashed: true)
    legend(stateEdge,          "seahorseCount", "8마리 — 이 고리 안에 흩어놓는다")

    // 메모
    let note = CGRect(x: lx, y: 82, width: 278, height: 74)
    c.box(note, fill: rgb(250, 250, 251), stroke: faint, radius: 8)
    c.ctx.setFillColor(cfgEdge)
    c.ctx.fill(CGRect(x: note.minX, y: note.minY + 10, width: 3, height: note.height - 20))
    c.text("기본값은 시뮬레이터 기준", x: note.minX + 16, y: note.maxY - 24,
           size: 12, color: ink, bold: true)
    c.text("창 안에서는 카메라가 원점 가까이 있다. 패스스루로", x: note.minX + 16, y: note.maxY - 43,
           size: 11, color: inkSoft)
    c.text("방 안에 설 때는 roamRadius를 2.0 쯤으로 키운다.", x: note.minX + 16, y: note.maxY - 60,
           size: 11, color: inkSoft)

    c.footer("안쪽을 비워두지 않으면 앱을 켠 자리 — 즉 내 얼굴이 있는 자리 — 에 해마가 생긴다.")
    c.write("04-section1", to: dir)
}

// MARK: - 04-section2 · 설정 / System / 런타임

func drawECS(to dir: URL) {
    let c = Canvas()
    c.title("설정은 RCP가, 상태는 코드가", "커스텀 컴포넌트를 둘로 나누면 생기는 구조")

    let colL: CGFloat = 56, colLW: CGFloat = 330
    let colR: CGFloat = 514, colRW: CGFloat = 330

    let rcpRect   = CGRect(x: colL, y: 392, width: colLW, height: 48)
    let cfgRect   = CGRect(x: colL, y: 266, width: colLW, height: 96)
    let sysRect   = CGRect(x: colL, y: 128, width: colLW, height: 96)
    let stateRect = CGRect(x: colR, y: 128, width: colRW, height: 96)
    let noteRect  = CGRect(x: colR, y: 266, width: colRW, height: 96)

    // RCP 인스펙터
    c.box(rcpRect, fill: rcpTint, stroke: rcpEdge, dashed: true)
    c.text("Reality Composer Pro 인스펙터", x: rcpRect.midX, y: rcpRect.midY + 3,
           size: 14, color: inkSoft, bold: true, align: .center)
    c.text("사람이 눈으로 보고 만지는 곳", x: rcpRect.midX, y: rcpRect.midY - 14,
           size: 11, color: inkSoft, align: .center)

    // 설정 컴포넌트
    c.box(cfgRect, fill: cfgTint, stroke: cfgEdge)
    c.text("SeahorseComponent", x: cfgRect.minX + 18, y: cfgRect.maxY - 28,
           size: 17, color: cfgText, bold: true)
    c.text("Component, Codable", x: cfgRect.minX + 18, y: cfgRect.maxY - 48,
           size: 11.5, color: cfgEdge, mono: true)
    c.text("swimSpeed · roamRadius · bobAmplitude …", x: cfgRect.minX + 18, y: cfgRect.maxY - 68,
           size: 11.5, color: inkSoft, mono: true)
    c.text("설정값 — RCP 인스펙터에 그대로 노출", x: cfgRect.minX + 18, y: cfgRect.minY + 12,
           size: 12, color: cfgText)

    // 런타임 컴포넌트
    c.box(stateRect, fill: stateTint, stroke: stateEdge)
    c.text("SeahorseRuntimeComponent", x: stateRect.minX + 18, y: stateRect.maxY - 28,
           size: 17, color: stateText, bold: true)
    c.text("Component  (Codable 아님)", x: stateRect.minX + 18, y: stateRect.maxY - 48,
           size: 11.5, color: stateEdge, mono: true)
    c.text("heading · bobPhase · currentState …", x: stateRect.minX + 18, y: stateRect.maxY - 68,
           size: 11.5, color: inkSoft, mono: true)
    c.text("상태 — RCP에 보이지 않음, 코드만 만짐", x: stateRect.minX + 18, y: stateRect.minY + 12,
           size: 12, color: stateText)

    // 메모
    c.box(noteRect, fill: rgb(250, 250, 251), stroke: faint)
    c.ctx.setFillColor(cfgEdge)
    c.ctx.fill(CGRect(x: noteRect.minX, y: noteRect.minY + 10, width: 3, height: noteRect.height - 20))
    c.text("나눠서 얻는 것", x: noteRect.minX + 18, y: noteRect.maxY - 26,
           size: 13, color: ink, bold: true)
    c.text("· 속도를 바꾸려고 Xcode를 열 필요가 없다", x: noteRect.minX + 18, y: noteRect.maxY - 50,
           size: 12, color: inkSoft)
    c.text("· 복제본 여덟 마리도 System이 알아서 맡는다", x: noteRect.minX + 18, y: noteRect.maxY - 70,
           size: 12, color: inkSoft)
    c.text("· 뷰 코드에는 \"상태를 만들어라\"가 한 줄도 없다", x: noteRect.minX + 18, y: noteRect.maxY - 90,
           size: 12, color: inkSoft)

    // System
    c.box(sysRect, fill: sysTint)
    c.text("SeahorseSystem", x: sysRect.minX + 18, y: sysRect.maxY - 30,
           size: 17, color: sysText, bold: true)
    c.text("System", x: sysRect.minX + 18, y: sysRect.maxY - 50,
           size: 11.5, color: rgb(168, 178, 192), mono: true)
    c.text("둘을 잇는 유일한 코드", x: sysRect.minX + 18, y: sysRect.minY + 14,
           size: 12, color: rgb(196, 204, 216))

    // ① RCP → 설정
    let ax = colL + 60
    c.polyline([CGPoint(x: ax, y: rcpRect.minY - 2), CGPoint(x: ax, y: cfgRect.maxY + 2)],
               color: rcpEdge, dashed: true)
    c.text("값 입력", x: ax + 12, y: (rcpRect.minY + cfgRect.maxY) / 2 - 4,
           size: 11.5, color: inkSoft)

    // ② 설정 → System
    c.polyline([CGPoint(x: ax, y: cfgRect.minY - 2), CGPoint(x: ax, y: sysRect.maxY + 2)],
               color: cfgEdge)
    c.text("ComponentEvents.DidAdd", x: ax + 12, y: (cfgRect.minY + sysRect.maxY) / 2 + 2,
           size: 11.5, color: cfgText, mono: true)
    c.text("씬에 붙는 순간 알려 온다", x: ax + 12, y: (cfgRect.minY + sysRect.maxY) / 2 - 14,
           size: 11, color: inkSoft)

    // ③ System → 런타임 (생성)
    let midX = (sysRect.maxX + stateRect.minX) / 2
    let createY = sysRect.midY + 4
    c.polyline([CGPoint(x: sysRect.maxX + 3, y: createY),
                CGPoint(x: stateRect.minX - 3, y: createY)], color: stateEdge)
    c.text("자동 생성", x: midX, y: createY + 26, size: 12, color: stateText,
           bold: true, align: .center)
    c.text("initialize()", x: midX, y: createY + 10, size: 11, color: stateEdge,
           mono: true, align: .center)

    // ④ 런타임 → System (매 프레임)
    let loopY: CGFloat = 74
    c.polyline([CGPoint(x: stateRect.midX, y: stateRect.minY - 2),
                CGPoint(x: stateRect.midX, y: loopY),
                CGPoint(x: sysRect.midX, y: loopY),
                CGPoint(x: sysRect.midX, y: sysRect.minY - 2)], color: sysTint)
    c.text("매 프레임  update() → swim()", x: (stateRect.midX + sysRect.midX) / 2, y: loopY + 10,
           size: 12, color: ink, bold: true, align: .center)

    c.footer("디자이너는 RCP에서 숫자만 만지고, 코드는 상태만 관리한다. "
           + "애플 샘플의 식물과 로봇이 전부 이 모양이다.")
    c.write("04-section2", to: dir)
}

// MARK: - 실행

let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
                 ? CommandLine.arguments[1] : ".")
drawNotificationFlow(to: outDir)
drawDonut(to: outDir)
drawECS(to: outDir)
