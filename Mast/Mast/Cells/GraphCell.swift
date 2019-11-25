//
//  GraphCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class GraphCell: UITableViewCell, ScrollableGraphViewDataSource {
    
    var allVals: [Int] = []
    var notifications: [Notificationt] = []
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        self.allVals = []
        if pointIndex == 0 {
            let x = self.notifications.filter({ (item) -> Bool in
                item.type == .mention
            })
            self.allVals.append(x.count)
            return Double(x.count)
        } else if pointIndex == 1 {
            let x = self.notifications.filter({ (item) -> Bool in
                item.type == .mention
            })
            let y = x.filter({ (item) -> Bool in
                item.status?.visibility == .direct
            })
            self.allVals.append(y.count)
            return Double(y.count)
        } else if pointIndex == 2 {
            let x = self.notifications.filter({ (item) -> Bool in
                item.type == .reblog
            })
            self.allVals.append(x.count)
            return Double(x.count)
        } else if pointIndex == 3 {
            let x = self.notifications.filter({ (item) -> Bool in
                item.type == .favourite
            })
            self.allVals.append(x.count)
            return Double(x.count)
        } else {
            let x = self.notifications.filter({ (item) -> Bool in
                item.type == .follow
            })
            self.allVals.append(x.count)
            return Double(x.count)
        }
    }
    
    let labels = ["Mentions".localized, "Direct".localized, "Boosts".localized, "Likes".localized, "Follows".localized]
    func label(atIndex pointIndex: Int) -> String {
        return labels[pointIndex]
    }
    
    func numberOfPoints() -> Int {
        return 5
    }
    
    var graphView = ScrollableGraphView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ notifications: [Notificationt]) {
        self.notifications = notifications
        self.allVals = []
        let x = notifications.filter({ (item) -> Bool in
            item.type == .mention
        })
        self.allVals.append(x.count)
        let x2 = notifications.filter({ (item) -> Bool in
            item.type == .mention
        })
        let y2 = x2.filter({ (item) -> Bool in
            item.status?.visibility == .direct
        })
        self.allVals.append(y2.count)
        let x3 = notifications.filter({ (item) -> Bool in
            item.type == .reblog
        })
        self.allVals.append(x3.count)
        let x4 = notifications.filter({ (item) -> Bool in
            item.type == .favourite
        })
        self.allVals.append(x4.count)
        let x5 = notifications.filter({ (item) -> Bool in
            item.type == .follow
        })
        self.allVals.append(x5.count)
        
        self.graphView.removeFromSuperview()
        self.graphView = ScrollableGraphView(frame: CGRect(x: 15, y: 15, width: CGFloat(self.bounds.width - 30), height: 200), dataSource: self)
        self.graphView.isScrollEnabled = false
        self.graphView.shouldAnimateOnStartup = false
        self.graphView.shouldAnimateOnAdapt = false
        self.graphView.alpha = 1
        self.graphView.dataPointSpacing = ((self.bounds.width - 30) / 5)
        
        let barPlot = BarPlot(identifier: "bar")
        barPlot.barWidth = 8
        barPlot.barLineWidth = 0
        barPlot.barLineColor = GlobalStruct.baseTint
        barPlot.barColor = GlobalStruct.baseTint
        barPlot.shouldRoundBarCorners = true
        
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        barPlot.animationDuration = 1.5
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.06)
        referenceLines.referenceLineLabelColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.5)
        referenceLines.dataPointLabelColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.5)
        
        graphView.backgroundFillColor = .clear
        graphView.addPlot(plot: barPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.rangeMax = Double(self.allVals.max() ?? 0)
        graphView.shouldRangeAlwaysStartAtZero = true
        
        contentView.addSubview(self.graphView)
    }
}

