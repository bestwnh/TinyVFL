//
//  TinyVFL.swift
//  TinyVFL
//
//  Created by Galvin on 2019/1/18.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

import UIKit

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

extension UIView {
    var vflName: String {
        return "view\(hashValue)"
    }
}

public struct VFLItem {
    let content: Content
}

extension VFLItem {
    enum Content {
        case view(UIView, size: Size?)
        case superView
        case space(Space)
    }
    struct Size {
        let content: Content
        enum Content {
            case size(Space)
            case sizeEqual(UIView, priority: Double?)
        }
        static func size(_ size: Double, priority: Double? = nil) -> Size {
            return .init(content: Content.size(.space(size, priority: priority)))
        }
        static func size(equal view: UIView, priority: Double? = nil) -> Size {
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
    static func view(_ view: UIView, size: Double? = nil) -> VFLItem {
        let viewSize: Size? = {
            if let size = size {
                return .size(size)
            } else {
                return nil
            }
        }()
        return .init(content: Content.view(view, size: viewSize))
    }
    static func view(_ view: UIView, size: Double, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(size, priority: priority)))
    }
    static func view(_ view: UIView, equal equalView: UIView, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.view(view, size: .size(equal: equalView, priority: priority)))
    }
    static func space(_ space: Double? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space)))
    }
    static func space(_ space: Double, priority: Double? = nil) -> VFLItem {
        return .init(content: Content.space(.space(space, priority: priority)))
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
    var view: UIView? {
        switch content {
        case let .view(view, _):
            return view
        default:
            return nil
        }
    }
}
