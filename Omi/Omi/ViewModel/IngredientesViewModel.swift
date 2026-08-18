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
    // Look how clean this is! No @Published needed.
    var itens: [Ingrediente] = []
    
    // We make the repo private so the View can't touch it directly.
    private let repo: ReceitasRepo
    
    init(repo: ReceitasRepo) {
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
            try repo.buscarOuCriarIngrediente(nome: nome)
            carregarIngredientes()
        } catch {
            print("Erro ao adicionar: \(error)")
        }
    }
    
    func deletar(offsets: IndexSet) {
        offsets.map { itens[$0] }.forEach { ingrediente in
            do {
                try repo.deletar(ingrediente: ingrediente)
            } catch {
                print("Erro ao deletar: \(error)")
            }
        }
        carregarIngredientes()
    }
}
