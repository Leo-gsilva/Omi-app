//
//  ReceitasRepo.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import CoreData

final class ReceitasRepo {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Create
    func criarIngrediente(nome: String) throws {
        let ingrediente = Ingrediente(context: context)
        ingrediente.id = UUID()
        ingrediente.nome = nome
        try context.save()
    }
    
    // Read (Fetch)
    func buscarIngredientes() throws -> [Ingrediente] {
        let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Ingrediente.nome, ascending: true)]
        return try context.fetch(request)
    }
    
    // Delete
    func deletar(ingrediente: Ingrediente) throws {
        context.delete(ingrediente)
        try context.save()
    }
}
