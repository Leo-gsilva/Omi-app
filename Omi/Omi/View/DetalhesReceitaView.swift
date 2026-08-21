//    //
//    //  DetalhesReceitaView.swift
//    //  Omi
//    //
//    //  Created by Igor Carrasco on 19/08/26.
//    //
//
import SwiftUI
//import CoreData

struct DetalhesReceitaView: View {
    let receita: ReceitaModel

    
    var body: some View {
        ZStack {
            Color(.cordoFundo)
                .ignoresSafeArea()

           
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        

                        ReceitaHeroView(
                            imagemData: receita.imagem,
                            titulo: receita.titulo
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Descrição:")
                            CartaoClaro {
                                Text(receita.descricao)
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Ingredientes:")
                            CartaoClaro {
                                ForEach(receita.ingredientes) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                        Text("\(item.quantidade) \(item.medida) de \(item.nome)")
                                    }
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Modo de Preparo:")
                            VStack(spacing: 16) {
                                ForEach(receita.passos) { passo in
                                    ReceitaEtapaCardView(
                                        numero: passo.etapa,
                                        nome: passo.nome,
                                        texto: passo.texto,
                                        imagemData: passo.texto
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
        }
    }
}

#Preview {
    DetalhesReceitaView(
        receita: ReceitaModel(
            id: UUID(),
            titulo: "Bolo de Cenoura",
            categoria: .sobremesa,
            descricao: "O bolo de cenoura é uma receita clássica e amada por todos! Com sua massa fofinha e saborosa, esse bolo é perfeito para um lanche da tarde ou como sobremesa em qualquer ocasião.",
            imagem: "Bolo",
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
        )
    )
}
