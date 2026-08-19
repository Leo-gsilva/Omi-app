//
//  TelaInicial.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TelaInicial: View {
    
        @State private var paginaAtual = 0
        @State private var totalPaginas = 0
    
    var body: some View {
        
        
        GeometryReader{ geo in
            VStack{
                ZStack{
                    Image("fundo")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .opacity(0.80)
                    VStack{
                        Text("Receitas")
                            .font(FontesApp.titulo)
                            .padding(.trailing,geo.size.width * 0.45)
                        Image("ReceitaTelaInicial")
                        TrocarPagina(
                            paginaAtual: paginaAtual,
                            totalPaginas: totalPaginas,
                            voltar: {
                                if paginaAtual > 1 {
                                    paginaAtual -= 1
                                }
                            },
                            avancar: {
                                if paginaAtual < totalPaginas {
                                    paginaAtual += 1
                                }
                            }
                        )
                        TabBar(action: {})
                            .padding(.horizontal, geo.size.width * 0.05)
                    }
                }
            }
        }
        
    }
}

#Preview {
    TelaInicial()
}
