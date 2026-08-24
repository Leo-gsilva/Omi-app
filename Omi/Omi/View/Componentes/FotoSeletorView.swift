//
//  FotoSeletorView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//

import SwiftUI
import PhotosUI

struct FotoSeletorView: View {
    @Binding var imagemSelecionada: UIImage?
    @State private var itemSelecionado: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Adicionar foto")
                .font(FontesApp.Semibold)
                .foregroundStyle(.cordosTextos)

            PhotosPicker(selection: $itemSelecionado, matching: .images) {
                HStack(spacing: 12) {
                    if let imagemSelecionada {
                        Image(uiImage: imagemSelecionada)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.cordosTextos.opacity(0.7))
                    }

                    Text(imagemSelecionada == nil ? "Selecione uma imagem" : "Imagem selecionada")
                        .font(FontesApp.corpo)
                        .foregroundStyle(.cordosTextos.opacity(0.7))

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
            }
            .onChange(of: itemSelecionado) { _, novoItem in
                Task {
                    guard let dados = try? await novoItem?.loadTransferable(type: Data.self) else { return }
                    imagemSelecionada = UIImage(data: dados)
                }
            }
        }
    }
}
#Preview {

}
