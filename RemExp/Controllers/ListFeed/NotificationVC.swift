//
//  NotificationVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotiCell"

final class NotificationVC: UIViewController {

    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.backgroundColor = viewBackgroundColor
        collection.register(NotiCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        return collection
    }()
    
    
    //MARK: - Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        configureNavController()

        configureUI()
    }
    
    private func configureNavController() {
        navigationItem.title = "알림"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleCloseButton))
        navigationItem.leftBarButtonItem?.tintColor = viewTextColor
    }
    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    //MARK: - Handlers
    
    @objc func handleCloseButton() {
        self.dismiss(animated: true)
    }

}

extension NotificationVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NotiCell
        cell.backgroundColor = cellColor
        //item 전달
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 60)
    }
    
}
