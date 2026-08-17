import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

let W = 900, H = 560

func draw(name: String, desc: String, to url: URL) {
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: W, height: H,
                              bitsPerComponent: 8, bytesPerRow: 0,
                              space: cs,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }

    // 바깥 배경
    ctx.setFillColor(CGColor(red: 0.055, green: 0.141, blue: 0.224, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

    // 안쪽 패널
    let inset = CGRect(x: 20, y: 20, width: W - 40, height: H - 40)
    ctx.setFillColor(CGColor(red: 0.071, green: 0.188, blue: 0.302, alpha: 1))
    ctx.fill(inset)
    ctx.setStrokeColor(CGColor(red: 0.290, green: 0.624, blue: 0.878, alpha: 1))
    ctx.setLineWidth(1.5)
    ctx.stroke(inset)

    func line(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, color: CGColor) {
        let font = CTFontCreateWithName("AppleSDGothicNeo-Regular" as CFString, size, nil)
        let attrs: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: color,
        ]
        guard let attributed = CFAttributedStringCreate(
            nil, text as CFString, attrs as CFDictionary) else { return }
        let line = CTLineCreateWithAttributedString(attributed)
        ctx.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(line, ctx)
    }

    line("PLACEHOLDER", x: 38, y: CGFloat(H) - 254,
         size: 13, color: CGColor(red: 0.435, green: 0.659, blue: 0.847, alpha: 1))
    line("\(name).png", x: 38, y: CGFloat(H) - 296,
         size: 14, color: CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    line(desc, x: 38, y: CGFloat(H) - 322,
         size: 13, color: CGColor(red: 0.784, green: 0.855, blue: 0.925, alpha: 1))

    guard let image = ctx.makeImage(),
          let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
    else { return }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// 인자: <출력디렉터리> 그리고 "이름|설명" 쌍들
let args = CommandLine.arguments
guard args.count >= 3 else {
    FileHandle.standardError.write("usage: MakePlaceholder <outdir> 'name|desc' ...\n".data(using: .utf8)!)
    exit(1)
}
let outDir = URL(fileURLWithPath: args[1])
for spec in args.dropFirst(2) {
    let parts = spec.split(separator: "|", maxSplits: 1).map(String.init)
    guard parts.count == 2 else { continue }
    draw(name: parts[0], desc: parts[1], to: outDir.appendingPathComponent(parts[0] + ".png"))
    print("wrote \(parts[0]).png")
}
