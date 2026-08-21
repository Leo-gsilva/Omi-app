//
//  Onboarding1.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI

struct Onboarding1: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[0]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
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
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cordosTextos)
                
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

#Preview("Tela 1") {
    Onboarding1(
        viewModel: OnboardingViewModel()
    )
}
