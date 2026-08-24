//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI
import PhotosUI

struct CriarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @Bindable var viewModel: CriarReceitaViewModel
    @State private var itemSelecionado: PhotosPickerItem?   // ✅ estado local do picker

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: Foto (agora funcional, ligada a viewModel.imagem: Data?)
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

                        // MARK: Categoria (estava faltando na sua versão — necessário pra salvar corretamente)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Categoria")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)

                            Picker("Categoria", selection: $viewModel.categoria) {
                                ForEach(CategoriaReceita.allCases) { cat in
                                    Text(cat.nomeExibicao).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
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

                            ForEach(viewModel.ingredientesAdicionados) { item in
                                Text("• \(item.quantidade.formatted()) \(item.medida) - \(item.nome)")
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
            .navigationTitle(viewModel.tituloDaTela)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { voltar() }) {
                        Image(systemName: "xmark")
                    }
                }

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

#Preview("Criar") {
    CriarReceitaView(viewModel: .preview)
}
