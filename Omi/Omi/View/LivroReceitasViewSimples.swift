////
////  LivroReceitasViewSimples.swift
////  Omi
////
////  Created by Igor Carrasco on 19/08/26.
////
//
import SwiftUI
import Observation

struct LivroReceitasViewSimples: View {
    // repo j[a vem injetado por fora
    // @Bindable permite usar o $viewModel.categoriaAtual com Picker/conteole
    @Bindable var viewModel: LivroReceitasViewModel
    
//    let receitas: FetchedResults<Receita>
    
//    @State private var categoriaSelecionada = "Sobremesa"
//
//    private let categorias = ["sobremesa", "salgado", "bebida", "massa", "lanche"]
    
//    private var receitasFiltradas: [Receita] {
//        receitas.filter{
//            $0.categoria == viewModel.categoriaAtual.rawValue
//        }
//    }

    
    var body: some View {
        Picker("Categoria", selection: $viewModel.categoriaAtual) {
            ForEach(CategoriaReceita.allCases) { categoria in
                Text(categoria.rawValue).tag(categoria)
            }
        }
        .pickerStyle(.segmented)
        
        if viewModel.receitasFiltradas.isEmpty {
            ContentUnavailableView("Nenhuma receita nessa categoria", systemImage: "book")
        } else {
            TabView {
                ForEach(viewModel.receitasFiltradas) { receita in
                    ReceitaPageView(
                        receita: receita
                    )
                }
            }
            .tabViewStyle(.page)
        }
    }
}

#Preview {
    LivroReceitasViewSimples(viewModel: .preview)
}
