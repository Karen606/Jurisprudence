//
//  CoreDataManager.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Jurisprudence") // Replace with your model name
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        // MARK: - Add Work on Background Thread
        func addWork(clientName: String, cost: String, deadline: Date, status: String, type: String, completion: @escaping (Error?) -> Void) {
            let backgroundContext = persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                let work = Work(context: backgroundContext) // Replace with your entity class name
                work.id = UUID()
                work.clientName = clientName
                work.cost = cost
                work.deadline = deadline
                work.status = status
                work.type = type
                
                do {
                    try backgroundContext.save()
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
        
        // MARK: - Edit Work Status on Background Thread
        func editWorkStatus(id: UUID, newStatus: String, completion: @escaping (Error?) -> Void) {
            let backgroundContext = persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                let fetchRequest: NSFetchRequest<Work> = Work.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                do {
                    let results = try backgroundContext.fetch(fetchRequest)
                    if let work = results.first {
                        work.status = newStatus
                        try backgroundContext.save()
                        completion(nil)
                    } else {
                        completion(NSError(domain: "CoreData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Work not found"]))
                    }
                } catch {
                    completion(error)
                }
            }
        }
        
        // MARK: - Fetch Works on Background Thread
        func fetchWorks(completion: @escaping ([WorkModel]?, Error?) -> Void) {
            let backgroundContext = persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                let fetchRequest: NSFetchRequest<Work> = Work.fetchRequest()
                
                do {
                    let results = try backgroundContext.fetch(fetchRequest)
                    var workModels: [WorkModel] = []
                    for work in results {
                        let workModel = WorkModel(name: work.clientName ?? "", type: work.type ?? "", deadline: work.deadline, cost: work.cost ?? "", status: Status.status(value: work.status ?? ""))
                        workModels.append(workModel)
                    }
                    completion(workModels, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
}
