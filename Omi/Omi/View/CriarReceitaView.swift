//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
//import SwiftUI
//
//struct CriarReceitaView: View {
//    @Environment(\.dismiss) private var voltar
//    
//    @Bindable var viewModel: CriarReceitaViewModel // Pq é um ObservableObject, então não precisa de init no viewModel aqui
//    
//    var body: some View {
//        ZStack{
//            
//        NavigationView{
//            
//               
//                
//                Form{
//                    Section("Título da receita") {
//                        TextField("Ex: Bolo de chocolate", text: $viewModel.titulo)
//                    }
//                    Section("Porções (pessoas)") {
//                        TextField("Ex: 5", text: $viewModel.porcoesTexto)
//                    }
//                    Section("Tempo de preparo (minutos)") {
//                        TextField("Ex: 30", text: $viewModel.tempoDePreparoTexto)
//                    }
//                    Section("Descrição") {
//                        TextEditor(text: $viewModel.descricao)
//                            .frame(minHeight: 200)
//                    }
//                    //categorias
//                    
//                    
//                    Section("Ingredientes") {
//                        TextField("Ingrediente", text: $viewModel.nomeIngredienteTexto)
//                        TextField("Quantidade", text: $viewModel.quantidadeTexto)
//                        TextField("Medida", text: $viewModel.medidaTexto)
//                        
//                        Button("Adicionar Ingrediente") {
//                            viewModel.adicionarIngrediente()
//                        }
//                        
//                        ForEach(viewModel.ingredientesAdicionados) { item in
//                            Text("\(item.quantidade) \(item.medida) - \(item.nome)")
//                        }
//                    }
//                    
//                    Section("Teste"){
//                        TextEditor(text: $viewModel.descricaoDoPasso)
//                            .font(FontesApp.corpo)
//                            .frame(minHeight: 200)
//                    }
//                    
//                    Section("Passos") {
//                        TextField("Nome do passo", text: $viewModel.nomeDoPasso)
//                        
//                   
//                           
//                        
//                        Button("Adicionar Passo") {
//                            viewModel.adicionarPasso()
//                        }
//                        
//                        ForEach(viewModel.passosAdicionados) { passo in
//                            Text("\(passo.etapa). \(passo.nome)")
//                        }
//                    }
//                }
//                .navigationTitle("Anotar receita")
//                .toolbar{
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button("Salvar") {
//                            viewModel.salvarReceitaNoBanco()
//                            voltar()
//                        }
//                    }
//                    
//                }
//            }
//        .backgroundStyle(.cordoFundo)
//        }
//    }
//}
//
//
//#Preview {
//    CriarReceitaView(viewModel: .preview)
//}
import SwiftUI

struct CriarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @Bindable var viewModel: CriarReceitaViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Screen background color
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Photo Picker Section
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Adicionar foto")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                Text("Selecione uma imagem")
                                    .font(FontesApp.corpo)
                            }
                            .foregroundStyle(.cordosTextos.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.corFundoCapsula))
                            .clipShape(Capsule())
                        }
                        
                        // Recipe Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Título da Receita")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: Bolo de chocolate", text: $viewModel.titulo)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // Portions
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Porções")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: 5 pessoas", text: $viewModel.porcoesTexto)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // Prep Time
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tempo de preparo")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: 30 min", text: $viewModel.tempoDePreparoTexto)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredientes:")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            VStack(spacing: 8) {
                                TextField("Ingrediente (ex: Chocolate)", text: $viewModel.nomeIngredienteTexto)
                                TextField("Quantidade (ex: 1)", text: $viewModel.quantidadeTexto)
                                TextField("Medida (ex: xícara)", text: $viewModel.medidaTexto)
                                
                                Button(action: {
                                    viewModel.adicionarIngrediente()
                                }) {
                                    Label("Adicionar Ingrediente", systemImage: "plus")
                                        .font(FontesApp.Semibold)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 4)
                            }
                            .padding(16)
                            .background(Color(.corFundoCapsula))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Added Ingredients List
                            ForEach(viewModel.ingredientesAdicionados) { item in
                                Text("• \(item.quantidade) \(item.medida) - \(item.nome)")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Preparation Steps Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Modo de Preparo:")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            VStack(spacing: 8) {
                                TextField("Nome da etapa", text: $viewModel.nomeDoPasso)
                                TextEditor(text: $viewModel.descricaoDoPasso)
                                    .frame(minHeight: 80)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Button(action: {
                                    viewModel.adicionarPasso()
                                }) {
                                    Label("Adicionar Etapa", systemImage: "plus")
                                        .font(FontesApp.Semibold)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(16)
                            .background(Color(.corFundoCapsula))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Added Steps List
                            ForEach(viewModel.passosAdicionados) { passo in
                                Text("Etapa \(passo.etapa): \(passo.nome)")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Anotar receita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Top Left: Close Button (X)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { voltar() }) {
                        Image(systemName: "xmark")
                        
                    }
                }
                
                // Top Right: Save Button (Checkmark)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.salvarReceitaNoBanco()
                        voltar()
                    }) {
                        Image(systemName: "checkmark")
                        
                        
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                }
            }
        }
    }
}

#Preview {
    CriarReceitaView(viewModel: .preview)
}
