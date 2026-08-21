//
//  NavigationModel.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import Foundation

enum Rota: Hashable {
    case telaInicial
    case detalheReceita(ReceitaModel)
    case criarReceita
//    case listaIngredientes
    case onboarding
}
