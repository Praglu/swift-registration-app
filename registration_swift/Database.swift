import Foundation
import SQLite3


class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    
    private init() {
        if let fileUrl = try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("registration-swift.db") {
            if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
                print("ERROR | DATABASE | init - Error opening database while init DatabaseManager!")
            }
            print("DATABASE | init - Database opened in init DatabaseManager")
            if createUsersTable() {
                print("DATABASE | init - Table users created successfully in init DatabaseManager")
            } else {
                print("ERROR | DATABASE | init - Error while creating table users in init DatabaseManager!")
            }
        }
    }
    
    func createUsersTable() -> Bool {
        let createUserTableQuery = """
            CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
        );
        """
        if sqlite3_exec(db, createUserTableQuery, nil, nil, nil) != SQLITE_OK {
            print("ERROR | DATABASE | createUsersTable - Users table not created")
            return false
        } else {
            print("DATABASE | createUsersTable - Table users created successfully")
            return true
        }
    }
    
    func deleteUsersTable() -> Bool {
        let deleteUsersTable = """
            DROP TABLE IF EXISTS users;
        """
        if sqlite3_exec(db, deleteUsersTable, nil, nil, nil) != SQLITE_OK {
            print("ERROR | DATABASE | deleteUsersTable - Users table not deleted successfully")
            return false
        } else {
            print("DATABASE | deleteUsersTable - Table users deleted successfully")
            return true
        }
    }
    
    func deleteUsersData() -> Bool {
        let deleteUsersData = """
            DELETE FROM users;
        """
        if sqlite3_exec(db, deleteUsersData, nil, nil, nil) != SQLITE_OK {
            print("ERROR | DATABASE | deleteUsersData - users data has not beed deleted correctlly")
            return false
        } else {
            print("DATABASE | deleteUsersData - Users data has been deleted correctlly")
            return true
        }
    }
    
    func executeQuery(query: String) -> [[String: String]]? {
        var result: [[String: String]] = []
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String: String] = [:]
                for i in 0..<sqlite3_column_count(statement) {
                    let name = String(cString: sqlite3_column_name(statement, i))
                    let value = String(cString: sqlite3_column_text(statement, i))
                    row[name] = value
                }
                result.append(row)
            }
        } else {
            print("ERROR | DATABASE | executeQuery - Error executing query: \(query)")
            return nil
        }
        sqlite3_finalize(statement)
        return result
    }
    
    func insertUserIntoUsers(email: String, password: String) -> Bool {
        let insertUser = """
            INSERT INTO users (email, password) VALUES ('\(email.lowercased())', '\(password)');
            """
        if sqlite3_exec(db, insertUser, nil, nil, nil) != SQLITE_OK {
            print("ERROR | DATABASE | TABLE - user not inserted correctlly!")
            return false
        } else {
            print("DATABASE | User with email: '\(email)' has been created successfully")
            return true
        }
    }
}
