//
//  NotificationsCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 18/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

class NotificationsCell: UITableViewCell, CoreChartViewDataSource {
    
    var containerView = UIView()
    var typeOf = UIImageView()
    var profile = UIImageView()
    var profile2 = UIImageView()
    var title = UILabel()
    var username = UILabel()
    var usertag = UILabel()
    var timestamp = UILabel()
    var content = ActiveLabel()
    var heart = UIImageView()
    var pollView = UIView()
    var barChart: HCoreBarChart = HCoreBarChart()
    var cwOverlay = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        typeOf.translatesAutoresizingMaskIntoConstraints = false
        typeOf.backgroundColor = UIColor.clear
        typeOf.contentMode = .scaleAspectFit
        contentView.addSubview(typeOf)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = GlobalStruct.baseDarkTint
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        profile2.translatesAutoresizingMaskIntoConstraints = false
        profile2.layer.cornerRadius = 14
        profile2.backgroundColor = GlobalStruct.baseDarkTint
        profile2.isUserInteractionEnabled = true
        profile2.layer.borderWidth = 1.6
        contentView.addSubview(profile2)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        title.textAlignment = .natural
        title.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        title.isUserInteractionEnabled = false
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        contentView.addSubview(title)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = UIColor(named: "baseBlack")
        username.textAlignment = .natural
        username.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        username.isUserInteractionEnabled = false
        username.adjustsFontForContentSizeCategory = true
        username.numberOfLines = 1
        username.lineBreakMode = .byTruncatingTail
        contentView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        usertag.textAlignment = .natural
        usertag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        usertag.isUserInteractionEnabled = false
        usertag.adjustsFontForContentSizeCategory = true
        usertag.numberOfLines = 1
        usertag.lineBreakMode = .byTruncatingTail
        contentView.addSubview(usertag)
        
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        timestamp.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        timestamp.textAlignment = .natural
        timestamp.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
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
        heart.backgroundColor = .clear
        heart.contentMode = .scaleAspectFit
        heart.alpha = 0
        contentView.addSubview(heart)
        
        pollView.translatesAutoresizingMaskIntoConstraints = false
        pollView.backgroundColor = .clear
        contentView.addSubview(pollView)
        
        username.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestamp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        heart.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        cwOverlay.translatesAutoresizingMaskIntoConstraints = false
        cwOverlay.backgroundColor = UIColor(named: "lighterBaseWhite")!
        cwOverlay.layer.cornerRadius = 4
        cwOverlay.alpha = 0
        cwOverlay.titleLabel?.numberOfLines = 0
        cwOverlay.addTarget(self, action: #selector(self.hideOverlay), for: .touchUpInside)
        contentView.addSubview(cwOverlay)
        
        let viewsDict = [
            "containerView" : containerView,
            "typeOf" : typeOf,
            "profile" : profile,
            "profile2" : profile2,
            "title" : title,
            "username" : username,
            "usertag" : usertag,
            "timestamp" : timestamp,
            "content" : content,
            "heart" : heart,
            "pollView" : pollView,
            "cwOverlay" : cwOverlay,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeOf(20)]-10-[profile(40)]-10-[username]-5-[usertag]-(>=5)-[heart(20)]-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[profile2(28)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[title]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[pollView]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[typeOf(20)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-33-[profile2(28)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[heart(20)]", options: [], metrics: nil, views: viewsDict))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[username]-2-[content]-[pollView]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[usertag]-2-[content]-[pollView]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[timestamp]", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-96-[cwOverlay]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[cwOverlay]-8-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func hideOverlay() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.selectionChanged()
        }
        self.cwOverlay.alpha = 0
    }
    
    func configure(_ noti: Notificationt) {
        content.mentionColor = GlobalStruct.baseTint
        content.hashtagColor = GlobalStruct.baseTint
        content.URLColor = GlobalStruct.baseTint
        self.notif = noti
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.timestamp.text = timeAgoSince(noti.createdAt)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        if noti.type == .mention {
            if noti.status?.visibility == .direct {
                self.typeOf.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
            } else {
                self.typeOf.image = UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal)
            }
        } else if noti.type == .favourite {
            self.typeOf.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        } else if noti.type == .reblog {
            self.typeOf.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemGreen, renderingMode: .alwaysOriginal)
        } else if noti.type == .direct {
            self.typeOf.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
        } else if noti.type == .poll {
            self.typeOf.image = UIImage(systemName: "chart.bar.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
        } else if noti.type == .follow {
            self.typeOf.image = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal)
        }
        
        if noti.status?.sensitive ?? false {
            if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int == 0 {
                self.cwOverlay.alpha = 1
                self.cwOverlay.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                if noti.status?.spoilerText ?? "" == "" {
                    self.cwOverlay.setTitle("Content Warning".localized, for: .normal)
                } else {
                    self.cwOverlay.setTitle(noti.status?.spoilerText ?? "Content Warning", for: .normal)
                }
                self.cwOverlay.setTitleColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.85), for: .normal)
                self.cwOverlay.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            } else {
                self.cwOverlay.alpha = 0
            }
        } else {
            self.cwOverlay.alpha = 0
        }
        
        if noti.type == .follow {
            self.title.text = "New follower".localized
            self.username.text = noti.account.displayName
            self.usertag.text = "@\(noti.account.username)"
            self.content.text = "\(noti.account.note.stripHTML())"
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.account.avatar) else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            self.profile2.alpha = 0
        } else {
            if noti.type == .mention {
                if noti.status?.visibility == .direct {
                    self.title.text = "\(noti.account.displayName) \("direct messaged you".localized)"
                } else {
                    self.title.text = "\(noti.account.displayName) \("mentioned you".localized)"
                }
            } else if noti.type == .favourite {
                self.title.text = "\(noti.account.displayName) \("liked your toot".localized)"
            } else if noti.type == .reblog {
                self.title.text = "\(noti.account.displayName) \("boosted your toot".localized)"
            } else if noti.type == .direct {
                self.title.text = "\(noti.account.displayName) \("direct messaged you".localized)"
            } else if noti.type == .poll {
                self.title.text = "\(noti.account.displayName)"
            }
            self.username.text = noti.status?.account.displayName ?? ""
            self.usertag.text = "@\(noti.status?.account.username ?? "")"
            self.content.text = noti.status?.content.stripHTML() ?? ""
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.status?.account.avatar ?? "") else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            if noti.type == .mention || noti.type == .poll {
                self.profile2.layer.masksToBounds = true
                self.profile2.alpha = 0
                self.profile2.layer.borderColor = GlobalStruct.baseDarkTint.cgColor
            } else {
                self.profile2.image = UIImage()
                guard let imageURL2 = URL(string: noti.account.avatar) else { return }
                self.profile2.sd_setImage(with: imageURL2, completed: nil)
                self.profile2.layer.masksToBounds = true
                self.profile2.alpha = 1
                self.profile2.layer.borderColor = GlobalStruct.baseDarkTint.cgColor
            }
        }
        if noti.status?.favourited ?? false || GlobalStruct.allLikedStatuses.contains(noti.status?.id ?? "") {
            if GlobalStruct.allDislikedStatuses.contains(noti.status?.id ?? "") {
                self.heart.alpha = 0
            } else {
                self.heart.alpha = 1
            }
        } else {
            self.heart.alpha = 0
        }
        
        if noti.status?.emojis.isEmpty ?? false {
            
        } else {
            var attributedString = NSMutableAttributedString(string: "\(noti.status?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            if UserDefaults.standard.value(forKey: "sync-dimn") as? Int == 0 {
                if noti.type == .mention {
                    attributedString = NSMutableAttributedString(string: "\(noti.status?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
                    if noti.type == .follow {
                        attributedString = NSMutableAttributedString(string: noti.account.note.stripHTML(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
                    }
                } else {
                    attributedString = NSMutableAttributedString(string: "\(noti.status?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(4)])
                    if noti.type == .follow {
                        attributedString = NSMutableAttributedString(string: noti.account.note.stripHTML(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.4)])
                    }
                }
            } else {
                attributedString = NSMutableAttributedString(string: "\(noti.status?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
                if noti.type == .follow {
                    attributedString = NSMutableAttributedString(string: noti.account.note.stripHTML(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
                }
            }
            
            let z = noti.status?.emojis ?? []
            let _ = z.map({
                let textAttachment = NSTextAttachment()
                textAttachment.kf.setImage(with: $0.url) { r in
                    self.content.setNeedsDisplay()
                }
                textAttachment.bounds = CGRect(x:0, y: Int(-4), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight))
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                while attributedString.mutableString.contains(":\($0.shortcode):") {
                    let range: NSRange = (attributedString.mutableString as NSString).range(of: ":\($0.shortcode):")
                    attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                }
            })
            #if !targetEnvironment(macCatalyst)
            self.content.attributedText = attributedString
            //self.reloadInputViews()
            #endif
        }
        
        if noti.status?.account.emojis.isEmpty ?? false {
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(noti.status?.account.displayName ?? noti.account.displayName)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            let z = noti.status?.account.emojis ?? []
            let _ = z.map({
                let textAttachment = NSTextAttachment()
                textAttachment.kf.setImage(with: $0.url) { r in
                    self.username.setNeedsDisplay()
                }
                textAttachment.bounds = CGRect(x:0, y: Int(-4), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight))
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                while attributedString.mutableString.contains(":\($0.shortcode):") {
                    let range: NSRange = (attributedString.mutableString as NSString).range(of: ":\($0.shortcode):")
                    attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                }
            })
            #if !targetEnvironment(macCatalyst)
            self.username.attributedText = attributedString
            //self.reloadInputViews()
            #endif
        }
        
        if UserDefaults.standard.value(forKey: "sync-dimn") as? Int == 0 {
            if noti.type == .mention {
                content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
            } else {
                content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.4)
            }
        } else {
            content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        }

        var pollHeight = (self.pollOptions.count * 24) + (self.pollOptions.count * 10)
        if noti.status?.reblog?.poll ?? noti.status?.poll != nil {
            self.pollView.alpha = 1
            self.pollOptions = noti.status?.reblog?.poll?.options ?? noti.status!.poll!.options
            pollHeight = (self.pollOptions.count * 26) + (self.pollOptions.count * 10)
            barChart.frame = CGRect(x: 0, y: 0, width: Int(CGFloat((self.bounds.width) - 116)), height: pollHeight)
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
            let expiryLabel = UILabel()
            var voteText = "\(noti.status?.reblog?.poll?.votesCount ?? noti.status?.poll?.votesCount ?? 0) \("votes".localized)"
            if noti.status?.reblog?.poll?.voted ?? noti.status?.poll?.voted ?? false {
                voteText = "\(voteText) • \("Voted".localized)"
            }
            if noti.status?.reblog?.poll?.multiple ?? noti.status?.poll?.multiple ?? false {
                voteText = "\(voteText) • \("Multiple choices allowed".localized)"
            }
            countLabel.frame = CGRect(x: 0, y: Int(pollHeight + 8), width: Int(CGFloat((getTopMostViewController()?.view.bounds.width ?? self.bounds.width) - 116)), height: 20)
            countLabel.text = voteText
            countLabel.font = UIFont.systemFont(ofSize: 12)
            countLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
            countLabel.textAlignment = .left
            pollView.addSubview(countLabel)
            let expText = noti.status?.reblog?.poll?.expiresAt?.toString(dateStyle: .short, timeStyle: .short) ?? noti.status?.poll?.expiresAt?.toString(dateStyle: .short, timeStyle: .short) ?? ""
            var timeText = "\("Expires at".localized) \(expText)"
            if noti.status?.reblog?.poll?.expired ?? noti.status?.poll?.expired ?? false {
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
            if self.updatedPollInt == index {
                let newEntry = CoreChartEntry(id: "\(index)",
                    barTitle: self.pollOptions[index].title,
                    barHeight: Double((self.pollOptions[index].votesCount ?? 0) + 1),
                    barColor: GlobalStruct.baseTint)
                allData.append(newEntry)
            } else {
                let newEntry = CoreChartEntry(id: "\(index)",
                    barTitle: self.pollOptions[index].title,
                    barHeight: Double(self.pollOptions[index].votesCount ?? 0),
                    barColor: GlobalStruct.baseTint)
                allData.append(newEntry)
            }
        }
        return allData
    }
    
    var notif: Notificationt!
    let countLabel = UILabel()
    var updatedPoll: Bool = false
    var updatedPollInt: Int = 0
    var doOnce: Bool = true
    func didTouch(entryData: CoreChartEntry) {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.selectionChanged()
        }
        if self.doOnce {
            self.doOnce = false
        if self.notif.account.id == GlobalStruct.currentUser.id {
            
        } else {
            if (self.notif.status?.reblog?.poll?.expired ?? self.notif.status?.poll?.expired ?? false) || (self.notif.status?.reblog?.poll?.voted ?? self.notif.status?.poll?.voted ?? false) {
                
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let op1 = UIAlertAction(title: "\("Vote for".localized) \(entryData.barTitle)", style: .default , handler:{ (UIAlertAction) in
                    let request = Polls.vote(id: self.notif.status?.reblog?.poll?.id ?? self.notif.status?.poll?.id ?? "", choices: [Int(entryData.id) ?? 0])
                    GlobalStruct.client.run(request) { (statuses) in
                        DispatchQueue.main.async {
                            ViewController().showNotifBanner("Voted".localized, subtitle: entryData.barTitle, style: BannerStyle.info)
                            var voteText = "\((self.notif.status?.reblog?.poll?.votesCount ?? self.notif.status?.poll?.votesCount ?? 0) + 1) \("votes".localized)"
                            if self.notif.status?.reblog?.poll?.voted ?? self.notif.status?.poll?.voted ?? false {
                                voteText = "\(voteText) • \("Voted".localized)"
                            }
                            if self.notif.status?.reblog?.poll?.multiple ?? self.notif.status?.poll?.multiple ?? false {
                                voteText = "\(voteText) • \("Multiple choices allowed".localized)"
                            }
                            self.countLabel.text = voteText
                            self.updatedPoll = true
                            self.updatedPollInt = Int(entryData.id) ?? 0
                            self.barChart.reload()
                        }
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

