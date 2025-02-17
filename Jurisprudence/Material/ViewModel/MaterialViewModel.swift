//
//  MaterialViewModel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import Foundation

class MaterialViewModel {
    static let shared = MaterialViewModel()
    @Published var material: MaterialModel?
    private init() {}
    
    func save(completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.saveMaterial(id: material?.id ?? UUID(), title: material?.title ?? "", info: material?.info ?? "") { error in
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
