//
//  GraphCell2.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class GraphCell2: UITableViewCell, TKRadarChartDataSource, TKRadarChartDelegate {
    
    var allVals: [Int] = []
    var chart = TKRadarChart()
    let labels = ["Mentions".localized, "Direct".localized, "Boosts".localized, "Likes".localized, "Follows".localized]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.allVals = []
        let x = GlobalStruct.notifications.filter({ (item) -> Bool in
            item.type == .mention
        })
        self.allVals.append(x.count)
        let x2 = GlobalStruct.notifications.filter({ (item) -> Bool in
            item.type == .mention
        })
        let y2 = x2.filter({ (item) -> Bool in
            item.status?.visibility == .direct
        })
        self.allVals.append(y2.count)
        let x3 = GlobalStruct.notifications.filter({ (item) -> Bool in
            item.type == .reblog
        })
        self.allVals.append(x3.count)
        let x4 = GlobalStruct.notifications.filter({ (item) -> Bool in
            item.type == .favourite
        })
        self.allVals.append(x4.count)
        let x5 = GlobalStruct.notifications.filter({ (item) -> Bool in
            item.type == .follow
        })
        self.allVals.append(x5.count)
        
        self.chart.removeFromSuperview()
        chart.frame = CGRect(x: 15, y: 20, width: CGFloat(self.bounds.width - 30), height: 200)
        chart.configuration.radius = 90
        chart.configuration.showBgLine = false
        chart.configuration.showBorder = false
        chart.configuration.borderWidth = 0.4
        chart.configuration.minValue = CGFloat(0)
        chart.configuration.maxValue = CGFloat(self.allVals.max() ?? 0)
        chart.dataSource = self
        chart.delegate = self
        chart.reloadData()
        contentView.addSubview(self.chart)
    }
    
    func numberOfStepForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return self.labels.count - 1
    }
    
    func numberOfRowForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return self.labels.count
    }
    
    func numberOfSectionForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return 1
    }
    
    func titleOfRowForRadarChart(_ radarChart: TKRadarChart, row: Int) -> String {
        return self.labels[row]
    }
    
    func valueOfSectionForRadarChart(withRow row: Int, section: Int) -> CGFloat {
        if row == 0 {
            let x = GlobalStruct.notifications.filter({ (item) -> Bool in
                item.type == .mention
            })
            return CGFloat(x.count)
        } else if row == 1 {
            let x2 = GlobalStruct.notifications.filter({ (item) -> Bool in
                item.type == .mention
            })
            let y2 = x2.filter({ (item) -> Bool in
                item.status?.visibility == .direct
            })
            return CGFloat(y2.count)
        } else if row == 2 {
            let x3 = GlobalStruct.notifications.filter({ (item) -> Bool in
                item.type == .reblog
            })
            return CGFloat(x3.count)
        } else if row == 3 {
            let x4 = GlobalStruct.notifications.filter({ (item) -> Bool in
                item.type == .favourite
            })
            return CGFloat(x4.count)
        } else {
            let x5 = GlobalStruct.notifications.filter({ (item) -> Bool in
                item.type == .follow
            })
            return CGFloat(x5.count)
        }
    }
    
    func colorOfLineForRadarChart(_ radarChart: TKRadarChart) -> UIColor {
        return UIColor(named: "baseBlack")!.withAlphaComponent(0.5)
    }
    
    func colorOfFillStepForRadarChart(_ radarChart: TKRadarChart, step: Int) -> UIColor {
        return .clear
    }
    
    func colorOfSectionFillForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor {
        return GlobalStruct.baseTint
    }
    
    func colorOfSectionBorderForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor {
        return UIColor(named: "baseBlack")!.withAlphaComponent(0.35)
    }
    
    func fontOfTitleForRadarChart(_ radarChart: TKRadarChart) -> UIFont {
        return UIFont.systemFont(ofSize: 10)
    }
}
