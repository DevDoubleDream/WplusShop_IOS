//
//  DBInterface.swift
//  WPlusShop
//
//  Created by 더블드림 on 2017. 2. 2..
//  Copyright © 2017년 더블드림. All rights reserved.
//

import Foundation

enum SQLError:Error {
    case ConnectionError
    case QueryError
    case OtherError
}

class DBInterface:NSObject {
    var obj_db:OpaquePointer? = nil
    var stmt:OpaquePointer? = nil
    
    lazy var db_path:String = {
        return self.doc_dir.appendingPathComponent("WPlusShop.sqlite").path
    }()
    
    lazy var doc_dir:URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    lazy var db: OpaquePointer? = {
        if sqlite3_open(self.db_path, &(self.obj_db)) == SQLITE_OK {
            return self.obj_db!
        }
        return nil
    }()
    
    
    override init(){
        super.init()
    
        do{
            try prepare_database()
        } catch {
            print("데이터베이스 실행 실패")
            abort()
        }
    }
    
    func prepare_database() throws {
        guard db != nil else {throw SQLError.ConnectionError}
        defer {sqlite3_finalize(stmt)}
        
        
        let query = "CREATE TABLE IF NOT EXISTS SAMPLE " +
            "(IDX INTEGER PRIMARY KEY, " +
            "ID VARCHAR(10), " +
            "PW VARCHAR(10), " +
            "USER_NO VARCHAR(10), " +
            "AUTO_LOGIN VARCHAR(1) DEFAULT 'N', " +
            "POINT VARCHAR(10), " +
            "CARD_NO VARCHAR(20));"
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("테이블 생성 완료")
                return
            }
        }
        
        throw SQLError.ConnectionError
    }
    
    deinit {
        if obj_db != nil {
            sqlite3_close_v2(obj_db)
        }
    }
    
    
    func insertData(ID id:NSString, PW pw:NSString, USER_NO userNo:NSString, AUTO auto:NSString, CARD card:NSString, POINT point:NSString) throws {
        guard db != nil else {throw SQLError.ConnectionError}
        defer {sqlite3_finalize(stmt)}
        
        let query = "INSERT INTO SAMPLE (ID, PW, USER_NO, AUTO_LOGIN, CARD_NO, POINT) VALUES (?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, id.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, pw.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, userNo.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, auto.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, card.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, point.utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("데이터 저장 완료")
                return
            }
        }
        
        throw SQLError.QueryError
    }
    
    func selectData() throws -> Dictionary<String,String>? {
        var returnValue:String = ""
        
        var returnDictionary:Dictionary<String,String> = Dictionary<String,String>()
        
        guard db != nil else {throw SQLError.ConnectionError}
        defer {sqlite3_finalize(stmt)}
        
        let query = "SELECT * FROM SAMPLE;"
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString:sqlite3_column_text(stmt, 1))
                let pw = String(cString:sqlite3_column_text(stmt, 2))
                let userNo = String(cString:sqlite3_column_text(stmt,3))
                let auto_login = String(cString:sqlite3_column_text(stmt,4))
                let card_no = String(cString:sqlite3_column_text(stmt,5))
                let point = String(cString:sqlite3_column_text(stmt,6))
                
                returnDictionary.updateValue(id, forKey: "id")
                returnDictionary.updateValue(pw, forKey: "pw")
                returnDictionary.updateValue(userNo, forKey: "userNo")
                returnDictionary.updateValue(auto_login, forKey: "auto_login")
                returnDictionary.updateValue(card_no, forKey: "card_no")
                returnDictionary.updateValue(point, forKey: "point")
            }
            return returnDictionary
        }
        return nil
    }
    
    func updateTable(ID id:NSString, PW pw:NSString, USER_NO userNo:NSString, AUTO auto:NSString, CARD card:NSString, POINT point:NSString) throws {
        guard db != nil else {throw SQLError.ConnectionError}
        defer {sqlite3_finalize(stmt)}
        
        let query = "UPDATE SAMPLE SET ID=?, PW=?, USER_NO=?, AUTO_LOGIN=?, CARD_NO=?, POINT=? WHERE IDX = 1;"
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, id.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, pw.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, userNo.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, auto.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, point.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, card.utf8String, -1, nil)
            

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("데이터 변경 완료")
                return
            }
        }
        
        throw SQLError.QueryError
    }
}




