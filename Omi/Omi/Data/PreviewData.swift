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



// .preview para o ContentViewCoreDataTestes
extension ReceitaRepositorioCoreData {
    static var preview: NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }
}

extension CriarReceitaViewModel {
    static var preview: CriarReceitaViewModel {
        CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext), modo: .criar)
    }
}

extension DetalhesReceitaViewModel {
    static var preview: DetalhesReceitaViewModel {
        DetalhesReceitaViewModel(
            receita: ReceitaModel(
                id: UUID(),
                titulo: "Bolo de Cenoura",
                categoria: .sobremesa,
                descricao: "O bolo de cenoura é uma receita clássica e amada por todos! Com sua massa fofinha e saborosa, esse bolo é perfeito para um lanche da tarde ou como sobremesa em qualquer ocasião.",
                imagem: nil,
                tempoDePreparo: 40,
                porcoes: "8",
                dificuldade: nil,
                dataCriacao: Date(),
                dataAtualizacao: nil,
                ingredientes: [
                    IngredienteModel(id: UUID(), nome: "cenouras médias", quantidade: "3", medida: "unidades"),
                    IngredienteModel(id: UUID(), nome: "ovos", quantidade: "4", medida: "unidades")
                ],
                passos: [
                    PassoModel(id: UUID(), etapa: 1, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40),
                    PassoModel(id: UUID(), etapa: 2, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40)
                    
                ]
            ),
            repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext)
        )
    }
}
