//
//  TelaInicial.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TelaInicial: View {
    
    @Bindable var viewModel: TelaInicialViewModel
    @State private var pesquisa = ""
    @State private var mostrarLivroAberto = false
    
    private let animacaoLivro = Animation.spring(
        response: 0.65,
        dampingFraction: 0.78
    )
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Image("fundo")
                    .resizable()
                    .ignoresSafeArea()
                
                
                VStack {
                    
                    Text("Receitas")
                        .font(FontesApp.titulo)
                        .padding(.trailing, geo.size.width * 0.45)
                        .padding(geo.size.width * 0.04)
                    
                    
                    ZStack(alignment: .leading) {
                        
                        Image("albumAbertoVermelho")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 1.00)
                            .opacity(viewModel.livroAberto ? 1 : 0)
                            .ignoresSafeArea(edges: .all)
                            
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
                            .zIndex(1)
                            .padding(.horizontal, 30)
                    }
                    
                    .clipped()
                    .contentShape(Rectangle())
                                        
                    .onTapGesture {
                        
                        abrirLivro()
                    }
                    
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: viewModel.paginaAtual
                    )
                    
                    TrocarPagina(
                        paginaAtual: viewModel.paginaAtual,
                        totalPaginas: viewModel.totalPaginas,
                        
                        voltar: {
                            
                            withAnimation(
                                .easeInOut(duration: 0.4)
                            ) {
                                viewModel.voltar()
                            }
                        },
                        
                        avancar: {
                            
                            if !viewModel.livroAberto {
                                
                                abrirLivro()
                                
                                return
                            }
                            
                            withAnimation(
                                .easeInOut(duration: 0.4)
                            ) {
                                viewModel.avancar()
                            }
                        }
                    )
                    .frame(height: geo.size.width * 0.18)
                }
            }
        }
        
        .searchable(
            text: $pesquisa,
            prompt: "Pesquisar receitas"
        )
        
        .toolbar {
            
            ToolbarItemGroup(
                placement: .bottomBar
            ) {
                
                HStack {
                    
                    Image(
                        systemName: "magnifyingglass"
                    )
                    
                    TextField(
                        "Pesquisar",
                        text: $pesquisa
                    )
                    .textFieldStyle(.plain)
                }
                .padding(.horizontal, 27)
                .frame(height: 45)
                
                Spacer()
                
                Button {
                    print("Adicionar receita")
                } label: {
                    
                    Image(
                        systemName: "plus"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold
                        )
                    )
                }
            }
        }
    }
    
    private func abrirLivro() {
        
        guard !viewModel.livroAberto else {
            return
        }
    
        withAnimation(animacaoLivro) {
            viewModel.abrirLivro()
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.50
        ) {
            withAnimation(.easeInOut(duration: 0.15)) {
                mostrarLivroAberto = true
            }
        }
        
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.65
        ) {
            viewModel.avancar()
        }
    }
}


#Preview {
    TelaInicial(viewModel: TelaInicialViewModel.preview)
}
