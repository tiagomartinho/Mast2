//
//  GalleryMediaViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 09/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class GalleryMediaViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var isSplitOrSlideOver: Bool {
        let windows = UIApplication.shared.windows
        for x in windows {
            if let z = self.view.window {
                if x == z {
                    if x.frame.width == x.screen.bounds.width || x.frame.width == x.screen.bounds.height {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
    var collectionView: UICollectionView!
    var chosenUser: Account!
    var profileStatusesImages: [Status] = []
    var images2: [UIImageView] = []
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        #if targetEnvironment(macCatalyst)
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.collectionView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            // Table
            let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.collectionView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        } else {
            // Table
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.collectionView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.backgroundColor = GlobalStruct.baseDarkTint
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Gallery".localized
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)

        let layout = ColumnFlowLayout(
            cellsPerRow: 3,
            minimumInteritemSpacing: 5,
            minimumLineSpacing: 5,
            sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        self.collectionView = UICollectionView(frame: CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height), collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ImageCell2.self, forCellWithReuseIdentifier: "ImageCell2")
        self.view.addSubview(self.collectionView)
        self.collectionView.reloadData()
        
        let _ = self.profileStatusesImages.map {_ in
            self.images2.append(UIImageView())
        }
    }
    
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileStatusesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = 3
        let y = (self.view.bounds.width) - 20
        let z = CGFloat(y)/CGFloat(x)
        return CGSize(width: z - 5, height: z - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell2", for: indexPath) as! ImageCell2
        cell.configure()
        cell.image.image = nil
        guard let imageURL = URL(string: self.profileStatusesImages[indexPath.row].mediaAttachments.first?.previewURL ?? "") else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell2", for: indexPath) as! ImageCell2
            cell.configure()
            cell.image.image = nil
            cell.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor(named: "baseGray")
            return cell
        }

        self.images2[indexPath.row].sd_setImage(with: imageURL, completed: nil)

        if self.profileStatusesImages[indexPath.row].mediaAttachments.first!.type == .video {
            cell.videoOverlay.alpha = 1
        } else {
            cell.videoOverlay.alpha = 0
        }
        
        if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int == 0 {
            if self.profileStatusesImages[indexPath.row].reblog?.sensitive ?? self.profileStatusesImages[indexPath.row].sensitive ?? true {
                let x = self.blurImage(imageURL)
                cell.image.sd_setImage(with: imageURL, completed: nil)
                cell.image.image = x
            } else {
                cell.image.sd_setImage(with: imageURL, completed: nil)
            }
        } else {
            cell.image.sd_setImage(with: imageURL, completed: nil)
        }
        
        cell.image.contentMode = .scaleAspectFill
        cell.layer.cornerRadius = 4
        cell.layer.cornerCurve = .continuous
        cell.image.layer.cornerRadius = 4
        cell.image.layer.cornerCurve = .continuous
        cell.image.layer.masksToBounds = true
        cell.imageCountTag.alpha = 0
        cell.image.frame.size.width = cell.frame.size.width
        cell.image.frame.size.height = cell.frame.size.height
        cell.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor(named: "baseGray")
        
        if indexPath.item == self.profileStatusesImages.count - 7 {
            self.fetchMoreImages()
        }
        
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
    
    func fetchMoreImages() {
        let request = Accounts.statuses(id: self.chosenUser.id, mediaOnly: true, pinnedOnly: nil, excludeReplies: true, excludeReblogs: true, range: .max(id: self.profileStatusesImages.last?.id ?? "", limit: 5000))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        self.profileStatusesImages = self.profileStatusesImages + stat
                        self.collectionView.reloadData()
                        
                        let _ = stat.map {_ in
                            self.images2.append(UIImageView())
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.profileStatusesImages[indexPath.item].mediaAttachments.first?.type == .video {
            if let ur = URL(string: self.profileStatusesImages[indexPath.item].mediaAttachments.first?.url ?? "") {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: URL(string: self.profileStatusesImages[indexPath.item].mediaAttachments.first?.remoteURL ?? self.profileStatusesImages[indexPath.item].mediaAttachments.first?.url ?? ""), imageText: "@\(self.profileStatusesImages[indexPath.item].account.username): \(self.profileStatusesImages[indexPath.item].content.stripHTML())", imageText2: self.profileStatusesImages[indexPath.item].favouritesCount, imageText3: self.profileStatusesImages[indexPath.item].reblogsCount, imageText4: self.profileStatusesImages[indexPath.item].id)
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! ImageCell2).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
        }
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
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell2 {
                activityViewController.popoverPresentationController?.sourceView = cell.image
                activityViewController.popoverPresentationController?.sourceRect = cell.image.bounds
            }
            self.getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
        }
        let save = UIAction(title: "Save".localized, image: UIImage(systemName: "square.and.arrow.down"), identifier: nil) { action in
            UIImageWriteToSavedPhotosAlbum(self.images2[indexPath.item].image ?? UIImage(), nil, nil, nil)
        }
        return UIMenu(__title: self.profileStatusesImages[indexPath.item].mediaAttachments.first?.description ?? "", image: nil, identifier: nil, children: [share, save])
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
}







