//
//  CriarReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import Observation

@Observable
final class CriarReceitaViewModel {
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
    }
    
    // Receita
    var titulo = ""
    var categoria: CategoriaReceita = .almoco
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = ""
    
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
    
    func salvarReceitaNoBanco() {
        do {
            try repo.criarReceita(
                titulo: titulo,
                categoria: categoria.rawValue,
                descricao: descricao,
                imagem: "imagem_padrao",
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
