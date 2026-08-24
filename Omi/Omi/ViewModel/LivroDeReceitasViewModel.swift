//
//  LivroDeReceitasViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation
import CoreData

@Observable
final class LivroReceitasViewModel {
    var paginaAtual: Int = 0                          // índice da RECEITA dentro da categoria
    var categoriaAtual: CategoriaReceita = .sobremesa // setada pelas tags
    private(set) var receitas: [ReceitaModel] = []
    var livroAberto: Bool = false

    private let repo: ReceitaRepositorio
    private var observer: NSObjectProtocol?

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

    func abrirLivro() {
        guard !livroAberto else { return }
        livroAberto = true
    }

    func selecionarCategoria(_ categoria: CategoriaReceita) {
        categoriaAtual = categoria
        paginaAtual = 0
    }

    func avancar() {
        guard paginaAtual < totalPaginas - 1 else { return }
        paginaAtual += 1
    }

    func voltar() {
        guard paginaAtual > 0 else { return }
        paginaAtual -= 1
    }

    private func observarMudancas() {
        observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.carregarReceitas()
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
