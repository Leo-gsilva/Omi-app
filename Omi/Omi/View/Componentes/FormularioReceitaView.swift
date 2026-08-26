//
//  FormularioReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 25/08/26.
//
import SwiftUI
import PhotosUI

struct FormularioReceitaView: View {
    @Bindable var viewModel: CriarReceitaViewModel
    @State private var itemSelecionado: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: Foto
            VStack(alignment: .leading, spacing: 6) {
                Text("Adicionar foto")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                PhotosPicker(selection: $itemSelecionado, matching: .images) {
                    HStack(spacing: 12) {
                        if let dados = viewModel.imagem, let uiImage = UIImage(data: dados) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "photo")
                                .font(.title2)
                        }
                        
                        Text(viewModel.imagem == nil ? "Selecione uma imagem" : "Imagem selecionada")
                            .font(FontesApp.corpo)
                        
                        Spacer()
                    }
                    .foregroundStyle(.cordosTextos.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.corFundoCapsula))
                    .clipShape(Capsule())
                }
                .onChange(of: itemSelecionado) { _, novoItem in
                    Task {
                        if let dados = try? await novoItem?.loadTransferable(type: Data.self) {
                            viewModel.imagem = dados
                        }
                    }
                }
            }
            
            // MARK: Título
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
            
            // MARK: Porções
            VStack(alignment: .leading, spacing: 6) {
                Text("Porções")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                TextField("Ex: 5", text: $viewModel.porcoesTexto)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.corFundoCapsula))
                    .clipShape(Capsule())
                    .keyboardType(.numberPad)
            }
            
            // MARK: Tempo de preparo
            VStack(alignment: .leading, spacing: 6) {
                Text("Tempo de preparo (minutos)")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                TextField("Ex: 30", text: $viewModel.tempoDePreparoTexto)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.corFundoCapsula))
                    .clipShape(Capsule())
                    .keyboardType(.numberPad)
            }
            
            // MARK: Categoria
            VStack(alignment: .leading, spacing: 6) {
                Text("Categoria")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                //                        Picker("Categoria", selection: $viewModel.categoria) {
                //                            ForEach(CategoriaReceita.allCases) { cat in
                //                                Text(cat.nomeExibicao).tag(cat)
                //                            }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.corFundoCapsula))
            .clipShape(Capsule())
            
            .padding(.horizontal, 20)
            
            // MARK: Descrição
            VStack(alignment: .leading) {
                Text("Descrição:")
                    .font(FontesApp.corpo)
                TextEditor(text: $viewModel.descricao)
                    .frame(minHeight: 200)
            }
            
            // MARK: Ingredientes
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredientes:")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                VStack(spacing: 8) {
                    TextField("Ingrediente (ex: Chocolate)", text: $viewModel.nomeIngredienteTexto)
                    Divider()
                    TextField("Quantidade (ex: 1)", text: $viewModel.quantidadeTexto)
                        .keyboardType(.numberPad)
                    Divider()
                    TextField("Medida (ex: xícara)", text: $viewModel.medidaTexto)
                    
                    Button(action: { viewModel.adicionarIngrediente() }) {
                        Label("Adicionar Ingrediente", systemImage: "plus")
                            .font(FontesApp.Semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 4)
                    
                    if let erro = viewModel.erroIngrediente {
                        Text(erro)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(Color(.corFundoCapsula))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.ingredientesAdicionados.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("• \(item.quantidade.formatted()) \(item.medida) - \(item.nome)")
                                .font(FontesApp.corpo)
                                .foregroundStyle(.cordosTextos)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.ingredientesAdicionados.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 8)
                        DividerPersonalizado()
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // MARK: Modo de preparo
            VStack(alignment: .leading, spacing: 8) {
                Text("Modo de Preparo:")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Nome da etapa", text: $viewModel.nomeDoPasso)
                    Divider()
                    Text("Descrição do Passo")
                        .font(FontesApp.corpo)
                    TextEditor(text: $viewModel.descricaoDoPasso)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button(action: { viewModel.adicionarPasso() }) {
                        Label("Adicionar Etapa", systemImage: "plus")
                            .font(FontesApp.Semibold)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let erro = viewModel.erroPasso {
                        Text(erro)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(Color(.corFundoCapsula))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.passosAdicionados.enumerated()), id: \.offset) { index, passo in
                        HStack {
                            Text("Etapa \(index + 1): \(passo.nome)")
                                .font(FontesApp.corpo)
                                .foregroundStyle(.cordosTextos)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.passosAdicionados.remove(at: index)
                                // Reorganiza o número das etapas automaticamente
                                for i in 0..<viewModel.passosAdicionados.count {
                                    viewModel.passosAdicionados[i].etapa = i + 1
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 8)
                        DividerPersonalizado()
                    }
                }
            }
            
        }
        .padding(20)
    }
}

#Preview {
    FormularioReceitaView(viewModel: CriarReceitaViewModel.preview)
}
