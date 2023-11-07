//
//  Protocols.swift
//  RemExp
//
//  Created by Heedon on 2023/06/14.
//

import Foundation

protocol UpdateItemDelegate: AnyObject {
    func didUpdateItem(_ userProduct: UserProduct)
}

protocol GetProductFromBarcodeDelegate: AnyObject {
    func updateUI(_ product: Product)
}
