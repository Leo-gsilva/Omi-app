////
////  LivroReceitasViewSimples.swift
////  Omi
////
////  Created by Igor Carrasco on 19/08/26.
////

import SwiftUI

struct LivroReceitasViewSimples: View {
    // repo j[a vem injetado por fora
    // @Bindable permite usar o $viewModel.categoriaAtual com Picker/conteole
    @Bindable var viewModel: LivroReceitasViewModel

    var body: some View {
//        Picker("Categoria", selection: $viewModel.categoriaAtual) {
//            ForEach(CategoriaReceita.allCases) { categoria in
//                Text(categoria.rawValue).tag(categoria)
//            }
//        }
//        .pickerStyle(.segmented)
//        .onChange(of: viewModel.categoriaAtual) { _, _ in
//            viewModel.paginaAtual = 1
//        }
        
        if viewModel.receitasFiltradas.isEmpty {
            ContentUnavailableView("Nenhuma receita nessa categoria", systemImage: "book")
        } else {
            TabView(selection: $viewModel.paginaAtual) {
                ForEach(Array(viewModel.receitasFiltradas.enumerated()), id: \.element.id) { index, receita in
                    ReceitaPageView(
                        receita: receita
                    )
                    .tag(index + 1) // +1 pq a página atual é 1-index
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    LivroReceitasViewSimples(viewModel: .preview)
}
