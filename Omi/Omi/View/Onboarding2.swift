//
//  Onboarding2.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI
struct Onboarding2: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[1]
    }
    
    private let postits = [
        "Etiqueta laranja",
        "Etiqueta amarela",
        "Etiqueta verde",
        "Etiqueta azul",
        "Etiqueta vermelha"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack() {
                
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
                    .padding(.top, geometry.size.height * 0.035)
                
                Spacer()
                
                ZStack() {
                    
                    
                    HStack(spacing: 2) {
                        ForEach(postits.indices, id: \.self) { index in
                            
                            PostitOnboarding(imagem: postits[index],ativo: viewModel.postitAtivo == index)
                            .frame(width: geometry.size.width * 0.099)
                        }
                    }
                    .padding(.leading, geometry.size.height * 0.06)
                    .offset(y: -geometry.size.height * 0.23)
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.70)
                }
                
                
                
                VStack{
                    Text(pagina.descricao)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    Text("com ")
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.ExtraBold)
                    }
                
                    .font(FontesApp.tituloComTexto)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: min(geometry.size.width * 0.78,305))
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
            .background(Color.cordoFundo)
        }
        .task {
            await viewModel.iniciarAnimacaoPostIts()
        }
    }
}

#Preview("Tela 2") {
    Onboarding2(
        viewModel: OnboardingViewModel()
    )
}
