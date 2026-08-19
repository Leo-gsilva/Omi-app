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

        let controller = PersistenceController(
            inMemory: true
        )

        let context = controller.container.viewContext

        let receita = Receita(context: context)

        receita.id = UUID()
        receita.titulo = "Bolo de Cenoura"
        receita.descricao = "Preview"

        try? context.save()

        return controller
    }() // Para aplicar nas #Previews das views filhas do App.swift

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Omi")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("ERRO AO CARREGAR CORE DATA \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        print(container.managedObjectModel.entitiesByName.keys)
    }
}

