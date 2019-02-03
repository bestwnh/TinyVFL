//
//  TinyVFL.swift
//  TinyVFL
//
//  Created by Galvin on 2019/1/18.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

#if canImport(AppKit)
import AppKit
public typealias VFLView = NSView
public typealias LayoutPriority = NSLayoutConstraint.Priority
#elseif canImport(UIKit)
import UIKit
public typealias VFLView = UIView
public typealias LayoutPriority = UILayoutPriority
#endif

public struct VFL {
    let direction: Direction
    let items: [VFLItem]
    var options: NSLayoutConstraint.FormatOptions
    
    private init(direction: Direction, items: [VFLItem], options: NSLayoutConstraint.FormatOptions) {
        self.direction = direction
        self.items = items
        self.options = options
        validateItems()
        validateOptions()
    }
    
    private func validateItems() {
        if items.dropFirst().dropLast().contains(where: {
            if case VFLItem.Content.superView = $0.content { return true } else { return false }
        }) {
            preconditionFailure("Super view should only at the start or end.")
        }
        
        if [items.first, items.last].compactMap({ $0 }).contains(where: {
            if case VFLItem.Content.space = $0.content { return true } else { return false }
        }) {
            preconditionFailure("Space should not at the start or end.")
        }
        
        for (index, item) in items.enumerated() {
            guard index > 0 else { continue }
            switch (items[index-1].content, item.content) {
            case (.space, .space):
                preconditionFailure("Should not have two continue spaces.")
            default:
                break
            }
        }
    }
    
    private func validateOptions() {
        let validOptions: NSLayoutConstraint.FormatOptions = {
            switch direction {
            case .horizontal:
                return [
                    .alignAllTop,
                    .alignAllBottom,
                    .alignAllCenterY,
                    .alignAllLastBaseline,
                    .alignAllFirstBaseline,
                    .directionLeadingToTrailing,
                ]
            case .vertical:
                var opt: NSLayoutConstraint.FormatOptions = [
                    .alignAllLeft,
                    .alignAllRight,
                    .alignAllLeading,
                    .alignAllTrailing,
                    .alignAllCenterX,
                    ]
                #if os(iOS)
                if #available(iOS 11.0, *) {
                    opt.insert(.spacingBaselineToBaseline)
                }
                #endif
                return opt
            }
        }()
        if !options.isSubset(of: validOptions) {
            preconditionFailure("NSLayoutConstraint.FormatOptions set in wrong direction.")
        }
    }
}

extension VFL {
    enum Direction {
        case vertical
        case horizontal
        var string: String {
            switch self {
            case .vertical:
                return "V:"
            case .horizontal:
                return "H:"
            }
        }
    }
}

public extension VFL {
    static func v(_ items: VFLItem..., options: NSLayoutConstraint.FormatOptions = []) -> VFL {
        return VFL(direction: .vertical, items: items, options:options)
    }
    static func h(_ items: VFLItem..., options: NSLayoutConstraint.FormatOptions = []) -> VFL {
        return VFL(direction: .horizontal, items: items, options:options)
    }
    func withOptions(_ options: NSLayoutConstraint.FormatOptions) -> VFL {
        return VFL(direction: direction, items: items, options:options)
    }
    func active() {
        NSLayoutConstraint.activate(constraints)
    }
    
    var constraints: [NSLayoutConstraint] {
        let views = Dictionary(uniqueKeysWithValues: items.compactMap{ $0.view }.map({ ("view\($0.hashValue)", $0) }))
        
        let format = "\(direction.string)\(items.map({ $0.string }).joined())"
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: views)
    }
}

extension VFLView {
    var vflName: String {
        return "view\(hashValue)"
    }
}

public struct VFLItem {
    let content: Content
}

extension VFLItem {
    enum Content {
        case view(VFLView, size: Size?)
        case superView
        case space(Space)
    }
    struct Size {
        let content: Content
        enum Content {
            case size(Space)
            case sizeEqual(VFLView, priority: LayoutPriority?)
        }
        static func size(_ size: Double, priority: LayoutPriority? = nil) -> Size {
            return .init(content: Content.size(.space(size, priority: priority)))
        }
        static func size(equal view: VFLView, priority: LayoutPriority? = nil) -> Size {
            return .init(content: Content.sizeEqual(view, priority: priority))
        }
        var string: String {
            switch content {
            case let .size(space):
                return space.vflSizeString
            case let .sizeEqual(view, .none):
                return "(==\(view.vflName))"
            case let .sizeEqual(view, .some(priority)):
                return "(==\(view.vflName)@\(priority.rawValue))"
            }
        }
    }
    struct Space {
        let space: Double?
        let priority: LayoutPriority?
        static func space(_ space: Double, priority: LayoutPriority? = nil) -> Space {
            return .init(space: space, priority: priority)
        }
        static func space(_ space: Double?) -> Space {
            return .init(space: space, priority: nil)
        }
        var vflSizeString: String {
            guard let space = space else {
                return ""
            }
            
            guard let priority = priority else {
                return "(\(space))"
            }
            
            return "(\(space)@\(priority.rawValue))"
        }
        var vflSpaceString: String {
            guard vflSizeString != "" else {
                return "-"
            }
            
            return "-\(vflSizeString)-"
        }
    }
}

public extension VFLItem {
    static var superView: VFLItem {
        return .init(content: Content.superView)
    }
    static func view(_ view: VFLView, size: Double? = nil) -> VFLItem {
        let viewSize: Size? = {
            if let size = size {
                return .size(size)
            } else {
                return nil
            }
        }()
        return .init(content: Content.view(view, size: viewSize))
    }
    static func view(_ view: VFLView, size: Double, priority: LayoutPriority? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(size, priority: priority)))
    }
    static func view(_ view: VFLView, equal equalView: VFLView, priority: LayoutPriority? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(equal: equalView, priority: priority)))
    }
    static func space(_ space: Double? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space)))
    }
    static func space(_ space: Double, priority: LayoutPriority? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space, priority: priority)))
    }
    
    static var top: VFLItem { return .superView }
    static var bottom: VFLItem { return .superView }
    static var left: VFLItem { return .superView }
    static var right: VFLItem { return .superView }
    static func v(_ view: VFLView, _ size: Double? = nil) -> VFLItem {
        return .view(view, size: size)
    }
    static func v(_ view: VFLView, _ size: Double, p priority: LayoutPriority? = nil) -> VFLItem {
        return .view(view, size: size, priority: priority)
    }
    static func v(_ view: VFLView, e equalView: VFLView, p priority: LayoutPriority? = nil) -> VFLItem {
        return .view(view, equal: equalView, priority: priority)
    }
    static func s(_ space: Double? = nil) -> VFLItem {
        return .space(space)
    }
    static func s(_ space: Double, p priority: LayoutPriority? = nil) -> VFLItem {
        return .space(space, priority: priority)
    }
    
    var string: String {
        switch content {
        case let .view(view, .none):
            return "[\(view.vflName)]"
        case let .view(view, .some(size)):
            return "[\(view.vflName)\(size.string)]"
        case .superView:
            return "|"
        case let .space(space):
            return space.vflSpaceString
        }
    }
    var view: VFLView? {
        switch content {
        case let .view(view, _):
            return view
        default:
            return nil
        }
    }
}

extension LayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Float) {
        self.init(value)
    }
    public init(integerLiteral value: Int) {
        self.init(Float(value))
    }
}
