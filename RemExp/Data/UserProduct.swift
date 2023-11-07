//
//  UserProduct.swift
//  RemExp
//
//  Created by Heedon on 2023/05/22.
//

import UIKit

//Product + alpha
//구분: uuid (명칭은 uid)

struct UserProduct: Codable, Equatable {
    var uid: String         //UUID (존재여부 확인: eidt, create 구분)
    var isUsed: Bool        //기간 내 사용여부 판단
    var createdAt: Date     //등록된 시간
    var expiresAt: Date       //유저가 직접 설정
    var product: Product
    
    static func == (lhs: UserProduct, rhs: UserProduct) -> Bool {
        //제품 구분용
        return lhs.uid == rhs.uid
    }
    
}
