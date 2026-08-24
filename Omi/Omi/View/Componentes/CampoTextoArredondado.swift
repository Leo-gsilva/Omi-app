//
//  CampoTextoArredondado.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct CampoTextoArredondado: View {
    let rotulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo)
                .font(FontesApp.Semibold)
                .foregroundStyle(.cordosTextos)

            TextField(placeholder, text: $texto)
                .font(FontesApp.corpo)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
        }
    }
}
#Preview {
    CampoTextoArredondado(rotulo: "Título da Receita", placeholder: "Ex: Bolo de chocolate", texto: .constant(""))
        .padding()
}
    
