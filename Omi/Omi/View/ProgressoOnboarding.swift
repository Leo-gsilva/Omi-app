//
//  progressoOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI

struct ProgressoOnboarding: View {
    
    let paginaAtual: Int
    let totalDePaginas: Int
    
    var body: some View {
        HStack(spacing: 7) {
            
            ForEach(0..<totalDePaginas, id: \.self) { index in
                
                Capsule()
                    .fill(
                        index == paginaAtual
                        ? (Color.cordoBotao)
                        : Color.gray.opacity(0.5)
                    )
                    .frame(width: 30, height: 5)
            }
        }
        .padding(.top, 38)
    }
}

#Preview {
    ProgressoOnboarding(paginaAtual: 0, totalDePaginas: 5)
}
