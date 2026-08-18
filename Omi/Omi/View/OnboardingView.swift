//
//  OnboardingView.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        
        switch viewModel.paginaAtual {
            
        case 0:
            Onboarding1(viewModel: viewModel)
            
        case 1:
            Onboarding2(viewModel: viewModel)
            
        case 2:
            Onboarding3(viewModel: viewModel)
            
//        case 3:
//            Onboarding4(viewModel: viewModel)
//
        case 4:
            Onboarding5(viewModel: viewModel)
            
        default:
            EmptyView()
        }
    }
}

#Preview {
    OnboardingView()
}
