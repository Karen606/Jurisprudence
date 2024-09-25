//
//  DocumentsViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation

class DocumentsViewModel {
    static let shared = DocumentsViewModel()
    private var documents: [DocumentModel] = []
    @Published var filteredDocuments: [DocumentModel] = []
    private var search: String?
    var name: String?
    var data: Data?
    
    private init() {}
    
    func fetchDocuments() {
        CoreDataManager.shared.fetchDocuments { [weak self] documents, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            self.documents = documents
            if let search = search, !search.isEmpty {
                filteredDocuments = documents.filter { $0.name.localizedCaseInsensitiveContains(search) }
            } else {
                filteredDocuments = documents
            }
        }
    }
    
    func saveDocument() {
        guard let name = name else { return }
        let id = UUID()
        CoreDataManager.shared.addDocument(name: name, content: data, id: id) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error)
            }
            self.fetchDocuments()
        }
        clear()
    }
    
    func searchDocuments(search: String?) {
        self.search = search
        if let search = search, !search.isEmpty {
            filteredDocuments = documents.filter { $0.name.localizedCaseInsensitiveContains(search) }
        } else {
            filteredDocuments = documents
        }
    }
    
    func clear() {
        name = nil
        data = nil
    }
}
