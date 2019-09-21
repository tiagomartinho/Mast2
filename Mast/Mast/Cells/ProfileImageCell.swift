//
//  ProfileImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ProfileImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var profileStatusesImages: [Status] = []
    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileStatusesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.profileStatusesImages.isEmpty {} else {
            cell.configure()
            if self.profileStatusesImages[indexPath.item].mediaAttachments.isEmpty {} else {
                let z = self.profileStatusesImages[indexPath.item].mediaAttachments[0].previewURL
                cell.image.contentMode = .scaleAspectFill
                if let imageURL = URL(string: z) {
                    cell.image.image = UIImage()
                    DispatchQueue.global().async {
                        guard let imageData = try? Data(contentsOf: imageURL) else { return }
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            cell.image.image = image
                            cell.image.layer.masksToBounds = true
                        }
                    }
                    cell.image.backgroundColor = UIColor(named: "baseWhite")
                    cell.image.layer.cornerRadius = 5
                    cell.image.layer.masksToBounds = true
                    cell.image.layer.borderColor = UIColor.black.cgColor
                    cell.image.frame.size.width = 160
                    cell.image.frame.size.height = 120
                    cell.bgImage.layer.masksToBounds = false
                    cell.bgImage.layer.shadowColor = UIColor.black.cgColor
                    cell.bgImage.layer.shadowRadius = 5
                    cell.bgImage.layer.shadowOpacity = 0.05
                    cell.bgImage.layer.shadowOffset = CGSize(width: 0, height: 6)
                }
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
