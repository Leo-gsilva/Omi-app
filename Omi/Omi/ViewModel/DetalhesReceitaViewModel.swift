//
//  DetalhesReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 19/08/26.
//
import SwiftUI
import Observation

// pelo que li, é mais tranquilo implementar o coredata usando o ObservedObject
@Observable
class DetalhesReceitaViewModel {
    var receita: ReceitaModel?
    
    private let repo: ReceitaRepositorio
    
    init(receita: ReceitaModel, repo: ReceitaRepositorio) {
        self.receita = receita
        self.repo = repo
        carregarDetalhes()
    }
    
    func carregarDetalhes() {
        guard let id = receita?.id else { return }
        do {
            receita = try repo.buscarReceita(id: id)
        } catch {
            print("Erro ao carregar detalhes: \(error)")
        }
    }
}
