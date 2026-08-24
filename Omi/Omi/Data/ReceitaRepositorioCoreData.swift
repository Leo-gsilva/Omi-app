//
//  ReceitasRepo.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import CoreData

// Implementação concreta usando CoreData
final class ReceitaRepositorioCoreData: ReceitaRepositorio {
    private let contexto: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.contexto = context
    }
    
    private func saveData() {
        do {
            try contexto.save()
        } catch {
            contexto.rollback()
            print("ERRO AO SALVAR COREDATA: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create
    
    // O segredo para não duplicar dados!
    private func buscarOuCriarIngrediente(nome: String) throws -> Ingrediente {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)
        
        let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
        // O '[c]' no final do %m avisa o Core Data para ignorar maiúsculas e minúsculas!
        // Assim "Chocolate" e "chocolate" são reconhecidos como o mesmo item.
        request.predicate = NSPredicate(format: "nome == [c] %@", nomeLimpo)
        request.fetchLimit = 1
        
        let resultados = try contexto.fetch(request)
        
        // Se já existe, retorna o que achou no banco
        if let ingredienteExistente = resultados.first {
            return ingredienteExistente
        } else {
            // Se não existe, cria um novo (mas não dá save ainda, vamos salvar tudo junto com a receita)
            let novoIngrediente = Ingrediente(context: contexto)
            novoIngrediente.id = UUID()
            novoIngrediente.nome = nomeLimpo
            return novoIngrediente
        }
    }

    func criarReceita(
        titulo: String,
        categoria: String,
        descricao: String,
        imagem: Data?,
        tempoDePreparo: Int16,
        porcoes: String,
        dificuldade: String?,
        ingredientes: [IngredienteAdicionado],
        passos: [PassoAdicionado]
    ) throws {
        
        // 1. Cria a Receita principal
        let receita = Receita(context: contexto)
        
        receita.id = UUID()
        receita.titulo = titulo
        receita.categoria = categoria
        receita.descricao = descricao
        receita.imagem = imagem
        receita.tempoDePreparo = tempoDePreparo
        receita.porcoes = porcoes
        receita.dificuldade = dificuldade
        receita.dataCriacao = Date()
        
        // 2. Loop passando por todos os ingredientes que o usuário escolheu
        for item in ingredientes {
            let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
            // Cria a entidade intermediária
            let relacao = IngredienteDaReceita(context: contexto)
            
            relacao.id = UUID()
            relacao.quantidade = String(item.quantidade)
            relacao.medida = item.medida
            relacao.receita = receita
            relacao.ingrediente = ingrediente
        }
        
        // CRIAR OS PASSOS
        for item in passos {
            let passo = PassoReceita(context: contexto)
            
            passo.id = UUID()
            passo.etapa = Int16(item.etapa)
            passo.nome = item.nome
            passo.texto = item.texto
            passo.imagem = imagem
            passo.tempoEstimado = Int16(item.tempoEstimado)
            passo.receita = receita
        }
        
        // 4. Salva o contexto (Isso salva a Receita e todas as relações ReceitaIngrediente de uma vez só)
        //            try context.save()
        saveData()
    }
    
    // MARK: - Read
    // Como devolve um [ReceitaModel] e não um [Receita], ele fecha o "vazamento"
    
    func buscarReceitas() throws -> [ReceitaModel] {
        let request = NSFetchRequest<Receita>(entityName: "Receita")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Receita.dataCriacao, ascending: false)]
        let entities = try contexto.fetch(request)
        return entities.map { $0.toModel() }
    }
    
    func buscarReceita(id: UUID) throws -> ReceitaModel? {
        try buscarReceitaEntity(id: id)?.toModel()
    }
    
    func buscarIngredientes() throws -> [IngredienteCadastradoModel] {
        let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Ingrediente.nome, ascending: true)]
        let entities = try contexto.fetch(request)
        return entities.map { $0.toModel() }
    }

        func buscarReceita(id: UUID) throws -> ReceitaModel? {
            try buscarReceitaEntity(id: id)?.toModel()
        }

        func buscarIngredientes() throws -> [IngredienteCadastradoModel] {
            let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Ingrediente.nome, ascending: true)]
            let entities = try contexto.fetch(request)
            return entities.map { $0.toModel() }
        }

        func buscarPassos(para receita: Receita) throws -> [PassoReceita] {
            let request = NSFetchRequest<PassoReceita>(entityName: "PassoReceita")
            request.predicate = NSPredicate(format: "receita == %@", receita)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \PassoReceita.etapa, ascending: true)]
            return try contexto.fetch(request)
        }
    // MARK: - Helpers privados de busca por id
    // Um dos poucos lugares do app que ainda "pensa"em NSManagedObject
    private func buscarReceitaEntity(id: UUID) throws -> Receita? {
            let request = NSFetchRequest<Receita>(entityName: "Receita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarPassoEntity(id: UUID) throws -> PassoReceita? {
            let request = NSFetchRequest<PassoReceita>(entityName: "PassoReceita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarIngredienteEntity(id: UUID) throws -> Ingrediente? {
            let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarRelacaoEntity(id: UUID) throws -> IngredienteDaReceita? {
            let request = NSFetchRequest<IngredienteDaReceita>(entityName: "IngredienteDaReceita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }
    
    // MARK: - Update
    
    func atualizarReceita(
            id: UUID,
            novoTitulo: String,
            novaCategoria: String,
            novaDescricao: String,
            novaImagem: Data?,
            novoTempoDePreparo: Int16,
            novasPorcoes: String,
            novaDificuldade: String?
        ) throws {
            guard let receita = try buscarReceitaEntity(id: id) else { return }

            receita.titulo = novoTitulo
            receita.categoria = novaCategoria
            receita.descricao = novaDescricao
            receita.imagem = novaImagem
            receita.tempoDePreparo = novoTempoDePreparo
            receita.porcoes = novasPorcoes
            receita.dificuldade = novaDificuldade
            receita.dataAtualizacao = Date()

            saveData()
        }
    
    func atualizarReceitaCompleta(
            id: UUID,
            titulo: String,
            categoria: String,
            descricao: String,
            imagem: Data?,
            tempoDePreparo: Int16,
            porcoes: String,
            dificuldade: String?,
            ingredientes: [IngredienteAdicionado],
            passos: [PassoAdicionado]
        ) throws {
            guard let receita = try buscarReceitaEntity(id: id) else { return }

            receita.titulo = titulo
            receita.categoria = categoria
            receita.descricao = descricao
            receita.imagem = imagem
            receita.tempoDePreparo = tempoDePreparo
            receita.porcoes = porcoes
            receita.dificuldade = dificuldade
            receita.dataAtualizacao = Date()

            // Remove as relações antigas antes de recriar do zero
            if let relacoesAntigas = receita.ingredientesDaReceita as? Set<IngredienteDaReceita> {
                relacoesAntigas.forEach(contexto.delete)
            }
            if let passosAntigos = receita.passo as? Set<PassoReceita> {
                passosAntigos.forEach(contexto.delete)
            }

            for item in ingredientes {
                let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
                let relacao = IngredienteDaReceita(context: contexto)
                relacao.id = UUID()
                relacao.quantidade = String(item.quantidade)
                relacao.medida = item.medida
                relacao.receita = receita
                relacao.ingrediente = ingrediente
            }

            for item in passos {
                let passo = PassoReceita(context: contexto)
                passo.id = UUID()
                passo.etapa = Int16(item.etapa)
                passo.nome = item.nome
                passo.texto = item.texto
                passo.imagem = imagem
                passo.tempoEstimado = Int16(item.tempoEstimado)
                passo.receita = receita
            }

            saveData()
        }
    
    func atualizarPasso(
            id: UUID,
            novaEtapa: Int16,
            novoNome: String,
            novoTexto: String,
            novaImagem: Data?,
            novoTempoEstimado: Int16
        ) throws {
            guard let passo = try buscarPassoEntity(id: id) else { return }

            passo.etapa = novaEtapa
            passo.nome = novoNome
            passo.texto = novoTexto
            passo.imagem = novaImagem
            passo.tempoEstimado = novoTempoEstimado

            saveData()
        }
    
    func atualizarIngredienteDaReceita(
            id: UUID,
            novaQuantidade: String,
            novaMedida: String
        ) throws {
            guard let relacao = try buscarRelacaoEntity(id: id) else { return }

            relacao.quantidade = novaQuantidade
            relacao.medida = novaMedida

            saveData()
        }
    
    // MARK: - Criar passo avulso (fora da criação de receita completa)
    func criarPasso(
        receitaId: UUID,
              etapa: Int16,
              nome: String,
              texto: String,
              imagem: Data?,
              tempoEstimado: Int16
          ) throws {
              guard let receita = try buscarReceitaEntity(id: receitaId) else { return }

              let passo = PassoReceita(context: contexto)
              passo.id = UUID()
              passo.etapa = etapa
              passo.nome = nome
              passo.texto = texto
              passo.imagem = imagem
              passo.tempoEstimado = tempoEstimado
              passo.receita = receita

              saveData()
          }
    
    func criarIngredienteAvulso(nome: String) throws -> IngredienteCadastradoModel {
            let ingrediente = try buscarOuCriarIngrediente(nome: nome)
            saveData()
            return ingrediente.toModel()
        }
    
    // MARK: - Delete
    // Busca entity pelo id e deleta -  quem chama não precisa ter uma referëncia do NSManagedObject
    func deletarReceita(id: UUID) throws {
            guard let receita = try buscarReceitaEntity(id: id) else { return }
            contexto.delete(receita)
            saveData()
        }
    func deletarPasso(id: UUID) throws {
           guard let passo = try buscarPassoEntity(id: id) else { return }
           contexto.delete(passo)
           saveData()
       }
    
    func deletarIngrediente(id: UUID) throws {
           guard let ingrediente = try buscarIngredienteEntity(id: id) else { return }
           contexto.delete(ingrediente)
           saveData()
       }
    
    
    
}


