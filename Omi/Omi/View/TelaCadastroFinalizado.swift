//
//  TelaCadastroFinalizado.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 28/08/26.
//

import SwiftUI

struct TelaCadastroFinalizado: View {
    private let mensagem: String
    private let acaoConfirmar: () -> Void
    
    // Uso original: dentro do fluxo de onboarding
    init(viewModel: OnboardingViewModel) {
        self.mensagem = "Parabéns,\nvocê fez mais\numa receita!"
        self.acaoConfirmar = { viewModel.continuar() }
    }
    
    // Uso novo: depois de salvar uma receita, mostrando o nome dela
    init(nomeReceita: String, action: @escaping () -> Void) {
        self.mensagem = "Parabéns,\nvocê criou a receita\n\"\(nomeReceita)\"!"
        self.acaoConfirmar = action
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                Spacer()
                
                Image("OvoFeliz")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.height * 0.30)
                    .padding(30)
                
                Text(mensagem)
                    .multilineTextAlignment(.center)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Obrigado!") {
                    acaoConfirmar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Onboarding") {
    TelaCadastroFinalizado(viewModel: .init())
}

#Preview("Receita salva") {
    TelaCadastroFinalizado(nomeReceita: "Bolo de cenoura") {}
}
