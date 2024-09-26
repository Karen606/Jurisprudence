//
//  DeadlineViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import Foundation

class DeadlineViewModel {
    static let shared = DeadlineViewModel()
    @Published var deadlines: [DeadlineModel] = []
    @Published var selectedDeadline: DeadlineModel?
    @Published var selectedDate: Date?
    
    func fetchDeadlines() {
        CoreDataManager.shared.fetchDeadlines { [weak self] deadlines, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            self.deadlines = deadlines
            selectedDeadline = deadlines.first(where: { $0.date == self.selectedDate })
        }
    }
    
    func save(info: String) {
        if let selectedDeadline = selectedDeadline {
            CoreDataManager.shared.editDeadline(date: selectedDeadline.date, info: info) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                self.fetchDeadlines()
            }
        } else {
            CoreDataManager.shared.addDeadline(date: selectedDate ?? Date(), info: info) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                self.fetchDeadlines()
            }
        }
    }
    
    func chooseDate(date: Date) {
        selectedDeadline = deadlines.first(where: { $0.date == date })
        self.selectedDate = date
    }
    
    func clear() {
        selectedDeadline = nil
        selectedDate = nil
    }
    
    private init() {}
}
