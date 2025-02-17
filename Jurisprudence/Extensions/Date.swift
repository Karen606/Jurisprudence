//
//  Date.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation

extension Date {
    func dateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
