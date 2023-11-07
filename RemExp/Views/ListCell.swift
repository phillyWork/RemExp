//
//  ListCell.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit

final class ListCell: UITableViewCell {
    
    //MARK: - Properties
   
    //get data from ListVC
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
    
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.text = "D - 7"
        label.textColor = expirationColor1
        label.font = UIFont.boldSystemFont(ofSize: 25)
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
        
        contentView.addSubview(expirationLabel)
        expirationLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        expirationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
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
        
        let today = Date()
        let leftDays = numberOfDaysBetween(today, and: userProduct.expiresAt)
        
        //임의로 3일, 7일, 30일 기준으로 색깔 설정
        if leftDays <= 3 {
            expirationLabel.textColor = expirationColor1
        } else if leftDays <= 7 {
            expirationLabel.textColor = expirationColor2
        } else {
            expirationLabel.textColor = expirationColor3
        }
        
        if leftDays < 0 {
            let resultDays = abs(leftDays)
            expirationLabel.text = "D + \(resultDays)"
        } else if leftDays == 0 {
            expirationLabel.text = "D - Day"
        } else {
            expirationLabel.text = "D - \(leftDays)"
        }
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
    
    private func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = Calendar(identifier: .gregorian) .startOfDay(for: from)
        let toDate = Calendar(identifier: .gregorian).startOfDay(for: to)
        let numberOfDays = Calendar(identifier: .gregorian).dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
    
}
