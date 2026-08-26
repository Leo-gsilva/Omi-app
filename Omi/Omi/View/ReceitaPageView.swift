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
    
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        GeometryReader{ geo in
            ScrollView{
                VStack (spacing: 16){
                    Section{
                        VStack (spacing: 4){
                            if let imagemData = receita.imagem,
                               let uiImage = UIImage(data: imagemData) {
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 426, height: 118)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 226, height: 118)
                        
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        DividerPersonalizado()
                            .padding(.horizontal, 30)
                        
                        Text(receita.titulo)
                            .font(FontesApp.tituloComTexto)
                            .frame(maxWidth: 200, maxHeight: 40)
                            .lineLimit(1)
                        
                        HStack{
                            Image("Tempo")
                            Text("\(receita.tempoDePreparo) min")
                            Image("Fatia")
                            Text("\(receita.porcoes) pessoas")
                        }
                        .font(FontesApp.Semibold)
                        
                    }
                    
                    Text(receita.descricao)
                        .frame(maxWidth: 200, maxHeight: 100)
                        .lineLimit(1)
                    
                    BotaoOnboarding(textoBotao: "Abrir Receita Completa") {
                        router.push(.detalheReceita(receita))
                    }
                    .frame(width: geo.size.width * 0.60)
                    
                }
            }
            .onTapGesture {
                router.push(.detalheReceita(receita))
            }
        }
    }
}

#Preview {
    NavigationStack{
        ReceitaPageView(
            receita: ReceitaModel(
                id: UUID(),
                titulo: "Bolo de Cenoura ADADADADA",
                categoria: .sobremesa,
                descricao: "Receita de teste para Preview.",
                imagem: nil,
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
    .environment(AppRouter())
}
