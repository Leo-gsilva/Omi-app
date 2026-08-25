//
//  RotasDestinoView.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import SwiftUI
import SwiftData

// Único lugar do App que transforma Rota em View

struct RotasDestinoView: View {
    let rota: Rota

    @Environment(\.modelContext) private var contexto
    
    var body: some View {
        switch rota {
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel())
            
        case .telaInicial:
            TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: contexto)))
        
        case .detalheReceita(let receita):
            DetalhesReceitaView(viewModel: DetalhesReceitaViewModel(receita: receita, repo: ReceitaRepositorioSwiftData(context: contexto)))
            
        case .criarReceita:
            CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioSwiftData(context: contexto)))
            
//        case .categoriaSheetView:
//            CategoriaSheetView(categoriaSelecionada: .refeicao, aoSelecionar: { _ in } )
            
//        case .listaIngredientes:
//            ListaIngredientesView(viewModel: IngredientesViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
        }
    }
}
