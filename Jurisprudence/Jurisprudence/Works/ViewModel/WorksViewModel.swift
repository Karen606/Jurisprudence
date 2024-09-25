//
//  WorksViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation

class WorksViewModel {
    static let shared = WorksViewModel()
    @Published var works: [WorkModel] = []
    
    @Published var workModel: WorkModel = WorkModel(name: "", type: "", deadline: nil, cost: "")
    
    private init() {}
    
    func fetchWorks() {
        CoreDataManager.shared.fetchWorks { [weak self] works, error in
            guard let self = self else { return }
            self.works = works ?? []
        }
    }
    
    func addWork() {
        guard let date = workModel.deadline else { return }
        CoreDataManager.shared.addWork(clientName: workModel.name, cost: workModel.cost, deadline: date, status: workModel.status.id, type: workModel.type) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            self.fetchWorks()
        }
    }
    
    func clear() {
        workModel = WorkModel(name: "", type: "", deadline: nil, cost: "")
    }
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
