//
//  GalleryMediaViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 09/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class GalleryMediaViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var chosenUser: Account!
    var profileStatusesImages: [Status] = []
    
    override func viewDidLayoutSubviews() {
        self.collectionView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Gallery".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]

        if UIDevice.current.userInterfaceIdiom == .pad {
            let layout = ColumnFlowLayout(
                cellsPerRow: 7,
                minimumInteritemSpacing: 5,
                minimumLineSpacing: 5,
                sectionInset: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            )
            self.collectionView = UICollectionView(frame: CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height), collectionViewLayout: layout)
        } else {
            let layout = ColumnFlowLayout(
                cellsPerRow: 4,
                minimumInteritemSpacing: 5,
                minimumLineSpacing: 5,
                sectionInset: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            )
            self.collectionView = UICollectionView(frame: CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height), collectionViewLayout: layout)
        }
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        self.view.addSubview(self.collectionView)
        self.collectionView.reloadData()
    }
    
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileStatusesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let x = 7
            let y = (self.view.bounds.width) - 30
            let z = CGFloat(y)/CGFloat(x)
            return CGSize(width: z - 7.5, height: z - 7.5)
        } else {
            let x = 4
            let y = (self.view.bounds.width) - 30
            let z = CGFloat(y)/CGFloat(x)
            return CGSize(width: z - 7.5, height: z - 7.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure()
        cell.image.image = nil
        guard let imageURL = URL(string: self.profileStatusesImages[indexPath.row].mediaAttachments.first?.previewURL ?? "") else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configure()
            cell.image.image = nil
            cell.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor(named: "baseGray")
            return cell
        }
        cell.image.sd_setImage(with: imageURL, completed: nil)
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
    
    func fetchMoreImages() {
        let request = Accounts.statuses(id: self.chosenUser.id, mediaOnly: true, pinnedOnly: nil, excludeReplies: true, excludeReblogs: true, range: .max(id: self.profileStatusesImages.last?.id ?? "", limit: 5000))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        self.profileStatusesImages = self.profileStatusesImages + stat
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}







