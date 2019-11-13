//
//  TootImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 22/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit
import AVFoundation
import ActiveLabel

class TootImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CoreChartViewDataSource {
    
    var containerView = UIView()
    var profile = UIImageView()
    var profile2 = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    var timestamp = UILabel()
    var content = ActiveLabel()
    var collectionView1: UICollectionView!
    var heart = UIImageView()
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
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
        
        profile2.translatesAutoresizingMaskIntoConstraints = false
        profile2.layer.cornerRadius = 14
        profile2.backgroundColor = GlobalStruct.baseDarkTint
        profile2.isUserInteractionEnabled = true
        profile2.layer.borderWidth = 1.6
        profile2.alpha = 0
        contentView.addSubview(profile2)
        
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
        
        let layout = ColumnFlowLayout(
            cellsPerRow: 4,
            minimumInteritemSpacing: 15,
            minimumLineSpacing: 15,
            sectionInset: UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 20)
        )
        layout.scrollDirection = .horizontal
        collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-10), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(178)), collectionViewLayout: layout)
        collectionView1.translatesAutoresizingMaskIntoConstraints = false
        collectionView1.backgroundColor = UIColor.clear
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.register(CollectionImageCell.self, forCellWithReuseIdentifier: "CollectionImageCell")
        contentView.addSubview(collectionView1)
        
        let viewsDict = [
            "containerView" : containerView,
            "profile" : profile,
            "profile2" : profile2,
            "username" : username,
            "usertag" : usertag,
            "timestamp" : timestamp,
            "content" : content,
            "collectionView" : collectionView1,
            "heart" : heart,
            "pollView" : pollView,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-36-[profile2(28)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[username]-5-[usertag]-(>=5)-[heart(20)]-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[pollView]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-33-[profile2(28)]-(>=5)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[heart(20)]", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[timestamp]-2-[content]-5-[collectionView(140)]-[pollView]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[username]-2-[content]-5-[collectionView(140)]-[pollView]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[usertag]-2-[content]-5-[collectionView(140)]-[pollView]-12-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentStat: Status!
    func configure(_ stat: Status) {
        self.sta = stat
        self.currentStat = stat.reblog ?? stat
        self.images = stat.reblog?.mediaAttachments ?? stat.mediaAttachments
        self.collectionView1.reloadData()
        
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.username.text = stat.reblog?.account.displayName ?? stat.account.displayName
        self.usertag.text = "@\(stat.reblog?.account.username ?? stat.account.username)"
        self.content.text = stat.reblog?.content.stripHTML() ?? stat.content.stripHTML()
        self.timestamp.text = timeAgoSince(stat.reblog?.createdAt ?? stat.createdAt)
        self.profile.image = UIImage()
        guard let imageURL = URL(string: stat.reblog?.account.avatar ?? stat.account.avatar) else { return }
        self.profile.sd_setImage(with: imageURL, completed: nil)
        self.profile.layer.masksToBounds = true
        if stat.reblog?.account.displayName == nil {
            self.profile2.alpha = 0
        } else {
            self.profile2.alpha = 1
            guard let imageURL2 = URL(string: stat.account.avatar) else { return }
            self.profile2.sd_setImage(with: imageURL2, completed: nil)
            self.profile2.layer.masksToBounds = true
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        if stat.reblog?.favourited ?? stat.favourited ?? false {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .direct {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .private {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "lock.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else if stat.reblog?.visibility ?? stat.visibility == .unlisted {
            self.heart.alpha = 1
            self.heart.image = UIImage(systemName: "lock.open.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
        } else {
            self.heart.alpha = 0
        }
        
        if stat.reblog?.emojis.isEmpty ?? stat.emojis.isEmpty {
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(stat.reblog?.content.stripHTML() ?? stat.content.stripHTML())", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            let z = stat.reblog?.emojis ?? stat.emojis
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
            let attributedString2 = NSMutableAttributedString(string: "\(stat.reblog?.account.displayName ?? stat.account.displayName)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!])
            self.username.attributedText = attributedString2
            self.content.attributedText = attributedString
            self.reloadInputViews()
        }
        
        let _ = self.images.map {_ in
            self.images2.append(UIImageView())
            self.images3.append("")
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
    func didTouch(entryData: CoreChartEntry) {
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
                    
                }
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = self.containerView
                    presenter.sourceRect = self.containerView.bounds
                }
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    var images: [Attachment] = []
    var images2: [UIImageView] = []
    var images3: [String] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.images.isEmpty {} else {
            
            let z2 = self.images[indexPath.item].remoteURL ?? self.images[indexPath.item].url
            self.images3[indexPath.row] = z2
            
            cell.configure()
            let z = self.images[indexPath.item].previewURL
            cell.image.contentMode = .scaleAspectFill
            if let imageURL = URL(string: z) {
                if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int == 0 {
                    if self.currentStat.reblog?.sensitive ?? self.currentStat.sensitive ?? true {
                        let x = self.blurImage(imageURL)
                        cell.image.image = x
                    } else {
                        cell.image.sd_setImage(with: imageURL, completed: nil)
                    }
                } else {
                    cell.image.sd_setImage(with: imageURL, completed: nil)
                }
                if self.images[indexPath.row].type == .video || self.images[indexPath.row].type == .audio {
                    cell.videoOverlay.alpha = 1
                } else {
                    cell.videoOverlay.alpha = 0
                }
                cell.image.layer.masksToBounds = true
                self.images2[indexPath.row].sd_setImage(with: imageURL, completed: nil)
                cell.image.backgroundColor = GlobalStruct.baseDarkTint
                cell.image.layer.cornerRadius = 5
                cell.image.layer.masksToBounds = true
                cell.image.layer.borderColor = UIColor.black.cgColor
                cell.image.frame.size.width = 160
                cell.image.frame.size.height = 120
                cell.bgImage.layer.masksToBounds = false
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func blurImage(_ ima: URL) -> UIImage? {
        let imageView = UIImageView()
        imageView.sd_setImage(with: ima, completed: nil)
        let image = imageView.image ?? UIImage()
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(30, forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage
        var cgImage: CGImage?
        if let asd = outputImage {
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }
        if let cgImageA = cgImage {
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images[indexPath.row].type == .video || images[indexPath.row].type == .audio {
            if let ur = URL(string: images[indexPath.row].url) {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: URL(string: self.images3[indexPath.item]), imageText: "@\(self.currentStat.account.username): \(self.currentStat.content.stripHTML())", imageText2: self.currentStat.favouritesCount, imageText3: self.currentStat.reblogsCount, imageText4: self.currentStat.id)
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = ImagePreviewViewController()
            vc.image = self.images2[indexPath.item].image ?? UIImage()
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath)
        })
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let share = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            let imToShare = [self.images2[indexPath.item].image ?? UIImage()]
            let activityViewController = UIActivityViewController(activityItems: imToShare,  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.contentView
            activityViewController.popoverPresentationController?.sourceRect = self.contentView.bounds
            self.getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
        }
        let save = UIAction(title: "Save".localized, image: UIImage(systemName: "square.and.arrow.down"), identifier: nil) { action in
            UIImageWriteToSavedPhotosAlbum(self.images2[indexPath.item].image ?? UIImage(), nil, nil, nil)
        }
        return UIMenu(__title: self.images[indexPath.item].description ?? "", image: nil, identifier: nil, children: [share, save])
    }
}

