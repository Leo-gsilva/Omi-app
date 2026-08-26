//
//  LivroDeReceitasViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation
import SwiftData
import SwiftUI

@Observable
final class LivroReceitasViewModel {
    var paginaAtual: Int = 0                          // índice da RECEITA dentro da categoria
    var categoriaAtual: CategoriaReceita = .cafeDaManha // setada pelas tags
    private(set) var receitas: [ReceitaModel] = []
    var livroAberto: Bool = false
    var pesquisa: String = ""

    private let repo: ReceitaRepositorio
    private var observer: NSObjectProtocol?
    // Recebe protocolo e não a classe
            
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarReceitas()
        observarMudancas()
    }

    var receitasFiltradas: [ReceitaModel] {
        guard !pesquisa.isEmpty else {
            return receitas.filter { $0.categoria == categoriaAtual }
        }
        
        return receitas.filter { $0.titulo.localizedCaseInsensitiveContains(pesquisa)}
    }
    
    func buscarPorNome(_ nome: String) {
        pesquisa = nome
        paginaAtual = 0
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

    private func observarMudancas() {
        observer = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave,
            object: nil,
            queue: .main ){ [weak self] _ in
                self?.carregarReceitas()
            }
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
                paginaAtual = 0
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
                paginaAtual = max(totalPaginas, 0)
            }
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
    
    deinit { // Desliga o observer
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
