//
//  DetalhesReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 19/08/26.
//
import SwiftUI
import Observation

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
            if let receitaAtualizada = try repo.buscarReceita(id: id) {
                self.receita = receitaAtualizada
                print("🔄 [SUCESSO] Receita atualizada na tela de detalhes: \(receitaAtualizada.titulo)")
            }
        } catch {
            print("Erro ao carregar detalhes: \(error)")
        }
    }
    func excluirReceita(_ receita: ReceitaModel) {
        do {
            try repo.deletarReceita(id: receita.id)
        } catch {
            print("Erro ao excluir receita: \(error)")
        }
    }
}
