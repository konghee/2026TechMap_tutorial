# ``RoomAquarium``

A tutorial that builds an aquarium inside your room on iPad, using
RealityKit and Reality Composer Pro.

## Overview

A three-chapter, hands-on tutorial for people meeting RealityKit for the
first time. You start by assembling a 3D scene in Reality Composer Pro,
load it with SwiftUI's `RealityView`, bring the seahorse to life with a
timeline and a behavior, and end by floating the whole thing in your real
room with camera passthrough and making it respond to a tap.

The thread running through all of it is **the boundary between RCP and
code**. It follows the structure shown in the WWDC24 session
[Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)
and its official sample.

- Shape, placement, motion, sound, and their timing are built in **RCP**.
- Putting it on screen, choosing the camera, and passing on the user's tap belong to **code**.
- When code hands over a tap (`applyTapForBehaviors()`), the performance you built
  in RCP plays. So changing that performance doesn't require opening Xcode.

Chapters 1 and 2 can be finished in the simulator; only the camera
passthrough in Chapter 3 needs a real device (iPhone or iPad).

- Requirements: written against Xcode 26 · deployment target iOS/iPadOS 18 or later
- Assets: the seahorse model comes from the [AR Quick Look Gallery](https://developer.apple.com/augmented-reality/quick-look/),
  and the whale call from Reality Composer Pro's Asset Library.

## Topics

### Tutorials

- <doc:/tutorials/RoomAquarium>
