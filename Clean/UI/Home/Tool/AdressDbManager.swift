//
//  AdressDbManager.swift
//  Clean
//
//  Created by liqi on 2020/11/9.
//

import Foundation
import SQLite

class AddressDbManager {
    
    static let shared = AddressDbManager()
    
    private let db: Connection
    private let addressTable: Table
    private let id: Expression<Int64>
    private let address: Expression<String>
    private let identifier: Expression<String>
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        db = try! Connection("\(path)/adress.sqlite3")
        
        addressTable = Table("addresses")
        
        id = Expression<Int64>("id")
        address = Expression<String>("address")
        identifier = Expression<String>("identifier")
        try! db.run(addressTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .autoincrement)
            t.column(identifier)
            t.column(address)
        })
    }
    
    func add(address: String, identifier: String) {
        try! db.run(addressTable.insert(self.address <- address, self.identifier <- identifier))
    }
    
    func select(identifier: String) -> String? {
        let result = addressTable.where(self.identifier == identifier)
        for address in try! db.prepare(result) {
            return address[self.address]
        }
        return nil
    }
    
}
