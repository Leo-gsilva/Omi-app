//
//  BotaoOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//
import SwiftUI

struct BotaoOnboarding: View {
    
    var textoBotao: String = "Confirmar"
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(textoBotao)
                .font(FontesApp.Botao)
                .foregroundStyle(Color.cordoFundo)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.cordoBotao)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
        }
    }
}
#Preview {
    BotaoOnboarding(
        
        action: {}
    )
    
}
