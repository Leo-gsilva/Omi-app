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
    // Recebe protocolo e não a classe
    
    var livroAberto: Bool = false
    
    var paginaAtual = 0
    
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
    
    // Receita correspondete a página atual
    // Usar para alimentar o tabView
    var receitaAtual: ReceitaModel? {
        guard paginaAtual >= 1, paginaAtual <= receitasFiltradas.count else { return nil }
        return receitasFiltradas[paginaAtual - 1]
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
            queue: .main ){ [weak self] _ in
                self?.carregarReceitas()
            }
    }
    
    // Funcs do antigo TelaInicialViewModel
    func abrirLivro() {
        guard !livroAberto else { return }

        livroAberto = true
    }

    // Agora avan;a dentro da categoria atual
    func avancar() {
        if totalPaginas == 0 {
            let categoriaAntes = categoriaAtual
            proximaCategoria()
            if categoriaAtual != categoriaAntes {
                paginaAtual = totalPaginas > 0 ? 1 : 0
            }
            
            return
        }
        if paginaAtual < totalPaginas {
            paginaAtual += 1
        } else {
            let categoriaAntes = categoriaAtual
            proximaCategoria()
            if categoriaAtual != categoriaAntes {
                paginaAtual = 1
            }
        }
    }
    
    func voltar() {
        if totalPaginas == 0 {
            let categoriaAntes = categoriaAtual
            categoriaAnterior()
            if categoriaAtual != categoriaAntes {
                paginaAtual = totalPaginas > 0 ? totalPaginas : 0
            }
            
            return
        }
        if paginaAtual > 1 {
            paginaAtual -= 1
        } else {
            let categoriaAntes = categoriaAtual
            categoriaAnterior()
            if categoriaAtual != categoriaAntes {
                paginaAtual = max(totalPaginas, 1)
            }
        }
    }
    
//    func tratarPaginaSentinela(_ pagina: Int) {
//        guard totalPaginas > 0 else { return }
//        if pagina == 0 {
//            let categoriaAntes = categoriaAtual
//            categoriaAnterior()
//            paginaAtual = categoriaAtual != categoriaAntes ? max(totalPaginas, 1) : 1
//        } else if pagina == totalPaginas + 1 {
//            let categoriaAntes = categoriaAtual
//            proximaCategoria()
//            paginaAtual = categoriaAtual != categoriaAntes ? (totalPaginas > 0 ? 1 : 0) : totalPaginas
//        }
//    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
