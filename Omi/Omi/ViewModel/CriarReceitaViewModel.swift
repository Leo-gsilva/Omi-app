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
    
    enum Modo {
        case criar
        case editar(ReceitaModel)
    }
    
    private let modo: Modo
    private let repo: ReceitaRepositorio
    
    // MARK: - Properties
    var estaEditando: Bool {
        if case .editar = modo { return true }
        return false
    }
    
    var tituloDaTela: String {
        estaEditando ? "Editar receita" : "Anotar receita"
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
    }
    
    // Recipe Fields
    var titulo = ""
    var categoria: CategoriaReceita = .refeicao
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = ""
    var imagem: Data? // Matched with PhotosPicker Data
    
    // Ingredients
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""
    var medidaTexto = ""
    
    // Steps
    var passosAdicionados: [PassoAdicionado] = []
    var nomeDoPasso: String = ""
    var descricaoDoPasso: String = ""
    var tempoPassoTexto: String = ""
    
    // MARK: - Initializer
    init(modo: Modo, repo: ReceitaRepositorio) {
        self.modo = modo
        self.repo = repo
        
        if case .editar(let receita) = modo {
            preencherComReceitaExistente(receita)
        }
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
    
    func adicionarIngrediente() {
        guard !nomeIngredienteTexto.isEmpty,
              let quantidade = Double(quantidadeTexto),
              !medidaTexto.isEmpty else { return }
        
        let novoItem = IngredienteAdicionado(nome: nomeIngredienteTexto, quantidade: quantidade, medida: medidaTexto)
        ingredientesAdicionados.append(novoItem)
        
        nomeIngredienteTexto = ""
        quantidadeTexto = ""
        medidaTexto = ""
    }
    
    func adicionarPasso() {
        guard !nomeDoPasso.isEmpty, !descricaoDoPasso.isEmpty else { return }
        
        let passo = PassoAdicionado(
            etapa: passosAdicionados.count + 1,
            nome: nomeDoPasso,
            texto: descricaoDoPasso,
            tempoEstimado: Int(tempoPassoTexto) ?? 0
        )
        
        passosAdicionados.append(passo)
        
        nomeDoPasso = ""
        descricaoDoPasso = ""
        tempoPassoTexto = ""
    }
    
    func salvarReceitaNoBanco() {
        do {
            let imagemString = imagem?.base64EncodedString() ?? ""
            
            switch modo {
            case .criar:
                try repo.criarReceita(
                    titulo: titulo,
                    categoria: categoria.rawValue,
                    descricao: descricao,
                    imagem: imagem,
                    tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                    porcoes: porcoesTexto,
                    dificuldade: dificuldade.isEmpty ? nil : dificuldade,
                    ingredientes: ingredientesAdicionados,
                    passos: passosAdicionados
                )
                
            case .editar(let receitaOriginal):
                try repo.atualizarReceitaCompleta(
                    id: receitaOriginal.id,
                    titulo: titulo,
                    categoria: categoria.rawValue,
                    descricao: descricao,
                    imagem: imagem,
                    tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                    porcoes: porcoesTexto,
                    dificuldade: dificuldade.isEmpty ? nil : dificuldade,
                    ingredientes: ingredientesAdicionados,
                    passos: passosAdicionados
                )
            }
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }
}
