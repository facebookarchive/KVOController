# [KVOController](https://github.com/facebook/KVOController)

Key-value observing is a particularly useful technique for communicating between layers in a Model-View-Controller application. KVOController builds on the time-tested Cocoa key-value observing implementation. It offers a simple, convenient API, that is also truly thread safe. Benefits include:

- Notification using blocks, custom actions, or NSKeyValueObserving callback.
- No exceptions on observer removal.
- Implicit observer removal on controller dealloc.
- Improved performance when using NSKeyValueObservingInitial.
- Thread-safety with special guards against observer resurection – [rdar://15985376](http://openradar.appspot.com/radar?id=5305010728468480).

For more information on KVO, see Apple's [Introduction to Key-Value Observing](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html).

## Usage

Example apps for iOS and OS X are included with the project. Here is one simple usage pattern:

```objective-c
// create KVO controller with observer
FBKVOController *KVOController = [FBKVOController controllerWithObserver:self];

// observe clock date property 
[KVOController observe:clock keyPath:@"date" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(ClockView *clockView, Clock *clock, NSDictionary *change) {

  // update clock view with new value
  clockView.date = change[NSKeyValueChangeNewKey];
}];
```

While simple, the above example is complete. A clock view creates a KVO controller to observe the clock date property. A block callback is used to handle initial and change notification. Unobservation happens implicitly on controller deallocation.

## Prerequisites

KVOController takes advantage of recent Objective-C runtime advances, including ARC and weak collections. It requires:

- iOS 6 or later.
- OS X 10.7 or later.

## Installation

Drag and drop FBKVOController.h and FBKVOControler.m into your Xcode project, agreeing to copy files if needed. Alternatively, for iOS applications, you can choose to link against the static library target of the KVOController project.

## Testing

The unit tests included use CocoaPods for managing depenendecies. Install CocoaPods if you haven't already done so. Then, at the command line, navigate to the root KVOController directory and type:

```sh
pod install
```

This will install and add test dependencies on OCHamcrest and OCMockito. Re-open the Xcode KVOController workspace and Test, ⌘U.

## Licence

KVOController is released under the BSD License.
