//
//  RotasDestinoView.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import SwiftUI

// Único lugar do App que transforma Rota em View

struct RotasDestinoView: View {
    let rota: Rota
    
    @Environment(\.managedObjectContext) private var contexto
    
    var body: some View {
        switch rota {
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel())
            
        case .telaInicial:
            TelaInicial(viewModel: TelaInicialViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
        
        case .detalheReceita(let receita):
            DetalhesReceitaView(viewModel: DetalhesReceitaViewModel(receita: receita, repo: ReceitaRepositorioCoreData(context: contexto)))
            
        case .criarReceita:
            CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
            
//        case .listaIngredientes:
//            ListaIngredientesView(viewModel: IngredientesViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
        }
    }
}
