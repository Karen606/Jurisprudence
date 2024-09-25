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
    
    @Published var workModel: WorkModel = WorkModel(id: UUID(), name: "", type: "", deadline: nil, cost: "")
    
    private init() {}
    
    func fetchWorks() {
        CoreDataManager.shared.fetchWorks { [weak self] works, error in
            guard let self = self else { return }
            self.works = works ?? []
        }
    }
    
    func addWork() {
        guard let date = workModel.deadline else { return }
        CoreDataManager.shared.addWork(clientName: workModel.name, cost: workModel.cost, deadline: date, status: workModel.status.id, type: workModel.type, id: workModel.id) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            self.fetchWorks()
        }
        self.clear()
    }
    
    func changeStatus(id: UUID, status: String) {
        CoreDataManager.shared.editWorkStatus(id: id, newStatus: status) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func clear() {
        workModel = WorkModel(id: UUID(), name: "", type: "", deadline: nil, cost: "")
    }
}
