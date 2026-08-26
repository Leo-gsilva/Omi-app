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
    case editarReceita(ReceitaModel)
    //case categoriaSheetView
}

extension Rota: Identifiable {
    // Como Rota já é hashable, ela serve como seu próprio id
    var id: Self { self }
}
