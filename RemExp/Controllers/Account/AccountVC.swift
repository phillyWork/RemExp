//
//  AccountVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Charts

private let reuseIdentifier = "Cell"

final class AccountVC: UIViewController {
    
    //MARK: - Properties

    let dataManager = DataManager.shared
    
    var currentUser: User?
    
    // "사용완료/전체" 보여주기
    private let statChart: PieChartView = {
        let chart = PieChartView()
        chart.usePercentValuesEnabled = true
        chart.drawSlicesUnderHoleEnabled = false
        chart.holeRadiusPercent = 0.58
        chart.transparentCircleRadiusPercent = 0.61
        chart.chartDescription.enabled = false
        chart.drawCenterTextEnabled = true
        chart.drawHoleEnabled = true
        chart.rotationAngle = 0
        chart.rotationEnabled = true
        chart.highlightPerTapEnabled = true
        
        //default data (no data)
        chart.noDataText = "통계 데이터가 없습니다."
        chart.noDataFont = .systemFont(ofSize: 20)
        chart.noDataTextColor = viewTextColor!
        chart.backgroundColor = cellColor
        
        //setting legend
        let l = chart.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        
        chart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        return chart
    }()
    
    private lazy var statButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = viewTextColor
        button.backgroundColor = brandColor
        button.setTitle("분석 더 보기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5

        button.addTarget(self, action: #selector(handleStatButton), for: .touchUpInside)

        return button
    }()

    //user info
    private let userInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = viewBackgroundColor
        return view
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.text = "유저 정보"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정하기", for: .normal)
        button.tintColor = blueButtonColor
        button.backgroundColor = viewBackgroundColor
        
        button.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        
        return button
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "email"
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = cellColor
        label.layer.cornerRadius = 5
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "nickname"
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = cellColor
        label.layer.cornerRadius = 5
        return label
    }()
    
    private lazy var moveToHistory: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.setTitle("사용 완료한 제품 목록 보기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = viewTextColor
        button.backgroundColor = brandColor
        
        button.addTarget(self, action: #selector(handleMoveToHistory), for: .touchUpInside)
        
        return button
    }()
    
    //logout button
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = viewTextColor
        button.backgroundColor = brandColor
    
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupStatData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavController()
                
        configureUI()
        
        setupUserData()
    }
    
    private func configureNavController() {
        let titleLabel = UILabel()
        titleLabel.textColor = viewTextColor
        titleLabel.text = "계정"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }

    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
    
        view.addSubview(statChart)
        statChart.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        
        view.addSubview(statButton)
        statButton.anchor(top: statChart.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 30)
        
        view.addSubview(userInfoContainer)
        userInfoContainer.anchor(top: statButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)

        userInfoContainer.addSubview(userLabel)
        userLabel.anchor(top: userInfoContainer.topAnchor, left: userInfoContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        userInfoContainer.addSubview(editButton)
        editButton.anchor(top: userInfoContainer.topAnchor, left: nil, bottom: nil, right: userInfoContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        
        let stackView = UIStackView(arrangedSubviews: [emailLabel, nicknameLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        userInfoContainer.addSubview(stackView)
        stackView.anchor(top: userLabel.bottomAnchor, left: userInfoContainer.leftAnchor, bottom: userInfoContainer.bottomAnchor, right: userInfoContainer.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
 
        view.addSubview(moveToHistory)
        moveToHistory.anchor(top: userInfoContainer.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 30)
        
        
        view.addSubview(logoutButton)
        logoutButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 20, paddingRight: 10, width: 0, height: 30)
    }
    
    //MARK: - API
    
    private func setupUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //get currentUser data from db
        DispatchQueue.global().async {
            DB_USERS.document("\(uid)").getDocument { document, error in
                if let error = error {
                    print("Fetching user from DB failed: \(error.localizedDescription)")
                    return
                }
                
                print("Fetch user from DB success")
                
                if let document = document, document.exists {
                    print("Got user data from document")
                    let data = document.data()!
                    print("data: \(data)")
                    
                    let email = data["email"] as! String
                    let nickName = data["nickName"] as! String
                    
                    //set user data
                    self.currentUser = User(uid: uid, email: email, nickName: nickName)
                    
                    DispatchQueue.main.async {
                        //set labels
                        self.emailLabel.text = self.currentUser?.email
                        self.nicknameLabel.text = self.currentUser?.nickName
                    }
                }
            }
        }
    }
    
    //기본 설정
    private func setupStatData() {
        //data for stats
        let dataValues = [Double(dataManager.getCurrentNotUsedUserProducts().count), Double(dataManager.getConfirmedUserProducts().count)]
        
        //pie chart
        self.setPieData(pieChartView: self.statChart, pieChartDataEntries: self.entryDataForPieChart(values: dataValues))
    }
    
    //데이터 셋 설정, 차트에 적용
    private func setPieData(pieChartView: PieChartView, pieChartDataEntries: [ChartDataEntry]) {
        
        //데이터 셋 만들기
        let pieChartdataSet = PieChartDataSet(entries: pieChartDataEntries, label: "사용 완료 여부")
        //사용완료 ~ brandColor / 사용미완료 ~ expirationColor1
        pieChartdataSet.colors = [expirationColor1!, brandColor!]
        //차트 데이터 만들기
        let pieChartData = PieChartData(dataSet: pieChartdataSet)
        //데이터 적용
        pieChartView.data = pieChartData
    }
    
    //entry 만들기
    private func entryDataForPieChart(values: [Double]) -> [PieChartDataEntry] {
        //엔트리 생성
        var pieDataEntries: [PieChartDataEntry] = []
        //데이터 값만큼
        for i in 0..<values.count {
            if i%2 == 0 {
                let pieDataEntry = PieChartDataEntry(value: values[i], label: "사용 전")
                pieDataEntries.append(pieDataEntry)
            } else {
                let pieDataEntry = PieChartDataEntry(value: values[i], label: "사용 후")
                pieDataEntries.append(pieDataEntry)
            }
        }
        return pieDataEntries
    }
    
    //MARK: - Handlers
    
    @objc func handleStatButton() {
        let statVC = StatVC()

        navigationController?.pushViewController(statVC, animated: true)
    }
    
    @objc func handleEditButton() {
        let settingVC = SettingVC()
        
        //delegate 설정
        settingVC.delegate = self
        
        //User 데이터 전달
        settingVC.user = self.currentUser
        
        let navController = UINavigationController(rootViewController: settingVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func handleMoveToHistory() {
        let historyVC = HistoryUserProductVC()
        
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc func handleLogout() {
        //logout on server & move to loginVC
        do {
            try Auth.auth().signOut()
            let loginVC = LoginVC()
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Failed to Sign Out, %@", signOutError)
        }
    }
    
}

//MARK: - Delegate for User Update

extension AccountVC: UserDelegate {
    
    func updateNickName(_ user: User) {
        //update nickname
        DB_USERS.document("\(user.uid)").updateData(["nickName": user.nickName]) { error in
            if let error = error {
                print("Failed to upload new nickname into db: \(error.localizedDescription)")
                return
            }
            print("Succeed to upload new nickname into db")
            DispatchQueue.main.async {
                self.nicknameLabel.text = user.nickName
            }
        }
        
        //set currentUser as newUser
        self.currentUser = user
    }
    
}
