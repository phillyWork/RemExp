//
//  HistoryCells.swift
//  RemExp
//
//  Created by Heedon on 2023/06/20.
//

import UIKit

final class HistoryCell: UITableViewCell {
    
    //MARK: - Properties
   
    //get data from HistoryVC
    //model to check if it got data
    var userProduct: UserProduct? {
        didSet {
            configureData()
        }
    }
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = viewBackgroundColor
        return iv
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "brandName"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let itemLabel: UILabel = {
        let label = UILabel()
        label.text = "itemName"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    func configureUI() {
        
        self.backgroundColor = cellColor
        self.layer.cornerRadius = 8
        
        contentView.addSubview(itemImageView)
        itemImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        itemImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        contentView.addSubview(brandLabel)
        brandLabel.anchor(top: nil, left: itemImageView.rightAnchor, bottom: self.centerYAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)

        contentView.addSubview(itemLabel)
        itemLabel.anchor(top: self.centerYAnchor, left: itemImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    
    //MARK: - API
    
    func configureData() {
        guard let userProduct = userProduct else { return }
        loadImage(with: userProduct.product.imageUrl)
        itemLabel.text = userProduct.product.productName
        brandLabel.text = userProduct.product.brandName
    }
    
    //url 활용 image load
    private func loadImage(with imageUrl: String?) {
        guard let urlString = imageUrl, let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.itemImageView.image = UIImage(data: data)
            }
        }
    }
}

