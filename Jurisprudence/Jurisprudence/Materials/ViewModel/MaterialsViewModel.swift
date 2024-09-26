//
//  MaterialsViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import Foundation

class MaterialsViewModel {
    static let shared = MaterialsViewModel()
    @Published var materials: [MaterialModel] = []
    private init() {}
    
    func fetchMaterials() {
        CoreDataManager.shared.fetchMaterials { [weak self] materials, error in
            guard let self = self else { return }
            self.materials = materials
        }
    }
    
    func save(id: UUID, title: String, info: String) {
        CoreDataManager.shared.saveMaterial(id: id, title: title, info: info) { [weak self] error in
            guard let self = self else { return }
            self.fetchMaterials()            
        }
    }
}
