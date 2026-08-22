//
//  LivroDeReceitasViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation
import CoreData // PQ esse viewModel importa o coreData? Ta certo?

@Observable
final class LivroReceitasViewModel {
    var categoriaAtual: CategoriaReceita = .sobremesa
    private(set) var receitas: [ReceitaModel] = []
    
    private let repo: ReceitaRepositorio
    private var observer: NSObjectProtocol?
    // Recebe protocolo e não a classe
    
    var livroAberto: Bool = false
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarReceitas()
        observarMudancas()
    }
    
    var receitasFiltradas: [ReceitaModel] {
        receitas.filter { $0.categoria == categoriaAtual }
    }

    var totalPaginas: Int {
        receitasFiltradas.count
    }
    
    var paginaAtual = 0
    
    func carregarReceitas() {
        do {
            receitas = try repo.buscarReceitas()
        } catch {
            print("Erro ao buscar receitas: \(error)")
            receitas = []
        }
    }
    
    func deletar(_ receita: ReceitaModel) {
        do {
            try repo.deletarReceita(id: receita.id)
            carregarReceitas()
        } catch {
            print("Erro ao deletar receita \(error)")
        }
    }
    
    func proximaCategoria() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual)
        else { return }

        let proximoIndice = min(indiceAtual + 1, CategoriaReceita.allCases.count - 1)

        categoriaAtual = CategoriaReceita.allCases[proximoIndice]
    }

    func categoriaAnterior() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual)
        else { return }

        let indiceAnterior = max(indiceAtual - 1, 0)

        categoriaAtual = CategoriaReceita.allCases[indiceAnterior]
    }
    
    // Substitui o que o @fetchRequest faz de graça: reage a saves no contexto e busca novamente
    private func observarMudancas() {
        observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main ){ [weak self] _ in
                self?.carregarReceitas()
            }
    }
    
    // Funcs do antigo TelaInicialViewModel
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
        guard paginaAtual > 0 else {
            return
        }
        
        paginaAtual -= 1
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
