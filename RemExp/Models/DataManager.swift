//
//  UserModel.swift
//  RemExp
//
//  Created by Heedon on 2023/05/22.
//

import UIKit

final class DataManager {
    
    //singleton for various screens
    static let shared = DataManager()

    private init() {}
    
    private let networkManager = NetworkManager.shared
    
    //서버에서 받아온 유저의 userProduct 목록들
    //empty array to fetch user-products from db
//    var userProducts = [UserProduct]()
    
    //서버에서 받아올 data들
    //ListVC에만 보여줄 완료 처리되지 않은 userProduct 목록들
    private var isUsedFalseUserProducts = [UserProduct]()
    
    //AccountVC에서 사용 완료 처리된 userProduct 목록들
    private var isUsedTrueUserProducts = [UserProduct]()
    
    //In-app NotificationVC에서 활용될 notifications 목록들
    private var notifications = [Notification]()
    
    
    
    //MARK: - Fetch API
    
    func fetchUserProductFromDB(with uid: String, completion: @escaping () -> Void) {
        //clear existing arrays
        isUsedFalseUserProducts.removeAll(keepingCapacity: false)
        isUsedTrueUserProducts.removeAll(keepingCapacity: false)
        
        print("\(uid)의 UserProduct 가져오기")
        getUserProductFromDB(with: uid) {
            completion()
        }
    }
    
    //networkManager 통해 firestore db에서 데이터 가져오기
    private func getUserProductFromDB(with uid: String, completion: @escaping () -> Void) {
        networkManager.fetchUserProducts(with: uid) { result in
            switch result {
            case .success(let userProducts):
                self.isUsedCheck(with: userProducts)
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                completion()
            }
        }
    }
    
    //isUsed 구분하기
    private func isUsedCheck(with userProducts: [UserProduct]) {
        for product in userProducts {
            product.isUsed == true ? isUsedTrueUserProducts.append(product) : isUsedFalseUserProducts.append(product)
            isUsedFalseUserProducts.sort { $0.expiresAt < $1.expiresAt }
        }
    }
    
    
    func queryProductFromDB(barcode: String, completion: @escaping (_ product: Product?) -> Void) {
        networkManager.fetchProduct(with: barcode) { result in
            switch result {
            case .success(let product):
                print("Success to fetch product from DB")
                completion(product)
            case .failure(let error):
                print("Failed to fetch product from DB")
                completion(nil)
            }
        }
    }
    

    //MARK: - Upload API
    
    func queryDuplicateUserData(uid: String, email: String, nickName: String, completion: @escaping (_ result: Bool) -> Void) {
        networkManager.queryDuplicateUserData(uid: uid, email: email, nickName: nickName) { result in
            switch result {
            case true:
                print("Uploading user data to DB succeed")
                completion(true)
            case false:
                print("Uploading user data to DB failed")
                completion(false)
            }
        }
    }
    
    func uploadDataToDB(uid: String, uidForUserProduct: String, userProduct: UserProduct, isUpdate: Bool, completion: @escaping (_ result: Bool) -> Void) {

        print("uploadDataToDB by dataManager")

        networkManager.uploadItemToDB(uid: uid, uidForUserProduct: uidForUserProduct, userProduct: userProduct) { didSuccess in
            switch didSuccess {
            case false:
                print("dataManager's uploading user-product \(uidForUserProduct) to db failed")
                completion(false)
            case true:
                print("data manager's uploading user-product \(uidForUserProduct) to db succeed")
                if isUpdate {
                    //update: 기존 제품 삭제 후, 업데이트 한 제품 다시 넣기
                    guard let beforeUpdateUserProductIndex = self.isUsedFalseUserProducts.firstIndex(of: userProduct) else {
                        print("can't get index of userProduct to remove")
                        return
                    }
                    self.isUsedFalseUserProducts.remove(at: beforeUpdateUserProductIndex)
                    self.isUsedFalseUserProducts.insert(userProduct, at: beforeUpdateUserProductIndex)
                } else {
                    //upload: 바로 추가하기
                    //add to isUsedFalseUserProduct
                    self.isUsedFalseUserProducts.insert(userProduct, at: 0)
                }
                completion(true)
            }
        }
    }
    
    //MARK: - Data between VCs, dealing with UserProducts
    
    //for ListVC
    func getCurrentNotUsedUserProducts() -> [UserProduct] {
        return isUsedFalseUserProducts
    }
    
    //swipe from left to right: deletion of not used UserProduct in ListVC
    func deleteNotUsedUserProduct(uid: String, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        //해당 userProduct 삭제: userProduct의 uid 구하기
        let uidForUserProduct = isUsedFalseUserProducts[indexPath.row].uid
        
        networkManager.deleteUserProduct(uid: uid, uidForUserProduct: uidForUserProduct) { didSucceed in
            switch didSucceed {
            case true:
                print("network manager deletion request of not used userproduct succeed")
                completion(true)
            case false:
                print("network manager deletion request of not used userproduct failed")
                completion(false)
            }
        }
    }
    
    //swipe from left to right: deletion of used UserProduct in HistoryUserProductVC
    func deleteUsedUserProduct(uid: String, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        //해당 userProduct 삭제: userProduct의 uid 구하기
        let uidForUserProduct = isUsedTrueUserProducts[indexPath.row].uid
        
        networkManager.deleteUserProduct(uid: uid, uidForUserProduct: uidForUserProduct) { didSucceed in
            switch didSucceed {
            case true:
                print("network manager deletion request of used userproduct succeed")
                completion(true)
            case false:
                print("network manager deletion request of used userproduct failed")
                completion(false)
            }
        }
    }
    
    func deleteUserData(uid: String, completion: @escaping (Bool) -> Void) {
        networkManager.deleteUserData(uid: uid) { didSucceed in
            switch didSucceed {
            case true:
                print("networkManager successfully deleted user from db")
                completion(true)
            case false:
                print("networkManager failed to delete user from db")
                completion(false)
            }
        }
    }

    func deleteCurrentNotUsedUserProduct(indexPath: IndexPath) {
        isUsedFalseUserProducts.remove(at: indexPath.row)
        print("Deletion in dataManager's isUsedFalse array succeed")
    }

    func deleteCurrentUsedUserProduct(indexPath: IndexPath) {
        isUsedTrueUserProducts.remove(at: indexPath.row)
        print("Deletion in dataManager's isUsedTrue array succeed")
    }
    
    
    //swipe from right to left: confirm using UserProduct in ListVC
    func confirmUserProduct(uid: String, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        //해당 userProduct 사용 완료 ~ uid구하기
        let uidForUserProduct = isUsedFalseUserProducts[indexPath.row].uid
        
        networkManager.updateIsUsedToTrue(uid: uid, confirmedUserProductUid: uidForUserProduct) { didSuccess in
            switch didSuccess {
            case true:
                print("networkManager's changing isUsed to true succeed")
                completion(true)
            case false:
                print("networkManager's changing isUsed to true failed")
                completion(false)
            }
        }
    }
    
    func applyConfirmationUserProduct(indexPath: IndexPath) {
        //delete from isUsedFalseUserProducts
        let confirmedUserProduct = isUsedFalseUserProducts.remove(at: indexPath.row)
        //add to isUsedTrueUserProducts
        isUsedTrueUserProducts.insert(confirmedUserProduct, at: 0)
    }
    
    //swipe from right to left: 사용전으로 되돌리기 in HistoryUserProductVC
    func undoConfirmUserProduct(uid: String, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        //해당 userProduct 사용 완료 ~ uid구하기
        let uidForUserProduct = isUsedTrueUserProducts[indexPath.row].uid
        
        networkManager.updateIsUsedToFalse(uid: uid, confirmedUserProductUid: uidForUserProduct) { didSuccess in
            switch didSuccess {
            case true:
                print("networkManager's changing isUsed to false succeed")
                completion(true)
            case false:
                print("networkManager's changing isUsed to false failed")
                completion(false)
            }
        }
    }
    
    func applyUndoConfirmationUserProduct(indexPath: IndexPath) {
        //delete from isUsedTrueUserProducts
        let undoConfirmedUserProduct = isUsedTrueUserProducts.remove(at: indexPath.row)
        //add to isUsedFalseUserProducts
        isUsedFalseUserProducts.insert(undoConfirmedUserProduct, at: 0)
    }
    
    //for AccountVC
    func getConfirmedUserProducts() -> [UserProduct] {
        isUsedTrueUserProducts.sort { $0.createdAt < $1.createdAt }
        return isUsedTrueUserProducts
    }
    
    //sorting in ListVC
    func sortByExpiration() {
        isUsedFalseUserProducts.sort { $0.expiresAt < $1.expiresAt }
    }
    
    func sortByAlphabet() {
        isUsedFalseUserProducts.sort { $0.product.productName < $1.product.productName }
    }
    
}
