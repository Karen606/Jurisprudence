//
//  WorkModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation

struct WorkModel {
    var id: UUID
    var name: String
    var type: String
    var deadline: Date?
    var cost: String
    var status: Status = .inProcess
}

enum Status {
    case inProcess
    case completed
    case delay
    
    var id: String {
        switch self {
        case .inProcess:
            return "in process"
        case .completed:
            return "completed"
        case .delay:
            return "delay"
        }
    }
    
    static func status(value: String) -> Self {
        switch value {
        case "in process":
            return .inProcess
        case "completed":
            return .completed
        case "delay":
            return .delay
        default:
            return .inProcess
        }
    }
}
