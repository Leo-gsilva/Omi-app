//
//  OnboardingView.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppRouter.self) private var router
    @Bindable var viewModel = OnboardingViewModel()
    
    var body: some View {
        Group{
            switch viewModel.paginaAtual {
            case 0:
                TelaDeApresetacao(viewModel: viewModel)
            case 1:
                Onboarding1(viewModel: viewModel)
            case 2:
                Onboarding2(viewModel: viewModel)
            case 3:
                Onboarding3(viewModel: viewModel)
            case 4:
                Onboarding4(viewModel: viewModel)
            case 5:
                Onboarding5(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .onChange(of: viewModel.finalizado) { _, finalizado in
            if finalizado {
                router.finalizarOnboarding()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
