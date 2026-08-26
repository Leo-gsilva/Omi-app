//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI
import PhotosUI

struct CriarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @State var viewModel: CriarReceitaViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    if let erro = viewModel.erroReceita {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                    FormularioReceitaView(viewModel: viewModel)
                }
            }
            .navigationTitle(viewModel.tituloDaTela)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { voltar() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if viewModel.salvarReceitaNoBanco() {
                            voltar()
                        }
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                }
            }
        }
    }
}

#Preview {
    CriarReceitaView(viewModel: CriarReceitaViewModel.preview)
}
