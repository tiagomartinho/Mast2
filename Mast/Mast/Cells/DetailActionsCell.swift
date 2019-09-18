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
    
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    var button4 = UIButton()
    var button5 = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.backgroundColor = UIColor.clear
        button1.setImage(UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(button1)
        
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.backgroundColor = UIColor.clear
        button2.setImage(UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(button2)
        
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.backgroundColor = UIColor.clear
        button3.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(button3)
        
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.backgroundColor = UIColor.clear
        button4.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(button4)
        
        button5.translatesAutoresizingMaskIntoConstraints = false
        button5.backgroundColor = UIColor.clear
        button5.setImage(UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(button5)
        
        let viewsDict = [
            "button1" : button1,
            "button2" : button2,
            "button3" : button3,
            "button4" : button4,
            "button5" : button5,
        ]
        let metrics = [
            "horizontalSpacing": 20,
            "cornerMargin": (self.bounds.width - 280)/2
        ]
        
        let horizontalFormat = "H:|-cornerMargin-[button1(40)]-horizontalSpacing-[button2(40)]-horizontalSpacing-[button3(40)]-horizontalSpacing-[button4(40)]-horizontalSpacing-[button5(40)]-cornerMargin-|"
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontalFormat, options: .alignAllCenterY, metrics: metrics, views: viewsDict)
        contentView.addConstraints(horizontalConstraints)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button1(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button2(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button3(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button4(40)]-10-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button5(40)]-10-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

