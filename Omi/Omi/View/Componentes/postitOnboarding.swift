//
//  postitOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI
struct PostitOnboarding: View {
    
    let imagem: String
    let ativo: Bool
    
    var body: some View {
        Image(imagem)
            .resizable()
            .scaledToFit()
            .offset(y: ativo ? -20 : 0)
            .animation(
                .easeInOut(duration: 0.35),
                value: ativo
            )
    }
}
