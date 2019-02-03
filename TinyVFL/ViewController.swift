//
//  ViewController.swift
//  TinyVFL
//
//  Created by Galvin on 2019/1/18.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        view1.translatesAutoresizingMaskIntoConstraints = false;
        view2.translatesAutoresizingMaskIntoConstraints = false;
        view3.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(view1)
        view.addSubview(view2)
        view.addSubview(view3)
        
        let spaceValue = 5.0
        
        // horizontal sample code
        NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1][view2(90)]-(space@750)-[view3(==view1)]",
                                       options: [.alignAllLeft, .alignAllRight],
                                       metrics: ["space": NSNumber(value: spaceValue)],
                                       views: ["view1": view1, "view2": view2, "view3": view3])
        
        VFL.v(.superView,
              .space(),
              .view(view1),
              .view(view2, size: 90),
              .space(spaceValue, priority: .defaultHigh),
              .view(view3, equal:view1))
            .withOptions([.alignAllLeft, .alignAllRight])
            .constraints
        
        VFL.v(.top,
              .s(),
              .v(view1),
              .v(view2, 90),
              .s(spaceValue, p: .defaultHigh),
              .v(view3, e:view1))
            .withOptions([.alignAllLeft, .alignAllRight])
//            .active()
        
        // vertical sample code
        NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1][view2][view3]|",
                                       options: [.alignAllCenterY],
                                       metrics: nil,
                                       views: ["view1": view1, "view2": view2, "view3": view3])
        VFL.h(.superView, .view(view1), .view(view2), .view(view3), .superView)
            .withOptions([.alignAllCenterY])
            .constraints
        
        VFL.h(.left, .v(view1), .v(view2), .v(view3), .right)
            .withOptions([.alignAllCenterY])
//            .active()
    }


}

