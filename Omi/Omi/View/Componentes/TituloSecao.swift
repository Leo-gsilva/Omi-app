//
//  TituloSecao.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct TituloSecao: View {
    let texto: String

    var body: some View {
        Text(texto)
            .font(FontesApp.subtitulo)
            .foregroundStyle(.cordosTextos)
    }
}
#Preview {
    TituloSecao(texto: "Título da seção")
}
