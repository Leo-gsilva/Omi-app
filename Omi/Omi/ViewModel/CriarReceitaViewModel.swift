//
//  CriarReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import Observation
import Foundation

@Observable
final class CriarReceitaViewModel {
    private let repo: ReceitaRepositorio
//    var receita: ReceitaModel?
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        
//        if modo {
//            preencherComReceitaExistente(receita)
//        }
    }
    
    var modo: Bool = false
    
    // Receita
    var titulo = ""
    var categoria: CategoriaReceita = .refeicao
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = ""
    var imagem: Data?
    
    // Ingredientes
    // Lista dos itens que o usuário foi adicionando na tela
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    
    // Campos temporários para digitar
    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""
    var medidaTexto = ""
    
    // Passos
    var passosAdicionados: [PassoAdicionado] = []
    
    var nomeDoPasso: String = ""
    var descricaoDoPasso: String = ""
    var tempoPassoTexto: String = ""
    var imagemPasso: Data?
    
    // FUNÇÕES
    // INGREDIENTE
    func adicionarIngrediente() {
        guard !nomeIngredienteTexto.isEmpty,
              let quantidade = Double(quantidadeTexto),
              !medidaTexto.isEmpty else { return }
        
        let novoItem = IngredienteAdicionado(nome: nomeIngredienteTexto, quantidade: quantidade, medida: medidaTexto)
        ingredientesAdicionados.append(novoItem)
        
        // Limpa os campos para o próximo ingrediente
        nomeIngredienteTexto = ""
        quantidadeTexto = ""
        medidaTexto = ""
    }
    
    // ADICIONAR PASSO
    func adicionarPasso() {
        guard !nomeDoPasso.isEmpty, !descricaoDoPasso.isEmpty else { return }
        
        let passo = PassoAdicionado(etapa: passosAdicionados.count + 1, nome: nomeDoPasso, texto: descricaoDoPasso, tempoEstimado: Int(tempoPassoTexto) ?? 0)
        
        passosAdicionados.append(passo)
        
        nomeDoPasso = ""
        descricaoDoPasso = ""
        tempoPassoTexto = ""
    }
    
    // MARK: - Actions
    func preencherComReceitaExistente(_ receita: ReceitaModel) {
        titulo = receita.titulo
        categoria = receita.categoria
        descricao = receita.descricao
        tempoDePreparoTexto = String(receita.tempoDePreparo)
        porcoesTexto = receita.porcoes
        dificuldade = receita.dificuldade ?? ""
        
        ingredientesAdicionados = receita.ingredientes.compactMap {
            guard let qtd = Double($0.quantidade) else { return nil }
            return IngredienteAdicionado(nome: $0.nome, quantidade: qtd, medida: $0.medida)
        }
        
        passosAdicionados = receita.passos.map {
            PassoAdicionado(etapa: Int($0.etapa), nome: $0.nome, texto: $0.texto, tempoEstimado: Int($0.tempoEstimado))
        }
    }
    
    func salvarReceitaNoBanco() {
        do {
            try repo.criarReceita(
                titulo: titulo,
                categoria: categoria.rawValue,
                descricao: descricao,
                imagem: imagem,
                tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                porcoes: porcoesTexto,
                dificuldade: dificuldade,
                ingredientes: ingredientesAdicionados,
                passos: passosAdicionados
            )
            print("Receita e ingredientes salvos perfeitamente!")
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }
}
