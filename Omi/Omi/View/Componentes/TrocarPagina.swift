//
//  TrocarPagina.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TrocarPagina: View {
    @Bindable var viewModel: LivroReceitasViewModel
      
    let voltar: () -> Void
    let avancar: () -> Void
    
    var body: some View {
        
        GeometryReader { geo in
            
            HStack {
 
                Button(action: voltar) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
                .frame(
                    width: geo.size.width * 0.30,
                    height: 50
                )
                .contentShape(Rectangle())
                .glassEffect()
                
                Text("\(viewModel.livroAberto ? viewModel.paginaAtual : 0)/\(viewModel.totalPaginas)")
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .frame(
                        width: geo.size.width * 0.20,
                        height: 50
                    )
        
                Button(action: avancar) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
                .frame(
                    width: geo.size.width * 0.30,
                    height: 50
                )
                .contentShape(Rectangle())
                .glassEffect()
            }
            .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    TrocarPagina(
        viewModel: LivroReceitasViewModel.preview,
        voltar: {},
        avancar: {}
    )
}
