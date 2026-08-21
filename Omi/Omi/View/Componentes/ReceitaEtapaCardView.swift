//
//  ReceitaEtapaCardView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct ReceitaEtapaCardView: View {
    let numero: Int16
    let nome: String
    let texto: String
    let imagemData: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CartaoClaro {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Etapa \(numero): \(nome)")
                        .font(FontesApp.subtitulo)
                        .foregroundStyle(.cordosTextos)

                    Rectangle()
                        .fill(Color(.corDivider))
                        .frame(height: 2)

                    Text(texto)
                        .font(FontesApp.corpo)
                        .foregroundStyle(.cordosTextos)
                }
            }

            //if let imagemData, let uiImage = UIImage(data: imagemData) {
                GeometryReader { geo in
                  //  Image(uiImage: uiImage)
                    Image("Bolo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .aspectRatio(308.0 / 188.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
           // }
        }
    }
}
#Preview {
    ReceitaEtapaCardView(numero: 1, nome: "Leo", texto: "ola", imagemData: nil)
}
