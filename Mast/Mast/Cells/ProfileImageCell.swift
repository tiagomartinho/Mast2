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
        collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-10), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(178)), collectionViewLayout: layout)
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileStatusesImages.count
    }
    
    var images2: [UIImageView] = []
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.profileStatusesImages.isEmpty {} else {
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
}
