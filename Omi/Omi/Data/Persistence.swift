//
//  Persistence.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import CoreData

// O NSPersistentContainer monta o NSManagedObjectModel, o NSPersistentStoreCoordinator e entrega um NSManagedObjectContext
// assim o container guarda contexto (rascunho)
struct PersistenceController {
    static let shared = PersistenceController()
    
    // Declara-se o container e precisa ter o mesmo nome do arquivo.xdatamodeld
    let container: NSPersistentContainer
    
    // Inicializa o container e lida com possível erro
    init(emMemoria: Bool = false) {
        container = NSPersistentContainer(name: "Omi")
        
        if emMemoria {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "dev/null")
        }
        
        container.loadPersistentStores { descricao, erro in
            if let erro = erro {
                fatalError("ERRO AO CARREGAR CORE DATA: \(erro.localizedDescription)")
            }
        }
        
        // Configura o container para mesclar automaticamente as mudanças vindas de outros contextos
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Para aplicar nas #Previews das views filhas do App.swift
    @MainActor
    static let preview: PersistenceController = {
        
        let controller = PersistenceController()
        
        let context = controller.container.viewContext
        
        let categorias = ["sobremesa", "salgado", "bebida", "massa", "lanche"]
        
        for i in 1...5 {
            let receita = Receita(context: context)
            
            receita.id = UUID()
            receita.titulo = "Receita \(i)"
            receita.descricao = "Descrição da receita: \(i)"
            receita.categoria = categorias.randomElement()
            receita.tempoDePreparo = Int16(20 + i)
            receita.porcoes = "8"
            receita.dataCriacao = Date()
        }
        
        try? context.save()
        
        return controller
    }()
}

