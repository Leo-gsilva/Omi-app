//
//  Persistence.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Generating some mock ingredients so the Xcode Preview looks good!
        let mockIngredients = ["Farinha de Trigo", "Ovos", "Açúcar", "Manteiga", "Leite"]
        
        for nome in mockIngredients {
            let novoIngrediente = Ingrediente(context: viewContext)
            novoIngrediente.id = UUID()
            novoIngrediente.nome = nome
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // This must exactly match the name of your .xcdatamodeld file!
        container = NSPersistentContainer(name: "Omi")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
