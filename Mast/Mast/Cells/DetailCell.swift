//
//  DetailCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 18/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

class DetailCell: UITableViewCell, CoreChartViewDataSource {
    
    var containerView = UIView()
    var profile = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    var metrics = UIButton()
    var timestamp = UILabel()
    var content = ActiveLabel()
    var heart = UIImageView()
    var pollView = UIView()
    var barChart: HCoreBarChart = HCoreBarChart()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = GlobalStruct.baseDarkTint
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = UIColor(named: "baseBlack")
        username.textAlignment = .natural
        username.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        username.isUserInteractionEnabled = false
        username.adjustsFontForContentSizeCategory = true
        username.numberOfLines = 1
        contentView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        usertag.textAlignment = .natural
        usertag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        usertag.isUserInteractionEnabled = false
        usertag.adjustsFontForContentSizeCategory = true
        usertag.numberOfLines = 1
        contentView.addSubview(usertag)
        
        metrics.translatesAutoresizingMaskIntoConstraints = false
        metrics.setTitleColor(GlobalStruct.baseTint, for: .normal)
        metrics.contentHorizontalAlignment = .leading
        metrics.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        metrics.titleLabel?.adjustsFontForContentSizeCategory = true
        metrics.titleLabel?.numberOfLines = 1
        metrics.titleLabel?.lineBreakMode = .byTruncatingTail
        contentView.addSubview(metrics)
        
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        timestamp.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        timestamp.textAlignment = .natural
        timestamp.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        timestamp.isUserInteractionEnabled = false
        timestamp.adjustsFontForContentSizeCategory = true
        timestamp.numberOfLines = 1
        timestamp.lineBreakMode = .byTruncatingTail
        contentView.addSubview(timestamp)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        content.textAlignment = .natural
        content.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        content.isUserInteractionEnabled = true
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        content.enabledTypes = [.mention, .hashtag, .url]
        content.mentionColor = GlobalStruct.baseTint
        content.hashtagColor = GlobalStruct.baseTint
        content.URLColor = GlobalStruct.baseTint
        contentView.addSubview(content)

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        heart.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        heart.translatesAutoresizingMaskIntoConstraints = false
        heart.backgroundColor = GlobalStruct.baseDarkTint
        heart.contentMode = .scaleAspectFit
        heart.alpha = 0
        contentView.addSubview(heart)
        
        pollView.translatesAutoresizingMaskIntoConstraints = false
        pollView.backgroundColor = .clear
        contentView.addSubview(pollView)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestamp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let viewsDict = [
            "containerView" : containerView,
            "profile" : profile,
            "username" : username,
            "usertag" : usertag,
            "metrics" : metrics,
            "timestamp" : timestamp,
            "content" : content,
            "pollView" : pollView,
            "heart" : heart,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[username]-5-[usertag]-(>=5)-[heart(20)]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[metrics]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[pollView]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[heart(20)]", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[username]-6-[content]-[pollView]-5-[metrics]-1-[timestamp]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[usertag]-6-[content]-[pollView]-5-[metrics]-1-[timestamp]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ stat: Status) {
        self.sta = stat
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.username.text = stat.account.displayName
        self.usertag.text = "@\(stat.account.username)"
        self.content.text = stat.content.stripHTML()
        self.timestamp.text = stat.createdAt.toString(dateStyle: .medium, timeStyle: .medium)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: stat.favouritesCount))
        let numberFormatter2 = NumberFormatter()
        numberFormatter2.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber2 = numberFormatter2.string(from: NSNumber(value: stat.reblogsCount))
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 4, weight: .bold)
        let normalFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 2)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "heart", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attachment2 = NSTextAttachment()
        attachment2.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attStringNewLine = NSMutableAttributedString(string: "\(formattedNumber ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(1)])
        let attStringNewLine2 = NSMutableAttributedString(string: "\(formattedNumber2 ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(1)])
        let attString = NSAttributedString(attachment: attachment)
        let attString2 = NSAttributedString(attachment: attachment2)
        let fullString = NSMutableAttributedString(string: "")
        let spaceString0 = NSMutableAttributedString(string: " ")
        let spaceString = NSMutableAttributedString(string: "  ")
        fullString.append(attString)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine)
        fullString.append(spaceString)
        fullString.append(attString2)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine2)
        self.metrics.setAttributedTitle(fullString, for: .normal)
        
        self.profile.image = UIImage()
        guard let imageURL = URL(string: stat.account.avatar) else { return }
        self.profile.sd_setImage(with: imageURL, completed: nil)
        self.profile.layer.masksToBounds = true
        
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        if stat.reblog?.favourited ?? stat.favourited ?? false {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig2)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .direct {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig2)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .private {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "lock.fill", withConfiguration: symbolConfig2)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .unlisted {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "lock.open.fill", withConfiguration: symbolConfig2)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else {
            self.heart.alpha = 0
        }
        
        if stat.emojis.isEmpty {
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(stat.content.stripHTML())", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            let z = stat.emojis
            let _ = z.map({
                let textAttachment = NSTextAttachment()
                textAttachment.loadImageUsingCache(withUrl: $0.url.absoluteString)
                textAttachment.bounds = CGRect(x:0, y: Int(-4), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight))
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                while attributedString.mutableString.contains(":\($0.shortcode):") {
                    let range: NSRange = (attributedString.mutableString as NSString).range(of: ":\($0.shortcode):")
                    attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                }
            })
            let attributedString2 = NSMutableAttributedString(string: "\(stat.account.displayName)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!])
            self.username.attributedText = attributedString2
            self.content.attributedText = attributedString
            self.reloadInputViews()
        }

        var pollHeight = (self.pollOptions.count * 24) + (self.pollOptions.count * 10)
        if stat.reblog?.poll ?? stat.poll != nil {
            self.pollView.alpha = 1
            self.pollOptions = stat.reblog?.poll?.options ?? stat.poll!.options
            pollHeight = (self.pollOptions.count * 26) + (self.pollOptions.count * 10)
            barChart.frame = CGRect(x: 0, y: 0, width: Int(CGFloat((getTopMostViewController()?.view.bounds.width ?? self.bounds.width) - 86)), height: pollHeight)
            barChart.dataSource = self
            barChart.displayConfig = CoreBarChartsDisplayConfig(barWidth: 26.0,
                                                                barSpace: 10.0,
                                                                bottomSpace: 0.0,
                                                                topSpace: 0.0,
                                                                backgroundColor: .clear,
                                                                titleFontSize: 14,
                                                                valueFontSize: 16,
                                                                titleFont: UIFont.systemFont(ofSize: 14),
                                                                valueFont: UIFont.systemFont(ofSize: 16),
                                                                titleLength: 400)
            pollView.addSubview(self.barChart)
            let countLabel = UILabel()
            let expiryLabel = UILabel()
            var voteText = "\(stat.reblog?.poll?.votesCount ?? stat.poll?.votesCount ?? 0) \("votes".localized)"
            if stat.reblog?.poll?.voted ?? stat.poll?.voted ?? false {
                voteText = "\(voteText) • \("Voted".localized)"
            }
            if stat.reblog?.poll?.multiple ?? stat.poll?.multiple ?? false {
                voteText = "\(voteText) • \("Multiple choices allowed".localized)"
            }
            countLabel.frame = CGRect(x: 0, y: Int(pollHeight + 8), width: Int(CGFloat((getTopMostViewController()?.view.bounds.width ?? self.bounds.width) - 116)), height: 20)
            countLabel.text = voteText
            countLabel.font = UIFont.systemFont(ofSize: 12)
            countLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
            countLabel.textAlignment = .left
            pollView.addSubview(countLabel)
            let expText = stat.reblog?.poll?.expiresAt?.toString(dateStyle: .short, timeStyle: .short) ?? stat.poll?.expiresAt?.toString(dateStyle: .short, timeStyle: .short) ?? ""
            var timeText = "\("Expires at".localized) \(expText)"
            if stat.reblog?.poll?.expired ?? stat.poll?.expired ?? false {
                timeText = "Closed".localized
            }
            expiryLabel.frame = CGRect(x: 0, y: Int(pollHeight + 24), width: Int(CGFloat((getTopMostViewController()?.view.bounds.width ?? self.bounds.width) - 116)), height: 20)
            expiryLabel.text = timeText
            expiryLabel.font = UIFont.systemFont(ofSize: 12)
            expiryLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
            expiryLabel.textAlignment = .left
            pollView.addSubview(expiryLabel)
            self.pollView.removeConstraint(heightConstraint)
            heightConstraint = NSLayoutConstraint(item: self.pollView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(pollHeight + 44))
            self.pollView.addConstraint(heightConstraint)
            contentView.layoutIfNeeded()
        } else {
            self.pollView.alpha = 0
            self.pollView.removeConstraint(heightConstraint)
            heightConstraint = NSLayoutConstraint(item: self.pollView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(0))
            self.pollView.addConstraint(heightConstraint)
            contentView.layoutIfNeeded()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.barChart.reload()
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }

    var heightConstraint = NSLayoutConstraint()
    var pollOptions: [PollOptions] = []
    func loadCoreChartData() -> [CoreChartEntry] {
        var allData = [CoreChartEntry]()
        for index in 0..<self.pollOptions.count {
            let newEntry = CoreChartEntry(id: "\(index)",
                barTitle: self.pollOptions[index].title,
                barHeight: Double(self.pollOptions[index].votesCount ?? 0),
                barColor: GlobalStruct.baseTint)
            allData.append(newEntry)
        }
        return allData
    }
    
    var sta: Status!
    var doOnce: Bool = true
    func didTouch(entryData: CoreChartEntry) {
        if self.doOnce {
            self.doOnce = false
        if self.sta.account.id == GlobalStruct.currentUser.id {
            
        } else {
            if (self.sta.reblog?.poll?.expired ?? self.sta.poll?.expired ?? false) || (self.sta.reblog?.poll?.voted ?? self.sta.poll?.voted ?? false) {
                
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let op1 = UIAlertAction(title: "\("Vote for".localized) \(entryData.barTitle)", style: .default , handler:{ (UIAlertAction) in
                    let request = Polls.vote(id: self.sta.reblog?.poll?.id ?? self.sta.poll?.id ?? "", choices: [Int(entryData.id) ?? 0])
                    GlobalStruct.client.run(request) { (statuses) in
//                        let request2 = Statuses.status(id: self.sta.id)
//                        GlobalStruct.client.run(request2) { (statuses) in
//                            if let stat = statuses.value {
//                                DispatchQueue.main.async {
//                                    self.configure(stat)
//                                }
//                            }
//                        }
                    }
                })
                op1.setValue(UIImage(systemName: "chart.bar")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
                alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                    self.doOnce = true
                }
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = self.containerView
                    presenter.sourceRect = self.containerView.bounds
                }
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
        }
        }
    }
    
    
    func highlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 1
        })
    }
    
    func unhighlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 0
        })
    }
}
