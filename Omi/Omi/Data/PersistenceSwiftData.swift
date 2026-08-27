//
//  PersistenceSwiftData.swift
//  Omi
//
//  Created by Igor Carrasco on 25/08/26.
//

import SwiftData

enum PersistenceSwiftData {
    static let container: ModelContainer = {
        let schema = Schema([Receita.self, Ingrediente.self, IngredienteDaReceita.self, PassoReceita.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Erro ao criar ModelContainer: \(error)")
        }
    }()
    
    // Equivalente ao PersistenceController.preview
    static let preview: ModelContainer = {
        let schema = Schema([Receita.self, Ingrediente.self, IngredienteDaReceita.self, PassoReceita.self])
        
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        let contexto = container.mainContext
        for i in 1...5 {
            let receita = Receita(titulo: "Receita \(i)", categoria: "sobremesa", descricao: "Descrição \(i)", imagem: nil, tempoDePreparo: 20, porcoes: "4", dificuldade: nil)
            contexto.insert(receita)
        }
        try? contexto.save()
        return container
    } ()
}
