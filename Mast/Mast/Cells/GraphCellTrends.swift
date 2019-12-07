//
//  GraphCellTrends.swift
//  Mast
//
//  Created by Shihab Mehboob on 07/12/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class GraphCellTrends: UITableViewCell, ScrollableGraphViewDataSource {
    
    var allVals: [Int] = []
    var history: [Tag] = []
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        self.allVals = []
        let _ = history.first?.history?.map {
            let z = Int($0.uses)
            self.allVals.append((z ?? 0))
        }
        self.allVals = self.allVals.reversed()
        return Double(self.allVals[pointIndex])
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return ""
    }
    
    func numberOfPoints() -> Int {
        return self.allVals.count
    }
    
    var graphView = ScrollableGraphView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ history: [Tag]) {
        self.history = history
        self.allVals = []

        let _ = history.first?.history?.map {
            let z = Int($0.uses)
            self.allVals.append((z ?? 0))
        }
        self.allVals = self.allVals.reversed()
        
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

