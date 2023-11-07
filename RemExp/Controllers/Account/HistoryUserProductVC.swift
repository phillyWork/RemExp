//
//  HistoryUserProductsVC.swift
//  RemExp
//
//  Created by Heedon on 2023/06/20.
//

import UIKit
import Firebase
import SafariServices

private let reuseIdentifier = "HistoryCell"

final class HistoryUserProductVC: UIViewController {
    
    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        
        table.backgroundColor = viewBackgroundColor
        table.register(HistoryCell.self, forCellReuseIdentifier: reuseIdentifier)
        table.allowsSelection = false  //no selection
        
        return table
    }()
    
    //MARK: - Setting UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure Nav Bar
        configureNavController()
        
        //delegate
        tableView.dataSource = self
        tableView.delegate = self
    
        //for custom section
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        configureUI()
    }
    
    private func configureNavController() {
        let backButton = UIBarButtonItem()
        backButton.title = "계정으로"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = viewTextColor
    }
    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        tabBarController?.tabBar.isHidden = true
    
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
}

//MARK: - Delegate and Datasource for TableView

extension HistoryUserProductVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.getConfirmedUserProducts().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HistoryCell
        cell.backgroundColor = cellColor
        
        let userProduct = dataManager.getConfirmedUserProducts()[indexPath.row]
        cell.userProduct = userProduct
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    //header 역할의 section custom하기
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    //swipe from left to right
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "삭제하기") { action, view, completionHandler in
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.dataManager.deleteUsedUserProduct(uid: uid, indexPath: indexPath) { didSuccess in
                switch didSuccess {
                case true:
                    print("Deletion UserProduct completed!")
                    
                    //dataManager의 array에서도 삭제
                    self.dataManager.deleteCurrentUsedUserProduct(indexPath: indexPath)
                    
                    //tableView에서 삭제하기
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    //tableView refresh
                    tableView.reloadData()
                    
                    completionHandler(true)
                case false:
                    print("Deletion UserProduct failed")
                    
                    let alert = UIAlertController(title: "등록된 제품 삭제에 실패했습니다.", message: "다시 시도해주세요.", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    
                    completionHandler(false)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //swipe from right to left
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        //1번: 되돌리기
        let action1 = UIContextualAction(style: .normal, title: "되돌리기") { action, view, completionHandler in
            //해당 userProduct의 isUsed "false"로 만들기
            self.dataManager.undoConfirmUserProduct(uid: uid, indexPath: indexPath) { didSucceed in
                switch didSucceed {
                case true:
                    print("Changing isUsed status to false succeed")
                    
                    //dataManager도 수정: isUsedFalse에서 isUsedTrue로 넘기기
                    self.dataManager.applyUndoConfirmationUserProduct(indexPath: indexPath)
                    
                    //tableView에서 삭제하기
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    //tableView refresh
                    tableView.reloadData()
                    
                    print("confirmed action performed")
                    completionHandler(true)
                case false:
                    print("Changing isUsed status failed")
                    completionHandler(false)
                }
            }
        }
        action1.backgroundColor = expirationColor2
        
        //2번: 쿠팡으로 넘어가기
        let action2 = UIContextualAction(style: .normal, title: "쿠팡 재주문") { action, view, completionHandler in
            let brandName = self.dataManager.getConfirmedUserProducts()[indexPath.row].product.brandName
            let productName = self.dataManager.getConfirmedUserProducts()[indexPath.row].product.productName
            
            let splitBrand = brandName.split(separator: " ")
            let splitItem = productName.split(separator: " ")
            
            var brand: String = ""
            var product: String = ""
            
            for split in splitBrand {
                brand.append(String(split))
            }
            
            for split in splitItem {
                product.append(String(split))
            }
            
            let requestUrl = "https://www.coupang.com/np/search?component=&q=\(brand)+\(product)"
            let encodedUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            guard let url = URL(string: encodedUrl) else {
                print("Can't make url from encodedUrl")
                return
            }
            
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true)
            completionHandler(true)
        }
        action2.backgroundColor = brandColor
        
        return UISwipeActionsConfiguration(actions: [action2, action1])
    }
}
