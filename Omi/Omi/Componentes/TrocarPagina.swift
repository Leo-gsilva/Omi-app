//
//  TrocarPagina.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TrocarPagina: View {
    
    let paginaAtual: Int
    let totalPaginas: Int
    
    let voltar: () -> Void
    let avancar: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                
                Button(action: voltar) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geo.size.width * 0.35,height: 50)
                .background(Color.cordaTabBar)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("\(paginaAtual)/\(totalPaginas)")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: geo.size.width * 0.20,height: 50)
                
                Button(action: avancar) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geo.size.width * 0.35,height: 50)
                .background(Color.cordaTabBar)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TrocarPagina(
        paginaAtual: 0,
        totalPaginas: 3,
        voltar: {
            print("Voltar")
        },
        avancar: {
            print("Avançar")
        }
    )
}
