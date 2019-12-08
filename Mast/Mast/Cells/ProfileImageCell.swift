//
//  ProfileImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
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
        
        #if targetEnvironment(macCatalyst)
        collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-15), width: CGFloat(380), height: CGFloat(178)), collectionViewLayout: layout)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad {
            collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-15), width: CGFloat(380), height: CGFloat(178)), collectionViewLayout: layout)
        } else {
            collectionView = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-15), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(178)), collectionViewLayout: layout)
        }
        #endif
        
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
    
    var currentStat: [Status] = []
    func configure(_ status: [Status]) {
        self.currentStat = status
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
                    if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int == 0 {
                        if self.profileStatusesImages[indexPath.item].reblog?.sensitive ?? self.profileStatusesImages[indexPath.item].sensitive ?? true {
                            let x = self.blurImage(imageURL)
                            cell.image.sd_setImage(with: imageURL, completed: nil)
                            cell.image.image = x
                        } else {
                            cell.image.sd_setImage(with: imageURL, completed: nil)
                        }
                    } else {
                        cell.image.sd_setImage(with: imageURL, completed: nil)
                    }
                    if self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .video || self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .gifv || self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .audio {
                        cell.videoOverlay.alpha = 1
                        
                        print("vidduration - \((self.profileStatusesImages[indexPath.item].mediaAttachments[0].meta?.original?.duration ?? 0).stringFromTimeInterval())")
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
                }
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
        if self.images3[indexPath.row] == "" {} else {
        if self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .video || self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .gifv || self.profileStatusesImages[indexPath.item].mediaAttachments[0].type == .audio {
            if let ur = URL(string: self.profileStatusesImages[indexPath.item].mediaAttachments[0].url) {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: URL(string: self.images3[indexPath.item]), imageText: "@\(self.currentStat[indexPath.item].account.username): \(self.currentStat[indexPath.item].content.stripHTML())", imageText2: self.currentStat[indexPath.item].favouritesCount, imageText3: self.currentStat[indexPath.item].reblogsCount, imageText4: self.currentStat[indexPath.item].id)
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
        }
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
        return UIMenu(__title: "", image: nil, identifier: nil, children: [share, save])
    }
}
