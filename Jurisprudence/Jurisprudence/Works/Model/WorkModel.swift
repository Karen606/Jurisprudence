//
//  WorkModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation

struct WorkModel {
    var name: String
    var type: String
    var deadline: Date?
    var cost: String
    var status: Status = .inProcess
}
