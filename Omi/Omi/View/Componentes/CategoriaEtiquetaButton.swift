//
//  CategoriaEtiquetaButton.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct CategoriaEtiquetaButton: View {
    let categoria: CategoriaReceita
    let selecionada: Bool
    var aoSelecionar: () -> Void

    var body: some View {
        Button(action: aoSelecionar) {
            HStack {
                Text(categoria.nomeExibicao)
                    .font(FontesApp.subtitulo)
                    .foregroundStyle(.white)

                Spacer()

                if selecionada {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .padding(.trailing, 24)
                }
            }
            .padding(.leading, 20)
            .padding(.vertical, 18)
            .background(selecionada ? categoria.cor : categoria.cor.opacity(0.40))
            .clipShape(EtiquetaSeta())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoriaEtiquetaButton(categoria: .cafeDaManha, selecionada: true, aoSelecionar: {})
        .padding()
}
