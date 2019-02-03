![TingVFL logo](https://github.com/bestwnh/TinyVFL/blob/master/TinyVFL.png)
TinyVFL is a tiny library to replace the native virtual format language of Auto Layout. The native VFL is string-base and not user friendly in Swift. TingVFL implement with type safe method and easy to use.

### Sample Code
Original Virtual Format Language code(Old way):
```objc
NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1][view2(90)]-(space@750)-[view3(==view1)]",
                                         options: [.alignAllLeft, .alignAllRight],
                                         metrics: ["space": NSNumber(value: spaceValue)],
                                         views: ["view1": view1, "view2": view2, "view3": view3])
```
Virtual Format Language with TinyVFL:
```Swift
VFL.v(.superView,
      .space(),
      .view(view1),
      .view(view2, size: 90),
      .space(spaceValue, priority: 750),
      .view(view3, equal:view1))
    .withOptions([.alignAllLeft, .alignAllRight])
    .constraints
```
Even simplier:
```Swift
VFL.v(.top,
      .s(),
      .v(view1),
      .v(view2, 90),
      .s(spaceValue, p: .defaultHigh),
      .v(view3, e:view1))
    .withOptions([.alignAllLeft, .alignAllRight])
    .active()
```

#### More detail can be found in these articles:
- [TinyVFL: A safer virtual format language for Auto Layout](https://medium.com/@GalvinLi/tinyvfl-6b21110428e0)
- [TinyVFL: 更安全的Auto Layout Virtual Format Language实现](https://medium.com/@GalvinLi/tinyvfl-更安全的auto-layout-virtual-format-language实现-8d15b5db2aeb)

More similar articles can found in [TinySeries](https://medium.com/tag/tiny-series/latest)
