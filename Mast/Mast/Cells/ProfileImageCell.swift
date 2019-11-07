//
//  ProfileImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import GSImageViewerController
import SDWebImage
import AVKit
import AVFoundation

class ProfileImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var profileStatusesImages: [Status] = []
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = ColumnFlowLayout(
            cellsPerRow: 4,
            minimumInteritemSpacing: 15,
            minimumLineSpacing: 15,
            sectionInset: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        )
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-15), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(178)), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CollectionImageCell.self, forCellWithReuseIdentifier: "CollectionImageCell")
        
        contentView.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ status: [Status]) {
        self.profileStatusesImages = status
        self.collectionView.reloadData()
        
        let _ = self.profileStatusesImages.map {_ in
            self.images2.append(UIImageView())
            self.images3.append("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileStatusesImages.count
    }
    
    var images2: [UIImageView] = []
    var images3: [String] = []
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.profileStatusesImages.isEmpty {} else {
            
            let z2 = self.profileStatusesImages[indexPath.item].mediaAttachments[0].remoteURL ?? self.profileStatusesImages[indexPath.item].mediaAttachments[0].url
            self.images3[indexPath.row] = z2
            
            cell.configure()
            if self.profileStatusesImages[indexPath.item].mediaAttachments.isEmpty {} else {
                let z = self.profileStatusesImages[indexPath.item].mediaAttachments[0].previewURL
                cell.image.contentMode = .scaleAspectFill
                if let imageURL = URL(string: z) {
                    cell.image.sd_setImage(with: imageURL, completed: nil)
                    if self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .video {
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
                }
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .video {
            if let ur = URL(string: self.profileStatusesImages[indexPath.item].mediaAttachments[0].url) {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: URL(string: self.images3[indexPath.item]))
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = ImageViewController()
            vc.image = self.images2[indexPath.item].image ?? UIImage()
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath)
        })
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let share = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            
        }
        let save = UIAction(title: "Save".localized, image: UIImage(systemName: "square.and.arrow.down"), identifier: nil) { action in
            UIImageWriteToSavedPhotosAlbum(self.images2[indexPath.item].image ?? UIImage(), nil, nil, nil)
        }
        return UIMenu(__title: "", image: nil, identifier: nil, children: [share, save])
    }
}
