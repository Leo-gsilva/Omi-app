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
    //@Environment(AppRouter.self) private var router
    
    @Environment(\.dismiss) private var voltar
    @State var viewModel: CriarReceitaViewModel
 
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    FormularioReceitaView(viewModel: viewModel)   // ✅ mesmo componente
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
                        viewModel.salvarReceitaNoBanco()
               
                        voltar()
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
