//
//  NetworkingManager.swift
//  RemExp
//
//  Created by Heedon on 2023/05/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

enum QueryProductError: Error {
    case notGettingDocumentError
    case notGettingDataError
    case queryError
}

final class NetworkManager {
    //singleton for various screens
    static let shared = NetworkManager()
    
    private init() {}
    
    //completion 정의
    typealias UserProductsCompletion = (Result<[UserProduct], Error>) -> Void
    typealias ProductCompletion = (Result<Product, QueryProductError>) -> Void
    
    //MARK: - Fetch API
    
    //Fetch UserProduct
    func fetchUserProducts(with uid: String, completion: @escaping UserProductsCompletion) {
        print("DB에서 UserProduct 가져오기 시작")
        requestToDB(uid: uid) { result in
            completion(result)
        }
    }
    
    //request to DB, 비동기적 실행, 클로저로 끝난 시점 받도록 하기
    private func requestToDB(uid: String, completion: @escaping UserProductsCompletion) {
        
        DB_USERS.document("\(uid)").collection("userProducts").getDocuments { snapshot, error in
            if let error = error {
                print("Fetch from DB failed")
                completion(.failure(error))
            }
            
            print("Fetch from DB success")
        
            var tempUserProducts = [UserProduct]()
            
            if let docs = snapshot?.documents {
                for doc in docs {
                    let data = doc.data()
                    
                    let uidForUserProduct = data["uid"] as! String
                    let isUsed = data["isUsed"] as! Bool
                    
                    //timestamp to Date
                    let timeStampCreated = data["createdAt"] as! Timestamp
                    let createdAt = timeStampCreated.dateValue()
                    
                    let timeStampExpires = data["expiresAt"] as! Timestamp
                    let expiresAt = timeStampExpires.dateValue()
                    
                    let productData = data["product"] as! [String : Any]
                    
                    let product = Product(barcode: productData["barcode"] as! String, brandName: productData["brandName"] as! String, productName: productData["productName"] as! String, category: productData["category"] as! String, imageUrl: productData["imageUrl"] as! String)
                    
                    let newUserProduct = UserProduct(uid: uidForUserProduct, isUsed: isUsed, createdAt: createdAt, expiresAt: expiresAt, product: product)
                    tempUserProducts.append(newUserProduct)
                }
                completion(.success(tempUserProducts))
            }
        }

    }
    
    //Fetch UserProduct
    func fetchProduct(with barcode: String, completion: @escaping ProductCompletion) {
        print("DB에서 Product 가져오기 시작")
        queryProductFromDB(barcode: barcode) { result in
            completion(result)
        }
    }
    
    private func queryProductFromDB(barcode: String, completion: @escaping ProductCompletion) {
        DB_PRODUCTS.document("\(barcode)").getDocument { document, error in
            if let error = error {
                print("Query to DB failed: \(error.localizedDescription)")
                completion(.failure(.queryError))
            }
            
            if let document = document {
                if let data = document.data() {
                    let category = data["category"] as! String
                    let brand = data["brandName"] as! String
                    let product = data["productName"] as! String
                    let imageUrl = data["imageUrl"] as! String
                    
                    let productFromDB = Product(barcode: barcode, brandName: brand, productName: product, category: category, imageUrl: imageUrl)
                    completion(.success(productFromDB))
                } else {
                    print("Failed to get Product data from DB")
                    completion(.failure(.notGettingDataError))
                }
            } else {
                print("Failed to get document from query result")
                completion(.failure(.notGettingDocumentError))
            }
        }
    }
    
    
    //MARK: - Upload API
    
    //Upload User
    func queryDuplicateUserData(uid: String, email: String, nickName: String, completion: @escaping (_ result: Bool) -> Void) {
        //이미 계정 존재 시, upload 안해야 함: email로 조회
        let queryResult = DB_USERS.whereField("email", isEqualTo: email)
        
        queryResult.getDocuments { snapshot, error in
            
            //query 그 자체가 문제가 있는 경우로 추측
            if let error = error {
                print("error: ", error.localizedDescription)
                completion(false)
            }
            
            //query 결과로 document count가 0이더라도 null로 취급을 안하는 것으로 보임 (왜인지는 모르겠음)
            if let docs = snapshot?.documents{
                //count가 0인 경우, 겹치는 email이 없으므로 새로 등록
                if docs.count == 0 {
                    print("no doc in documents, upload user")
                    self.uploadUserData(uid: uid, email: email, nickName: nickName) { result in
                        switch result {
                        case true:
                            completion(true)
                        case false:
                            completion(false)
                        }
                    }
                } else {
                    //겹치는 email 존재
                    print("There is already an account in database")
                    completion(false)
                }
            } else {
                //혹시 몰라서 else를 넣었지만 호출될 일이 없어보임
                //nothing on docs: new user info
                print("nothing matches: upload new user!")
                self.uploadUserData(uid: uid, email: email, nickName: nickName) { result in
                    switch result {
                    case true:
                        completion(true)
                    case false:
                        completion(false)
                    }
                }
                return
            }
        }
    }
    
    private func uploadUserData(uid: String, email: String, nickName: String, completion: @escaping (_ result: Bool) -> Void) {
        
        let newUser = User(uid: uid, email: email, nickName: nickName)
            
        //section "users" with uid, email, nickname
        do {
            try DB_USERS.document("\(uid)").setData(from: newUser)
            print("Successfully registered new user data to db")
            completion(true)
        } catch let error {
            print("error registering to firestore: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    //Upload Item
    func uploadItemToDB(uid: String, uidForUserProduct: String, userProduct: UserProduct, completion: @escaping (_ didSuccessed: Bool) -> Void) {
        print("uploadItemToDB by networkManager")
        //"users"/uid/"userProducts"/uuid
        do {
            try DB_USERS.document("\(uid)").collection("userProducts").document("\(uidForUserProduct)").setData(from: userProduct)
            print("Document added to firestore")
            completion(true)
        } catch let error {
            print("error uploading to Firestore: \(error)")
            completion(false)
        }
    }
    
    
    //MARK: - Deletion
    
    func deleteUserProduct(uid: String, uidForUserProduct: String, completion: @escaping (Bool) -> Void) {
        DB_USERS.document("\(uid)").collection("userProducts").document("\(uidForUserProduct)").delete { error in
            if let error = error {
                print("Error with deleting user-product: \(error.localizedDescription)")
                completion(false)
            }
            print("Success with deleting user-product")
            completion(true)
        }
    }
    
    
    func deleteUserData(uid: String, completion: @escaping (Bool) -> Void) {
        DB_USERS.document("\(uid)").delete { error in
            if let error = error {
                print("Failed to delete user data from db: \(error.localizedDescription)")
                completion(false)
            }
            
            print("Successfully deleted User data from Auth and DB")
            completion(true)
        }
    }
    
    
    //MARK: - Updating API
    
    func updateIsUsedToTrue(uid: String, confirmedUserProductUid: String, completion: @escaping (Bool) -> Void) {
        //DB의 데이터 업데이트 하기
        do {
            try DB_USERS.document("\(uid)").collection("userProducts").document("\(confirmedUserProductUid)").updateData(["isUsed" : true])
            print("updaing isUsed true to db is done")
            completion(true)
        }
        catch let error {
            print("error happened with updating isUsed true to db: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func updateIsUsedToFalse(uid: String, confirmedUserProductUid: String, completion: @escaping (Bool) -> Void) {
        //DB의 데이터 업데이트 하기
        do {
            try DB_USERS.document("\(uid)").collection("userProducts").document("\(confirmedUserProductUid)").updateData(["isUsed" : false])
            print("updaing isUsed false to db is done")
            completion(true)
        }
        catch let error {
            print("error happened with updating isUsed false to db: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
}



