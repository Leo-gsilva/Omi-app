//
//  Capsula.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
import SwiftUI

struct CapsulaDetalhes: View {
   let detalhe: TipoDetalhe
    
    var body: some View {
        HStack(spacing: 8) {
            
            Image(systemName: detalhe.iconePadrao)
                            .font(FontesApp.Semibold)
                            .foregroundStyle(.cordosTextos)
                        
                        Text(detalhe.textoFormatado)
                            .font(FontesApp.Semibold)
                            .foregroundStyle(.cordosTextos)
                
        }
        .padding(.vertical,8)
        .padding(.horizontal)
        .background(.corFundoCapsula)

        .clipShape(Capsule())
        .shadow(radius: 2)
    
    }
}
#Preview {
    CapsulaDetalhes(detalhe: .tempo(100))
}
