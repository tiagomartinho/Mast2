//
//  DetailImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 22/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import GSImageViewerController
import SDWebImage
import AVKit
import AVFoundation

class DetailImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var containerView = UIView()
    var profile = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    var metrics = UIButton()
    var timestamp = UILabel()
    var content = UILabel()
    var collectionView1: UICollectionView!
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = UIColor(named: "baseWhite")
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
        content.isUserInteractionEnabled = false
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        contentView.addSubview(content)
        
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
            "username" : username,
            "usertag" : usertag,
            "metrics" : metrics,
            "timestamp" : timestamp,
            "content" : content,
            "collectionView" : collectionView1,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[username]-5-[usertag]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[metrics]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[username]-6-[content]-5-[metrics]-1-[timestamp]-5-[collectionView(140)]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[usertag]-6-[content]-5-[metrics]-1-[timestamp]-5-[collectionView(140)]-12-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ stat: Status) {
        self.images = stat.mediaAttachments
        self.collectionView1.reloadData()
        
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
        
        let _ = self.images.map {_ in
            self.images2.append(UIImageView())
        }
    }
    
    var images: [Attachment] = []
    var images2: [UIImageView] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.images.isEmpty {} else {
            cell.configure()
            let z = self.images[indexPath.item].previewURL
            cell.image.contentMode = .scaleAspectFill
            if let imageURL = URL(string: z) {
                cell.image.sd_setImage(with: imageURL, completed: nil)
                if self.images[indexPath.row].type == .video {
                    cell.videoOverlay.alpha = 1
                } else {
                    cell.videoOverlay.alpha = 0
                }
                cell.image.layer.masksToBounds = true
                self.images2[indexPath.row].sd_setImage(with: imageURL, completed: nil)
                cell.image.backgroundColor = UIColor(named: "baseWhite")
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images[indexPath.row].type == .video {
            if let ur = URL(string: images[indexPath.row].url) {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                let win = UIApplication.shared.keyWindow?.rootViewController
                win?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            let win = UIApplication.shared.keyWindow?.rootViewController
            win?.present(imageViewer, animated: true, completion: nil)
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
