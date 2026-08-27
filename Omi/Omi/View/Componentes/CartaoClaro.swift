//
//  CartaoClaro.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct CartaoClaro<Content: View>: View {
    @ViewBuilder var conteudo: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            conteudo
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.cordoFundoTexto))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    }
}
#Preview {
    CartaoClaro {
        VStack(alignment: .leading, spacing: 10) {
            Text("Etapa 2: OLA")
                .font(FontesApp.subtitulo)
                .foregroundStyle(.cordosTextos)
            
            Divider()
            
            Text("oi")
                .font(FontesApp.corpo)
                .foregroundStyle(.cordosTextos)
        }
    }
}
