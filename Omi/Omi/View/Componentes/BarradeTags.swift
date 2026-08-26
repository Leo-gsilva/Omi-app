//
//  BarradeTags.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 21/08/26.
//

import SwiftUI

struct BarraDeTags: View {
    @Bindable var viewModel: LivroReceitasViewModel

    private let ordemCategorias: [CategoriaReceita] = [
        .cafeDaManha, .refeicao, .saudavel, .sobremesa, .lanche
    ]

    private let tagPorCategoria: [CategoriaReceita: String] = [
        .cafeDaManha: "TagVermelha",
        .refeicao:      "TagAzul",
        .saudavel:      "TagVerde",
        .sobremesa:   "TagAmarela",
        .lanche:     "TagLaranja"
    ]

    var body: some View {
        GeometryReader { geo in
            
            HStack(spacing: 3) {
                
                ForEach(ordemCategorias) { categoria in
                    
                    Image(tagPorCategoria[categoria] ?? "TagVermelha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.10)
                        .offset(
                            y: viewModel.categoriaAtual == categoria
                            ? -14
                            : 0
                        )
                        .contentShape(
                            Rectangle()
                        )
                        .onTapGesture {
                            viewModel.selecionarCategoria(categoria)
                        }
                        .animation(
                            .spring(
                                response: 0.35,
                                dampingFraction: 0.7
                            ),
                            value: viewModel.categoriaAtual
                        )
                }
            }
            .padding(.horizontal, 150)
           
        }
    }
}

#Preview {
    BarraDeTags(viewModel: .preview)
}
