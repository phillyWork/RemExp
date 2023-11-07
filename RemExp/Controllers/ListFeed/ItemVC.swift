//
//  ItemVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import SafariServices

final class ItemVC: UIViewController {

    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    //ListVC에서 넘어오는 userProduct data 받기
    var userProduct: UserProduct? {
        didSet {
            configureData()
        }
    }
    
    private let itemImageVIew: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let labelContainer: UIView = {
        let container = UIView()
        container.backgroundColor = viewBackgroundColor
        return container
    }()
    
    private let brandLabel: UILabel =  {
        let label = UILabel()
        label.text = "brandName"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private let productLabel: UILabel = {
        let label = UILabel()
        label.text = "itemName"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "YYYY-MM-DD"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.text = "D - 7"
        label.textColor = expirationColor1
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
//    private let tipsView: UITextView = {
//        let tip = UITextView()
//        tip.backgroundColor = cellColor
//        tip.font = UIFont.systemFont(ofSize: 14)
//        tip.textColor = viewTextColor
//        tip.text = "this is tip box"
//        tip.layer.cornerRadius = 5
//        return tip
//    }()
    
    private lazy var coupangButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.setTitle("쿠팡에서 주문하기", for: .normal)
        button.setTitleColor(viewTextColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = brandColor
        
        button.addTarget(self, action: #selector(handleCoupangButton), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavController()
        
        configureUI()
        
    }
    
    private func configureNavController() {
        
        let backButton = UIBarButtonItem()
        backButton.title = "목록으로"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = viewTextColor
                
        let editButton = UIBarButtonItem(title: "수정하기", style: .plain, target: self, action: #selector(handleEditButton))
        navigationItem.rightBarButtonItem = editButton
    }
    
    
    private func configureUI() {
        
        view.backgroundColor = viewBackgroundColor
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(itemImageVIew)
        itemImageVIew.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 45, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 200, height: 200)
        
        view.addSubview(coupangButton)
        coupangButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 20, paddingRight: 10, width: 0, height: 40)
        
//        view.addSubview(tipsView)
//        tipsView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: coupangButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 20, paddingRight: 10, width: 0, height: 150)
        
        view.addSubview(labelContainer)
        labelContainer.anchor(top: itemImageVIew.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: coupangButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
//        labelContainer.anchor(top: itemImageVIew.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: tipsView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        labelContainer.addSubview(brandLabel)
        brandLabel.anchor(top: labelContainer.topAnchor, left: labelContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        labelContainer.addSubview(productLabel)
        productLabel.anchor(top: brandLabel.bottomAnchor, left: labelContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        productLabel.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor).isActive = true
        
        labelContainer.addSubview(dateLabel)
        dateLabel.anchor(top: productLabel.bottomAnchor, left: labelContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        labelContainer.addSubview(expirationLabel)
        expirationLabel.anchor(top: itemImageVIew.bottomAnchor, left: nil, bottom: nil, right: labelContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        expirationLabel.centerYAnchor.constraint(equalTo: productLabel.centerYAnchor).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Handlers
    
    @objc func handleEditButton() {
        let addItemVC = AddItemVC()
        
        //해당 item 정보 같이 넘기기
        addItemVC.existUserProduct = self.userProduct
        
        //delegate
        addItemVC.updateUserProductDelegate = self
        
        let navController = UINavigationController(rootViewController: addItemVC)
        navController.navigationBar.tintColor = viewTextColor
        navController.modalPresentationStyle = .fullScreen
            
        present(navController, animated: true)
    }
    
    @objc func handleCoupangButton() {
        guard let brandName = brandLabel.text else { return }
        guard let itemName = productLabel.text else { return }
        
        let splitBrand = brandName.split(separator: " ")
        let splitItem = itemName.split(separator: " ")
        
        print("split: \(splitBrand) and \(splitItem)")
        
        var brand: String = ""
        var item: String = ""
        
        for split in splitBrand {
            brand.append(String(split))
        }
        
        for split in splitItem {
            item.append(String(split))
        }
            
        let requestUrl = "https://www.coupang.com/np/search?component=&q=\(brand)+\(item)"
        let encodedUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: encodedUrl) else {
            print("Can't make url from encodedUrl")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    //MARK: - API
    
    func configureData() {
        print("UsrProduct data from ListVC moved to ItemVC")
        
        guard let userProduct = self.userProduct else {
            print("Nothing to show userProduct in ItemVC")
            return
        }
        
        loadImage(with: userProduct.product.imageUrl)
        
        DispatchQueue.main.async {
            self.productLabel.text = userProduct.product.productName
            self.brandLabel.text = userProduct.product.brandName
        
            let today = Date.now
            
            let leftDays = self.numberOfDaysBetween(today, and: userProduct.expiresAt)
            //3일, 7일, 30일 기준으로 색깔 설정
            if leftDays <= 3 {
                self.expirationLabel.textColor = expirationColor1
            } else if leftDays <= 7 {
                self.expirationLabel.textColor = expirationColor2
            } else {
                self.expirationLabel.textColor = expirationColor3
            }
            
            if leftDays < 0 {
                let resultDays = abs(leftDays)
                self.expirationLabel.text = "D + \(resultDays)"
            } else if leftDays == 0 {
                self.expirationLabel.text = "D - Day"
            } else {
                self.expirationLabel.text = "D - \(leftDays)"
            }
            
            let expDateFormatter = DateFormatter()
            expDateFormatter.dateFormat = "YYYY-MM-dd"
            self.dateLabel.text = expDateFormatter.string(from: userProduct.expiresAt)
            
            print("userProduct: \(userProduct)")
        }
    }
    
    //url 활용 image 가져오기
    private func loadImage(with imageUrl: String?) {
        guard let urlString = imageUrl, let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.itemImageVIew.image = UIImage(data: data)
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

//MARK: - Delegate for Updating UserProduct from AddItemVC to UI

extension ItemVC: UpdateItemDelegate {
    
    func didUpdateItem(_ userProduct: UserProduct) {
        print("updated UserProduct data from AddItemVC moved to ItemVC")
        
        loadImage(with: userProduct.product.imageUrl)
        
        DispatchQueue.main.async {
            self.productLabel.text = userProduct.product.productName
            self.brandLabel.text = userProduct.product.brandName
        
            let leftDays = self.numberOfDaysBetween(userProduct.createdAt, and: userProduct.expiresAt)
            //3일, 7일, 30일 기준으로 색깔 설정
            if leftDays <= 3 {
                self.expirationLabel.textColor = expirationColor1
            } else if leftDays <= 7 {
                self.expirationLabel.textColor = expirationColor2
            } else {
                self.expirationLabel.textColor = expirationColor3
            }
            
            if leftDays < 0 {
                let resultDays = abs(leftDays)
                self.expirationLabel.text = "D + \(resultDays)"
            } else if leftDays == 0 {
                self.expirationLabel.text = "D - Day"
            } else {
                self.expirationLabel.text = "D - \(leftDays)"
            }
            
            let expDateFormatter = DateFormatter()
            expDateFormatter.dateFormat = "YYYY-MM-dd" 
            self.dateLabel.text = expDateFormatter.string(from: userProduct.expiresAt)
            
            print("userProduct: \(userProduct)")
        }
    }
}
