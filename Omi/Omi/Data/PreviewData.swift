//
//  PreviewData.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import CoreData

enum PreviewData {
    static func receitas(context: NSManagedObjectContext) {
        for i in 1...5 {
            let receita = Receita(context: context)
            
            receita.id = UUID()
            receita.titulo = "Receita \(i)"
        }
        
        try? context.save()
    }
}

// Como aqui é sobre Preview e també importa o CoreData, posso chamar extensions do que preciso criar para passar chamar no preview
extension LivroReceitasViewModel {
    static var preview: LivroReceitasViewModel {
        LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}

extension TelaInicialViewModel {
    static var preview: TelaInicialViewModel {
        TelaInicialViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}

// .preview para o ContentViewCoreDataTestes
extension ReceitaRepositorioCoreData {
    static var preview: NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }
}

extension CriarReceitaViewModel {
    static var preview: CriarReceitaViewModel {
        CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}
