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
#elseif canImport(UIKit)
import UIKit
public typealias VFLView = UIView
#endif

public struct VFL {
    let direction: Direction
    let items: [VFLItem]
    var options: NSLayoutConstraint.FormatOptions
    
    private init(direction: Direction, items: [VFLItem], options: NSLayoutConstraint.FormatOptions) {
        self.direction = direction
        self.items = items
        self.options = options
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
        NSLayoutConstraint.activate(self.constraints)
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
            case sizeEqual(VFLView, priority: Double?)
        }
        static func size(_ size: Double, priority: Double? = nil) -> Size {
            return .init(content: Content.size(.space(size, priority: priority)))
        }
        static func size(equal view: VFLView, priority: Double? = nil) -> Size {
            return .init(content: Content.sizeEqual(view, priority: priority))
        }
        var string: String {
            switch content {
            case let .size(space):
                return space.vflSizeString
            case let .sizeEqual(view, .none):
                return "(==\(view.vflName))"
            case let .sizeEqual(view, .some(priority)):
                return "(==\(view.vflName)@\(priority))"
            }
        }
    }
    struct Space {
        let space: Double?
        let priority: Double?
        static func space(_ space: Double, priority: Double? = nil) -> Space {
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
            
            return "(\(space)@\(priority))"
        }
        var vflSpaceString: String {
            let sizeString = self.vflSizeString
            guard sizeString != "" else {
                return "-"
            }
            
            return "-\(sizeString)-"
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
    static func view(_ view: VFLView, size: Double, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(size, priority: priority)))
    }
    static func view(_ view: VFLView, equal equalView: VFLView, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(equal: equalView, priority: priority)))
    }
    static func space(_ space: Double? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space)))
    }
    static func space(_ space: Double, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space, priority: priority)))
    }
    
    static var top: VFLItem { return .superView }
    static var bottom: VFLItem { return .superView }
    static var left: VFLItem { return .superView }
    static var right: VFLItem { return .superView }
    static func v(_ view: VFLView, _ size: Double? = nil) -> VFLItem {
        return .view(view, size: size)
    }
    static func v(_ view: VFLView, _ size: Double, p priority: Double? = nil) -> VFLItem {
        return .view(view, size: size, priority: priority)
    }
    static func v(_ view: VFLView, e equalView: VFLView, p priority: Double? = nil) -> VFLItem {
        return .view(view, equal: equalView, priority: priority)
    }
    static func s(_ space: Double? = nil) -> VFLItem {
        return .space(space)
    }
    static func s(_ space: Double, p priority: Double? = nil) -> VFLItem {
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
