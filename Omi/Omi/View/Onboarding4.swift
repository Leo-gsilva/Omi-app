//
//  Onboarding4.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct Onboarding4: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[3]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width:geo.size.height * 0.35)
                
                
                Spacer()
                
                VStack{
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    
                    +
                    Text("Ingredientes ")
                        .font(FontesApp.ExtraBold)
                    +
                    Text("e\n")
                        .font(FontesApp.tituloComTexto)
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.tituloComTexto)
                    
                    
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black.opacity(0.7))
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Tela 4") {
    Onboarding4(
        viewModel: OnboardingViewModel()
    )
}
