# ``RoomAquarium``

A tutorial that builds an aquarium inside your room on iPad, using
RealityKit and Reality Composer Pro.

## Overview

A four-chapter, hands-on tutorial for people meeting RealityKit for the
first time. You start by assembling a 3D scene in Reality Composer Pro,
load it with SwiftUI's `RealityView`, place it in your real room with
camera passthrough, and end with a school of seahorses swimming around,
driven by a custom component and a System.

The thread running through all of it is **the boundary between RCP and
code**. It follows the structure shown in the WWDC24 session
[Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)
and its official sample.

- Shape, placement, performance, and its timing are authored in **RCP**.
- Managing many of something and advancing state every frame belongs to **code**.
- The two talk in both directions: behaviors (code → RCP) and notifications (RCP → code).

Chapters 1 and 2 can be finished in the simulator; from the camera
passthrough in Chapter 3 on, you need a real device (iPad).

- Requirements: written against Xcode 26 · deployment target iOS/iPadOS 18 or later
- Finished project and assets: [konghee/SpatialComputing](https://github.com/konghee/SpatialComputing)

## Topics

### Tutorials

- <doc:/tutorials/RoomAquarium>
