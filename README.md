<p align="center">
<img src="./Rem.png" width=425/>
<br>
Rem
<br>
<pre align="center">A maid helps you handle with launching Ads</pre>
</p>

[![Swift](https://img.shields.io/badge/Swift-3.0-green.svg)](https://github.com/apple/swift) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/CodeEagle/Rem/master/LICENSE) [![Build Status](https://travis-ci.org/CodeEagle/CacheLeaf.svg?branch=master)](https://travis-ci.org/CodeEagle/Rem)

Feature
---
- [x] Optional shows(1s) blank page when image not downloaded

- [x] Support tapping the content, showing countdown info or skip button

- [x] Support customize trademark

- [x] Show only once in app lifetime

- [x] Support Gif

Screenshot
---
<p align="center">
<img src="./RemWork.jpg" width=320/>
</p>

Usage
---
```swift
  import Rem
// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let ad = Rem.Work(...)// watch demo for detail
    Rem.show(advertisement: ad)
// return true
//}
```
install
---
###Carthage
```
github "CodeEagle/Rem"
```
Wiki
---
states For handling user event
```swift
  //Rem.Work.State
  public enum State { case complete, idle, blank, tap, skip }
```
Donations
---
<pre>
<p align="center">
<img src="https://raw.githubusercontent.com/CodeEagle/CacheLeaf/master/donate.jpg" width=320/>
</p>
</pre>
License
---
Rem is released under the MIT license. See LICENSE for details.
