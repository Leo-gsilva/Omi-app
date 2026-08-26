//
//  LivroInterativo.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 24/08/26.
//

import SwiftUI


struct LivroInterativo: View {
    @Bindable var viewModel: LivroReceitasViewModel
    @State private var pesquisa = ""
    
    private let animacaoLivro = Animation.spring(
        response: 0.65,
        dampingFraction: 0.78
    )
    private let coresPorCategoria: [CategoriaReceita: String] = [
        .cafeDaManha: "albumAbertoVermelho",
        .refeicao:      "albumAbertoAzul",
        .saudavel:      "albumAbertoVerde",
        .sobremesa:   "albumAbertoAmarelo",
        .lanche:     "albumAbertoLaranja"
    ]

    private var nomePaginaAtual: String {
        coresPorCategoria[viewModel.categoriaAtual] ?? "albumAbertoVermelho"
    }
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                if viewModel.livroAberto {
                            BarraDeTags(viewModel: viewModel)
                      
                    }

                Image(nomePaginaAtual)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 1.00)
                    .opacity(viewModel.livroAberto ? 1 : 0)
                    .ignoresSafeArea(edges: .all)
                    .id(nomePaginaAtual)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: nomePaginaAtual)
                    .allowsHitTesting(false)
                
                if viewModel.livroAberto {
                    LivroReceitasViewSimples(viewModel: viewModel)
                        .frame(
                            width: geo.size.width * 0.75,
                            height: geo.size.height * 0.55
                        )
                        .padding(.leading, geo.size.width * 0.23)
                        .transition(.opacity)
                        .zIndex(2)
                }
                
                Image("ReceitaTelaInicial")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.90)
                    .rotation3DEffect(
                        .degrees(viewModel.livroAberto ? -90 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        perspective: 0.35
                    )
                    .shadow(color: .black.opacity(0.25), radius: 14, x: 8, y: 10)
                    .padding(.horizontal, 30)
                    
            }

            .onTapGesture {
                
                abrirLivro()
            }
            .animation(
                .easeInOut(duration: 0.4),
                value: viewModel.paginaAtual
            )
        }
    }
    private func abrirLivro() {
        
        guard !viewModel.livroAberto else { return }
    
        withAnimation(animacaoLivro) {
            viewModel.abrirLivro()
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.50
        ) {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.livroAberto = true
            }
        }
    }
}

#Preview {
    LivroInterativo(viewModel: LivroReceitasViewModel.preview)
}


    
