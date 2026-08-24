//
//  ReceitaHeroView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct ReceitaHeroView: View {
    let imagemData: Data?
    let titulo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { geo in
              Group {
                    if let imagemData, let uiImage = UIImage(data: imagemData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("Bolo")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
            }
            .aspectRatio(308.0 / 188.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Text(titulo)
                .font(FontesApp.titulo)
                .foregroundStyle(.cordosTextos)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.cordoFundoTexto))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
    }
}
#Preview {
    ReceitaHeroView(imagemData: nil, titulo: "olha")
}
