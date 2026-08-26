//
//  TeladeApresentação.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct TelaDeApresetacao: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                Text("Bem-Vindo(a) ao OVÔ")
                    .font(FontesApp.titulo)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                Text("O seu app para\n anotar as receitas\n do dia a dia!")
                    .multilineTextAlignment(.center)
                    .font(FontesApp.tituloComTexto)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                Image("Ovo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:geo.size.height * 0.35)
                
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


#Preview{
    TelaDeApresetacao(viewModel: OnboardingViewModel())
}
