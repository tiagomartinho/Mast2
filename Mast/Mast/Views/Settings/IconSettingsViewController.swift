//
//  IconSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 09/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class IconSettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var appArrayIcons = ["icon1", "icon2", "icon3", "icon4", "icon5", "icon6", "icon7", "icon8", "icon9", "icon10", "icon11", "icon12", "icon29", "icon30", "icon31", "icon32", "icon13", "icon14", "icon15", "icon16", "icon17", "icon18", "icon19", "icon20", "icon21", "icon22", "icon23", "icon24", "icon25", "icon26", "icon27", "icon28", "icon33", "icon34", "icon35", "icon36", "icon37", "icon38", "icon39", "icon40"]
    var appArray = ["AppIcon-1", "AppIcon-2", "AppIcon-3", "AppIcon-4", "AppIcon-5", "AppIcon-6", "AppIcon-7", "AppIcon-8", "AppIcon-9", "AppIcon-10", "AppIcon-11", "AppIcon-12", "AppIcon-29", "AppIcon-30", "AppIcon-31", "AppIcon-32", "AppIcon-13", "AppIcon-14", "AppIcon-15", "AppIcon-16", "AppIcon-17", "AppIcon-18", "AppIcon-19", "AppIcon-20", "AppIcon-21", "AppIcon-22", "AppIcon-23", "AppIcon-24", "AppIcon-25", "AppIcon-26", "AppIcon-27", "AppIcon-28", "AppIcon-33", "AppIcon-34", "AppIcon-35", "AppIcon-36", "AppIcon-37", "AppIcon-38", "AppIcon-39", "AppIcon-40"]
    
    override func viewDidLayoutSubviews() {
        self.collectionView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "App Icon".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]

        if UIDevice.current.userInterfaceIdiom == .pad {
            let layout = ColumnFlowLayout(
                cellsPerRow: 7,
                minimumInteritemSpacing: 5,
                minimumLineSpacing: 5,
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            )
            self.collectionView = UICollectionView(frame: CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height), collectionViewLayout: layout)
        } else {
            let layout = ColumnFlowLayout(
                cellsPerRow: 4,
                minimumInteritemSpacing: 5,
                minimumLineSpacing: 5,
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        return self.appArrayIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let x = 7
            let y = (self.view.bounds.width) - 20
            let z = CGFloat(y)/CGFloat(x)
            return CGSize(width: z - 5, height: z - 5)
        } else {
            let x = 4
            let y = (self.view.bounds.width) - 20
            let z = CGFloat(y)/CGFloat(x)
            return CGSize(width: z - 5, height: z - 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure()
        cell.image.image = nil
        cell.image.image = UIImage(named: self.appArrayIcons[indexPath.row])
        cell.image.contentMode = .scaleAspectFill
        cell.layer.cornerRadius = 20
        cell.layer.cornerCurve = .continuous
        cell.image.layer.cornerRadius = 20
        cell.image.layer.cornerCurve = .continuous
        cell.image.layer.masksToBounds = true
        cell.imageCountTag.alpha = 0
        cell.image.frame.size.width = cell.frame.size.width
        cell.image.frame.size.height = cell.frame.size.height
        cell.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor(named: "baseGray")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        #if !targetEnvironment(macCatalyst)
//        if GlobalStruct.iapPurchased {
            let imp = UIImpactFeedbackGenerator(style: .light)
            imp.impactOccurred()
            if indexPath.item == 0 {
                UIApplication.shared.setAlternateIconName(nil)
            } else {
                UIApplication.shared.setAlternateIconName(self.appArray[indexPath.row])
            }
//        } else {
//            let vc = IAPSettingsViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        #elseif targetEnvironment(macCatalyst)
        let imp = UIImpactFeedbackGenerator(style: .light)
        imp.impactOccurred()
        if indexPath.item == 0 {
            UIApplication.shared.setAlternateIconName(nil)
        } else {
            UIApplication.shared.setAlternateIconName(self.appArray[indexPath.row])
        }
        #endif
    }
}






