//
//  IngredientesViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import SwiftUI
import Observation

@Observable
class IngredientesViewModel {
    var itens: [IngredienteCadastradoModel] = []
    
    // We make the repo private so the View can't touch it directly.
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarIngredientes()
    }
    
    func carregarIngredientes() {
        do {
            itens = try repo.buscarIngredientes()
        } catch {
            print("Erro ao buscar: \(error)")
        }
    }
    
    func adicionar(nome: String) {
        guard !nome.isEmpty else { return }
        do {
            _ = try repo.criarIngredienteAvulso(nome: nome)
            carregarIngredientes()
        } catch {
            print("Erro ao adicionar: \(error)")
        }
    }
    
    func deletar(offsets: IndexSet) {
        offsets.map { itens[$0] }.forEach { ingrediente in
            do {
                try repo.deletarIngrediente(id: ingrediente.id)
            } catch {
                print("Erro ao deletar: \(error)")
            }
        }
        carregarIngredientes()
    }
}
