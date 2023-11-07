//
//  ListVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase
import FirebaseAuth

import GoogleMobileAds

private let reuseIdentifier = "ListCell"
private let segueIdentifier = "ItemVC"

final class ListVC: UIViewController {
    
    //MARK: - Properties
    
    //UserProduct 관리
    let dataManager = DataManager.shared
    
    var isSortForAlphabet = false

    //Ad placeholder
    private var googleNativeAdPlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = viewBackgroundColor
        return view
    }()
    
    //Google Native Ad Loader
    var adLoader: GADAdLoader!
    //Native Ad View
    var nativeAdView: GADNativeAdView!
    //Height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    
    private let sortingViewContainer: UIView = {
        let sortView = UIView()
        sortView.backgroundColor = viewBackgroundColor
        return sortView
    }()
    
    private let label1: UILabel = {
        let label = UILabel()
        label.text = "정렬: "
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.text = "임박한 순서대로"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(sortImage, for: .normal)
        button.tintColor = viewTextColor
        button.addTarget(self, action: #selector(handleSortingButton), for: .touchUpInside)
        return button
    }()
        
    private let tableView: UITableView = {
        let collection = UITableView(frame: .zero, style: .insetGrouped)
        
        collection.backgroundColor = viewBackgroundColor
        collection.register(ListCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        return collection
    }()

    //MARK: - Setup UI

    //AddItemVC에서 upload or update 한 경우, tableView에 표시될 데이터 업데이트
    //ItemVC에서 다시 돌아올 때도 실행된다는 단점 존재
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reload ads
        adLoader.load(GADRequest())
        
        tableView.reloadData()
    }
    
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
                
        setupData()
        
        setGoogleAds()
    }
    
    private func configureNavController() {
        
        let titleLabel = UILabel()
        titleLabel.textColor = viewTextColor
        titleLabel.text = "유통기한"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: notificationImage, style: .plain, target: self, action: #selector(handleNotificationButton))
//        navigationItem.rightBarButtonItem?.tintColor = viewTextColor
    }

    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        
        view.addSubview(sortingViewContainer)
        sortingViewContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        
        sortingViewContainer.addSubview(label1)
        label1.anchor(top: sortingViewContainer.topAnchor, left: sortingViewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        label1.centerYAnchor.constraint(equalTo: sortingViewContainer.centerYAnchor).isActive = true
        
        sortingViewContainer.addSubview(sortLabel)
        sortLabel.anchor(top: sortingViewContainer.topAnchor, left: label1.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        sortLabel.centerYAnchor.constraint(equalTo: sortingViewContainer.centerYAnchor).isActive = true
        
        sortingViewContainer.addSubview(sortButton)
        sortButton.anchor(top: sortingViewContainer.topAnchor, left: nil, bottom: nil, right: sortingViewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 40, height: 40)
        sortButton.centerYAnchor.constraint(equalTo: sortingViewContainer.centerYAnchor).isActive = true
        
        view.addSubview(googleNativeAdPlaceholder)
        googleNativeAdPlaceholder.anchor(top: sortingViewContainer.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 304)
        
        view.addSubview(tableView)
//        tableView.anchor(top: sortingViewContainer.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.anchor(top: googleNativeAdPlaceholder.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
    //MARK: - Handlers
    
    @objc func handleNotificationButton() {
        let notiVC = NotificationVC()
        let navController = UINavigationController(rootViewController: notiVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func handleSortingButton() {
        if isSortForAlphabet {
            dataManager.sortByExpiration()
            sortLabel.text = "임박한 순서대로"
            tableView.reloadData()
            isSortForAlphabet.toggle()
        } else {
            dataManager.sortByAlphabet()
            sortLabel.text = "이름 순서대로"
            tableView.reloadData()
            isSortForAlphabet.toggle()
        }
    }
        
    //MARK: - API
    
    private func setupData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        dataManager.fetchUserProductFromDB(with: uid) {
            //DB에서 데이터 가지고 오면 tableView reload
            self.tableView.reloadData()
        }
    }
    
    private func setGoogleAds() {
        print("Setting Google Ads")

        guard let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil), let adView = nibObjects.first as? GADNativeAdView else {
            assert(false, "Could not load nib files for adView")
            return
        }
        
        setAdView(adView)

        adLoader = GADAdLoader(adUnitID: APIKey.admob, rootViewController: self, adTypes: [.native], options: nil)
        //delegate setting
        adLoader.delegate = self
        //load ads
        adLoader.load(GADRequest())
    }
    
    private func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        googleNativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height of the googleNatvieAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
          NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[_nativeAdView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
          NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[_nativeAdView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
}

// MARK: - TableView Delegates
extension ListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.getCurrentNotUsedUserProducts().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell for regular data
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListCell
        cell.backgroundColor = cellColor
        
        //dataManager 통해서 받아온 userProduct 데이터 cell로 전달
        //isUsed가 false인 [UserProduct] 받기
        let userProduct = dataManager.getCurrentNotUsedUserProducts()[indexPath.row]
        cell.userProduct = userProduct
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemVC = ItemVC()
    
        //해당 userProduct 전달
        itemVC.userProduct = dataManager.getCurrentNotUsedUserProducts()[indexPath.row]
    
        //push navigation
        navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //header 역할의 section custom하기
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    //swipe from left to right
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "삭제하기") { action, view, completionHandler in
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.dataManager.deleteNotUsedUserProduct(uid: uid, indexPath: indexPath) { didSuccess in
                switch didSuccess {
                case true:
                    print("Deletion UserProduct completed!")
                    
                    //dataManager의 array에서도 삭제
                    self.dataManager.deleteCurrentNotUsedUserProduct(indexPath: indexPath)
                    
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
        let action = UIContextualAction(style: .normal, title: "사용 완료") { action, view, completionHandler in
            
            //해당 userProduct의 isUsed "true"로 만들기

            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.dataManager.confirmUserProduct(uid: uid, indexPath: indexPath) { didSucceed in
                switch didSucceed {
                case true:
                    print("Changing isUsed status succeed")
                    
                    //dataManager도 수정: isUsedFalse에서 isUsedTrue로 넘기기
                    self.dataManager.applyConfirmationUserProduct(indexPath: indexPath)
                    
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
        action.backgroundColor = brandColor
        return UISwipeActionsConfiguration(actions: [action])
    }
 
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard velocity.y != 0 else { return }
            
            if velocity.y < 0 {
                let height = self?.tabBarController?.tabBar.frame.height ?? 0.0
                self?.tabBarController?.tabBar.alpha = 1.0
                self?.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - height)
            } else {
                self?.tabBarController?.tabBar.alpha = 0.0
                self?.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
            }
        }
    }
    
}


//MARK: - Extension for GADNativeAdLoaderDelegate, GADNativeAdDelegate

extension ListVC: GADNativeAdLoaderDelegate {
    
    // Handle the loaded ad
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        // A native ad has loaded, and can be displayed
        print("It's loading ads")
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        // Some native ads will include a video asset, while others do not. Apps can use the GADVideoController's hasVideoContent property to determine if one is present, and adjust their UI accordingly.
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            // By acting as the delegate to the GADVideoController, this ViewController receives messages about events in the video lifecycle.
            mediaContent.videoController.delegate = self
        }
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect ratio of the media it displays.
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint?.isActive = true
        }
        
        
        // These assets are not guaranteed to be present. Check that they are before showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
        
    }
    
    // Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    // if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else { return nil }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    // Handle ad loading failure
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native ad failed to load: \(error.localizedDescription)")
    }
    
}

//MARK: - Extension for GADVideoControllerDelegate

extension ListVC: GADVideoControllerDelegate {
    
}

//MARK: - Extension for GADNativeAdDelegate

extension ListVC: GADNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
      print("\(#function) called")
    }
    
}


