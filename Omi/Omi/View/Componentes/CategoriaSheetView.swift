////
////  CategoriaSheetView.swift
////  Omi
////
////  Created by Leonardo Gonçalves da Silva on 23/08/26.
////
//
//import SwiftUI
//
//struct CategoriaSheetView: View {
//    @Environment(\.dismiss) private var fechar
//
//    let categoriaSelecionada: CategoriaReceita?
//    var aoSelecionar: (CategoriaReceita) -> Void
//
//    var body: some View {
//        ZStack {
//            Color(.cordoFundo)
//                .ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 20) {
//                HStack {
//                    Button(action: { fechar() }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundStyle(.cordosTextos)
//                            .padding(10)
//                            .background(.ultraThinMaterial, in: Circle())
//                    }
//
//                    Spacer()
//
//                    Text("Adicionar categoria")
//                        .font(FontesApp.subtitulo)
//                        .foregroundStyle(.cordosTextos)
//
//                    Spacer()
//
//                    Button(action: { fechar() }) {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundStyle(.white)
//                            .padding(10)
//                            .background(Color(.cordosTextos), in: Circle())
//                    }
//                }
//
//                Text("Selecione uma etiqueta com o nome da categoria que você quer escolher para sua receita.")
//                    .font(FontesApp.corpo)
//                    .foregroundStyle(.cordosTextos.opacity(0.7))
//
//                VStack(spacing: 16) {
//                    ForEach(CategoriaReceita.allCases) { categoria in
//                        CategoriaEtiquetaButton(
//                            categoria: categoria,
//                            selecionada: categoria == categoriaSelecionada,
//                            aoSelecionar: {
//                                aoSelecionar(categoria)
//                                fechar()
//                            }
//                        )
//                    }
//                }
//
//                Spacer()
//            }
//            .padding(20)
//        }
//    }
//}
//
//#Preview {
//    CategoriaSheetView(categoriaSelecionada: .sobremesa, aoSelecionar: { _ in })
//}
