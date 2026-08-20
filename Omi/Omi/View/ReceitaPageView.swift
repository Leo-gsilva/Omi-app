//
//  ReceitaPageView.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI

struct ReceitaPageView: View {
    //ReceitaModel, não Receita (entidade) - Não chama CoreData
    let receita: ReceitaModel
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 12) {
                Text(receita.titulo)
                    .font(.title)
                    .bold()
                
                Text(receita.categoria.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(receita.descricao)
                            
                if !receita.passos.isEmpty {
                    Text("Modo de preparo")
                        .font(.headline)
                    
                    ForEach(receita.passos) { passo in
                        Text("\(passo.etapa). \(passo.nome)")
                            .fontWeight(.semibold)
                        Text(passo.texto)
                    }
                }
//                Text("Tempo: \(receita.tempoDePreparo) min")
//                Text("Porções: \(receita.porcoes ?? "")")
//                Text("Categoria: \(receita.categoria ?? "")")
            }
            .padding()
        }
    }
}

#Preview {
    ReceitaPageView(
        receita: ReceitaModel(
            id: UUID(),
            titulo: "Bolo de Cenoura",
            categoria: .sobremesa,
            descricao: "Receita de teste para Preview.",
            imagem: "",
            tempoDePreparo: 45,
            porcoes: "8",
            dificuldade: "Fácil",
            dataCriacao: Date(),
            dataAtualizacao: nil,
            ingredientes: [
                IngredienteModel(id: UUID(), nome: "Cenoura", quantidade: "3", medida: "unidades"),
                IngredienteModel(id: UUID(), nome: "Farinha", quantidade: "2", medida: "xícaras")
            ],
            passos: [
                PassoModel(id: UUID(), etapa: 1, nome: "Misture", texto: "Bata tudo no liquidificador.", tempoEstimado: 5),
                PassoModel(id: UUID(), etapa: 2, nome: "Asse", texto: "Leve ao forno por 40 min.", tempoEstimado: 40)
            ]
        )
    )
}
