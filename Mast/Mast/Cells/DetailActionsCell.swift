//
//  DetailActionsCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 18/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class DetailActionsCell: UITableViewCell {
    
    let containerView = UIView(frame: CGRect.zero)
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    var button4 = UIButton()
    var button5 = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.backgroundColor = UIColor.clear
        button1.setImage(UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal), for: .normal)
        containerView.addSubview(button1)
        
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.backgroundColor = UIColor.clear
        button2.setImage(UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal), for: .normal)
        containerView.addSubview(button2)
        
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.backgroundColor = UIColor.clear
        button3.setImage(UIImage(systemName: "heart", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal), for: .normal)
        containerView.addSubview(button3)
        
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.backgroundColor = UIColor.clear
        button4.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal), for: .normal)
        containerView.addSubview(button4)
        
        button5.translatesAutoresizingMaskIntoConstraints = false
        button5.backgroundColor = UIColor.clear
        button5.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal), for: .normal)
        containerView.addSubview(button5)
        
        let viewsDict = [
            "container" : containerView,
            "button1" : button1,
            "button2" : button2,
            "button3" : button3,
            "button4" : button4,
            "button5" : button5,
        ]
        let metrics = [
            "horizontalSpacing": 25,
            "cornerMargin": 30
        ]

        let verticalCenter = NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0)
        let horizontalCenter = NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0)
        contentView.addConstraint(verticalCenter)
        contentView.addConstraint(horizontalCenter)
        
        let horizontalFormat = "H:|-(==cornerMargin)-[button1(40)]-horizontalSpacing-[button2(40)]-horizontalSpacing-[button3(40)]-horizontalSpacing-[button4(40)]-horizontalSpacing-[button5(40)]-(==cornerMargin)-|"
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontalFormat, options: .alignAllCenterY, metrics: metrics, views: viewsDict)
        contentView.addConstraints(horizontalConstraints)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button1(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button2(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button3(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button4(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button5(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        
        let verticalFormat5 = "V:|-0-[container]-0-|"
        let verticalConstraints5 = NSLayoutConstraint.constraints(withVisualFormat: verticalFormat5, options: .alignAllCenterY, metrics: metrics, views: viewsDict)
        contentView.addConstraints(verticalConstraints5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ stat: Status) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        if stat.favourited ?? false {
            button3.setImage(UIImage(systemName: "heart", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        }
        if stat.reblogged ?? false {
            button2.setImage(UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemGreen.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        }
    }
}

