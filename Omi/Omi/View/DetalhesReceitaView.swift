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
    @Bindable var viewModel: DetalhesReceitaViewModel
    
    
    var body: some View {
        GeometryReader { geo in
            
            
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        ZStack(alignment: .bottomLeading){
                            ReceitaHeroView(
                                imagemData: viewModel.receita?.imagem,
                                titulo: viewModel.receita?.titulo ?? ""
                            )
                            HStack(){
                                CapsulaDetalhes(detalhe: .tempo(viewModel.receita?.tempoDePreparo ?? 1))
                                    .position(
                                        x: geo.size.width * 0.15,y: geo.size.width * 0.48)
                                CapsulaDetalhes(detalhe: .pessoas(viewModel.receita?.porcoes ?? "1"))
                                    .position(x: geo.size.width * -0.03,y: geo.size.width * 0.48)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Descrição:")
                            CartaoClaro {
                                Text(viewModel.receita?.descricao ?? "")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Ingredientes:")
                            CartaoClaro {
                                ForEach(viewModel.receita?.ingredientes ?? [IngredienteModel(id: UUID(), nome: "None", quantidade: "0", medida: "ml")]) { item in
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
                                ForEach(viewModel.receita?.passos ?? [PassoModel(id: UUID(), etapa: 0, nome: "None", texto: "None", tempoEstimado: 1)]) { passo in
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink(
                    item: "Confira a receita de \(viewModel.receita?.titulo ?? "") no Omi!\n\n\(viewModel.receita?.descricao ?? "")",
                    subject: Text(viewModel.receita?.titulo ?? ""),
                    message: Text("Enviado via Omi App")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    // Action for edit
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        DetalhesReceitaView(
            viewModel: DetalhesReceitaViewModel.preview
        )
    }
}
