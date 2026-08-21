//
//  Telainicial.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI
import Observation

@Observable
class TelaInicialViewModel {
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
    }
    
    var receitas: [ReceitaModel] = []
    var paginaAtual: Int = 0
    var totalPaginas = 1
    
    var livroAberto: Bool = false
    
    func getTotalPaginas() -> Int {
        return receitas.count
    }
    
    func abrirLivro() {
        guard !livroAberto else {
            return
        }

        livroAberto = true
    }

    func avancar() {
        guard paginaAtual < totalPaginas else {
            return
        }

        paginaAtual += 1
    }
    
    func voltar() {
        guard paginaAtual > 1 else {
            return
        }
        
        paginaAtual -= 1
    }
}
