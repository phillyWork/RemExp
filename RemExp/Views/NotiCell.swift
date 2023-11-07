//
//  NotiCell.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit

//외부용 NotiCell은 cell 왼쪽에 앱 아이콘 추가하기

final class NotiCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private let itemLabel: UILabel = {
        let label = UILabel()
        label.text = "itemName"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let dateLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "7일 남았음"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let sendDateLabel: UILabel = {
        let label = UILabel()
        label.text = "5월 10일 11:11 AM"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - UI
    
    func configureUI() {
        self.backgroundColor = cellColor
        self.layer.cornerRadius = 8
        
        contentView.addSubview(itemLabel)
        itemLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        contentView.addSubview(dateLeftLabel)
        dateLeftLabel.anchor(top: itemLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        dateLeftLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        contentView.addSubview(sendDateLabel)
        sendDateLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    
}
