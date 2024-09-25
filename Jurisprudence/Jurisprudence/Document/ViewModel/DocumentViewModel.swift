//
//  DocumentViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import Foundation

class DocumentViewModel {
    static let shared = DocumentViewModel()
    @Published var document: DocumentModel?
    private init() {}
    
    func save(completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.editDocument(id: document?.id ?? UUID(), content: document?.content) { error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false)
                }
                print(error)
            } else {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
}
