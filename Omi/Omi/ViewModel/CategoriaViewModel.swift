//
//  CategoriaViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation

@Observable
final class CategoriaViewModel {
    var categoriaAtual: CategoriaReceita = .cafeDaManha

    func proximaCategoria() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual) else { return }

        let proximoIndice = min(indiceAtual + 1, CategoriaReceita.allCases.count - 1)

        categoriaAtual = CategoriaReceita.allCases[proximoIndice]
    }

    func categoriaAnterior() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual) else { return }

        let indiceAnterior = max(indiceAtual - 1, 0)

        categoriaAtual = CategoriaReceita.allCases[indiceAnterior]
    }
}
