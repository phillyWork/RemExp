//
//  User.swift
//  RemExp
//
//  Created by Heedon on 2023/05/18.
//

import UIKit

//custom delegate pattern 만들기
//User 활용하는 protocol 만들기

//강한 순환참조 막기 위해 weak으로 선언: class만 사용하도록 정의 바뀌어야 함
//AnyObject: class에서만 사용가능한 protocol 선언 의미
protocol UserDelegate: AnyObject {
    //대리자가 할 수 있는 일 정의하기 (VC가 동작 받아서 대신해서 해야하는 일)
    
    //SettingVC에서 User nickName 수정 --> 대리자에게 알려줘서 대리자가 역할 하기
    func updateNickName(_ user: User)
}


//구분: uid
struct User: Codable {
    var uid: String
    var email: String
    var nickName: String
}
