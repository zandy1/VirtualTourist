//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation
import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoAlbumImageView: UIImageView!
    
    var spinner = UIActivityIndicatorView(style: .large)

            override init(frame: CGRect) {
                super.init(frame: frame)
                commonInit()
            }

            required init?(coder: NSCoder) {
                super.init(coder: coder)
                commonInit()
            }

            private func commonInit() {
                 spinner.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(spinner)
                
                spinner.hidesWhenStopped = true

                //spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                //spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
             }
}
