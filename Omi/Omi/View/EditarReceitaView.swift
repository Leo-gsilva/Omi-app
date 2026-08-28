//
//  EditarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 25/08/26.
//
//

import SwiftUI
import PhotosUI

struct EditarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @State var viewModel: CriarReceitaViewModel
 
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
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
    EditarReceitaView( viewModel: .preview)
}
