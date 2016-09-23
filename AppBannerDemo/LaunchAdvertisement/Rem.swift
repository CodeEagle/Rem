//
//  LaunchAdvertisement.swift
//  AppBannerDemo
//
//  Created by LawLincoln on 2016/9/20.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit

// MARK: - Rem
final public class Rem {
    
    internal static var shared: Rem! = Rem()
    static internal func gotAHappyEnding() { shared = nil }
    private var ad: Work!
    private var activeCount = 0
    private var showingBlank = false
    private weak var countdownLabel: CATextLayer?
    private weak var skipButton: UIButton?
    private var totalTime = 0
    internal let activeAfterInit = 2
    deinit { NotificationCenter.default.removeObserver(self) }
    private init() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) {[weak self] (_) in
            guard let sself = self else { return }
            sself.activeCount += 1
            if sself.activeCount == 1 { return }
            sself.work()
        }
    }
    // MARK: - Public
    
    public class func handle(work stuff: Work) {
        Rem.shared.handle(work: stuff)
    }
    
    private func handle(work stuff: Work) {
        ad = stuff
        work()
    }
    
    public class func cleanHouse() {
        DispatchQueue.global(qos: .default).async {
            let fm = FileManager.default
            let tmp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first!
            let pre = "Launch_"
            let sub = ".jpg"
            do {
                let contents = try fm.contentsOfDirectory(atPath: tmp)
                for item in contents {
                    guard item.hasPrefix(pre) , item.hasSuffix(sub) else { continue }
                    let p = (tmp as NSString).appendingPathComponent(item)
                    try fm.removeItem(atPath: p)
                }
            } catch { }
        }
    }
    
    // MARK: - Private
    private func work() {
        let url = ad.url
        var bg = image(for: url)
        var duration = ad.duration
        if ad.showBlank && bg == nil {
            bg = NSData()
            duration = 1
            showingBlank = true
            store(image: url)
        }
        if let image = bg { processToShow(image: image, duration: duration) }
        else {
            if activeCount < 2 { ad.complete?(.idle) }
            store(image: url)
        }
    }
    
    private func processToShow(image: NSData?, duration: Int) {
        let topVC = topMostViewController
        let bg = UIImageView()
        bg.load(data: image)
        bg.backgroundColor = UIColor.white
        bg.frame = UIScreen.main.bounds
        bg.contentMode = ad.contentMode
        if let over = ad.image { bg.addSubview(over) }
        if !showingBlank {
            if case Work.Extra.countdown(let postion) = ad.enableCountdown {
                let rect = postion.rect.insetBy(dx: 0, dy: 6)
                let label = CATextLayer()
                label.frame = rect
                label.contentsScale = UIScreen.main.scale
                label.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
                label.alignmentMode = "center"
                label.fontSize = rect.size.height - 4
                label.cornerRadius = rect.height / 2
                label.foregroundColor = UIColor.white.cgColor
                label.masksToBounds = true
                bg.layer.addSublayer(label)
                countdownLabel = label
                totalTime = ad.duration
                count()
            }
            if case Work.Extra.skip(let postion) = ad.enableSkip {
                let rect = postion.rect
                let label = UIButton(frame: rect)
                label.backgroundColor = UIColor(white: 1, alpha: 0.9)
                label.contentHorizontalAlignment = .center
                label.layer.borderWidth = 0.5
                label.layer.borderColor = UIColor.lightGray.cgColor
                label.layer.cornerRadius = rect.height / 2
                label.clipsToBounds = true
                label.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                label.setTitleColor(UIColor.darkGray, for: .normal)
                label.addTarget(self, action: #selector(Rem.skip(button:)), for: .touchUpInside)
                let cn = Locale.current.identifier.contains("zh")
                let title = cn ? "跳过" : "Skip"
                label.setTitle(title, for: .normal)
                bg.addSubview(label)
                skipButton = label
            }
        }
        topVC.view.addSubview(bg)
        let dispatchTime: DispatchTime = DispatchTime.now() + .seconds(duration)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {[weak self] in
            guard let sself = self else { return }
            bg.fadeOut()
            if sself.showingBlank {
                sself.showingBlank = false
                sself.ad.complete?(.blank)
                return
            }
            if sself.activeCount < sself.activeAfterInit { sself.ad.complete?(.complete) }
            Rem.gotAHappyEnding()
        })
        if ad.enableTap {
            let tap = UITapGestureRecognizer(target: self, action: #selector(Rem.tap(gesture:)))
            bg.isUserInteractionEnabled = true
            bg.addGestureRecognizer(tap)
        }
    }
    
    @objc private func skip(button: UIButton) {
        if showingBlank { return }
        button.superview?.fadeOut()
        ad.complete?(.skip)
        Rem.gotAHappyEnding()
    }
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        if showingBlank { return }
        gesture.view?.fadeOut()
        ad.complete?(.tap)
        Rem.gotAHappyEnding()
    }
    
    // MARK:  Help
    private func path(for url: String) -> String {
        let tmp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first!
        let name = "Launch_\(url.hash)_.jpg"
        return (tmp as NSString).appendingPathComponent(name)
    }
    
    private func image(for url: String) -> NSData? {
        let file = path(for: url)
        return NSData(contentsOfFile: file)
    }
    
    private func store(image url: String) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let value = URL(string: url) else { return }
                let filePath = self.path(for: url)
                guard let data = NSData(contentsOf: value) else { return }
                let aurl = URL(fileURLWithPath: filePath)
                try data.write(to: aurl)
            } catch { print("😠 \(error)")}
        }
    }
    
    private var topMostViewController: UIViewController {
        var root = UIApplication.shared.windows.first?.rootViewController
        while(root == nil) { root = UIApplication.shared.windows.first?.rootViewController }
        var topController: UIViewController? = root
        while (topController?.presentedViewController != nil) { topController = topController?.presentedViewController }
        return topController!
    }
    
    private func count() {
        if totalTime <= 0 { return }
        countdownLabel?.string = "\(totalTime)"
        let dispatchTime: DispatchTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {[weak self] in
            guard let sself = self else { return }
            sself.totalTime -= 1
            sself.count()
            sself.countdownLabel?.string = "\(sself.totalTime)"
        })
    }
    
    // MARK: - Work
    public struct Work {
        public enum Extra {
            public enum Position {
                case topLeft, topRight, bottomLeft, bottomRight
                var rect: CGRect {
                    let size = UIScreen.main.bounds.size
                    var x: CGFloat = 0
                    var y = x, width = x, height = x
                    width = 50
                    height = 35
                    switch self {
                    case .topLeft:
                        x = 10
                        y = 10
                    case .topRight:
                        x = size.width - width - 10
                        y = 10
                    case .bottomRight:
                        x = size.width - width - 10
                        y = size.height - height - 10
                    case .bottomLeft:
                        x = 10
                        y = size.height - height - 10
                    }
                    return CGRect(x: x, y: y, width: width, height: height)
                }
            }
            case none
            case countdown(Position)
            case skip(Position)
        }
        public enum State { case complete, idle, blank, tap, skip }
        fileprivate let url: String
        fileprivate let duration: Int
        fileprivate let image: UIImageView?
        fileprivate let showBlank: Bool
        fileprivate let enableTap: Bool
        fileprivate let contentMode: UIViewContentMode
        fileprivate let complete: ((State) -> ())?
        fileprivate let enableCountdown: Extra
        fileprivate let enableSkip: Extra
        public init(url: String, duration: Int, showBlank: Bool = false, imageOverBanner: UIImageView? = nil, enableTap: Bool = false, contentMode: UIViewContentMode = .scaleAspectFill, countdown: Extra = .none,
                    skip: Extra = .none, complete: ((State) -> ())? = nil) {
            self.url = url
            self.duration = duration
            self.showBlank = showBlank
            image = imageOverBanner
            self.contentMode = contentMode
            self.enableTap = enableTap
            self.complete = complete
            enableCountdown = countdown
            enableSkip = skip
        }
    }
}

// MARK: - Extensions
// MARK: NSData
fileprivate extension NSData {
    var isGif: Bool {
        let b = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        b.initialize(to: 1)
        getBytes(b, length: 1)
        return b.pointee ==  0x47
    }
}
// MARK: UIView
fileprivate extension UIView {
    
    func fadeOut() {
        let animations = {
            self.layer.opacity = 0
            self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
        }
        UIView.animate(withDuration: 0.2,
                       animations: animations,
                       completion: {[weak self] (_) in self?.removeFromSuperview() })
    }
}
// MARK: - Gif

// https://github.com/bahlo/SwiftGif/blob/master/SwiftGifCommon/UIImage%2BGif.swift
import UIKit
import ImageIO
extension UIImageView {
    
    fileprivate func load(data: NSData?) {
        DispatchQueue.global().async {
            guard let d = data as? Data else { return }
            let image = data?.isGif == true ? UIImage.gif(data: d) : UIImage(data: d)
            DispatchQueue.main.async { self.image = image }
        }
    }
}

extension UIImage {
    
    fileprivate class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        return UIImage.animatedImageWithSource(source)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false { return delay }
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        delay = delayObject as? Double ?? 0
        if delay < 0.1 { delay = 0.1 } // Make sure they're not too fast
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! { swap(&a, &b) }
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            if rest == 0 { return b! }// Found it  
            else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty { return 1 }
        var gcd = array[0]
        for val in array { gcd = UIImage.gcdForPair(val, gcd) }
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) { images.append(image) }
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        // Calculate full duration
        let duration = delays.reduce(0, +)
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        // Heyhey
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        return animation
    }
}
