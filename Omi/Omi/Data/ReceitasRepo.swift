//
//  ReceitasRepo.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import CoreData

final class ReceitasRepo {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Create
   
    // O segredo para não duplicar dados!
        func buscarOuCriarIngrediente(nome: String) throws -> Ingrediente {
            let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)
            
            let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
            // O '[c]' no final do %m avisa o Core Data para ignorar maiúsculas e minúsculas!
            // Assim "Chocolate" e "chocolate" são reconhecidos como o mesmo item.
            request.predicate = NSPredicate(format: "nome [c] == %@", nomeLimpo)
            request.fetchLimit = 1
            
            let resultados = try context.fetch(request)
            
            // Se já existe, retorna o que achou no banco
            if let ingredienteExistente = resultados.first {
                return ingredienteExistente
            } else {
                // Se não existe, cria um novo (mas não dá save ainda, vamos salvar tudo junto com a receita)
                let novoIngrediente = Ingrediente(context: context)
                novoIngrediente.id = UUID()
                novoIngrediente.nome = nomeLimpo
                return novoIngrediente
            }
        }
    
    func criarReceita(
            titulo: String,
            categoria: String,
            descricao: String,
            imagem: String,
            tempoDePreparo: Int,
            porcoes: String,
            dificuldade: String?,
            ingredientesComMedida: [(ingrediente: Ingrediente, quantidade: String, medida: String)]
        ) throws {
            
            // 1. Cria a Receita principal
            let receita = Receita(context: context)
            receita.id = UUID()
            receita.titulo = titulo
            receita.categoria = categoria
            receita.descricao = descricao
            receita.imagem = imagem
            receita.tempoDePreparo = Int16(tempoDePreparo)
            receita.porcoes = porcoes
            receita.dificuldade = dificuldade
            receita.dataCriacao = Date()
            
            // 2. Loop passando por todos os ingredientes que o usuário escolheu
            for item in ingredientesComMedida {
                
                // Cria a entidade intermediária
                let relacao = IngredienteDaReceita(context: context)
                    relacao.id = UUID()
                    relacao.quantidade = item.quantidade
                    relacao.medida = item.medida
                
                // 3. A Mágica do Core Data: Fazendo os vínculos (Relacionamentos)
                relacao.receita = receita           // Diz que essa medida pertence à receita que acabamos de criar
                relacao.ingrediente = item.ingrediente // Aponta para o ingrediente existente no banco de dados
            }
            
            // 4. Salva o contexto (Isso salva a Receita e todas as relações ReceitaIngrediente de uma vez só)
            try context.save()
        }
    
    func criarPasso(receita: Receita, etapa: Int16, texto: String, nome: String, imagem: String, tempoEstimado: Int16) throws {
        let passo = PassoReceita(context: context)
        passo.id = UUID()
        passo.etapa = etapa
        passo.texto = texto
        passo.nome = nome
        passo.imagem = imagem
        passo.tempoEstimado = tempoEstimado
        
        passo.receita = receita
                
        // Don't forget to save!
        try context.save()
    }
    
    // Read (Fetch)
    func buscarIngredientes() throws -> [Ingrediente] {
        let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Ingrediente.nome, ascending: true)]
        return try context.fetch(request)
    }
    func buscarReceitas() throws -> [Receita] {
        let request = NSFetchRequest<Receita>(entityName: "Receita")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Receita.titulo, ascending: true)]
        return try context.fetch(request)
    }
    func buscarPassos(para receita: Receita) throws -> [PassoReceita] {
            let request = NSFetchRequest<PassoReceita>(entityName: "PassoReceita")
            
            // Predicate: "Only give me the steps where the recipe matches the one I passed in"
            request.predicate = NSPredicate(format: "receita == %@", receita)
            
            // Sort: Put them in ascending order based on the 'etapa' number
            request.sortDescriptors = [NSSortDescriptor(keyPath: \PassoReceita.etapa, ascending: true)]
            
            return try context.fetch(request)
        }
    
    // Delete
    func deletarIngrediente(ingrediente: Ingrediente) throws {
        context.delete(ingrediente)
        try context.save()
    }
    func deletarReceita(receita: Receita) throws {
        context.delete(receita)
        try context.save()
    }
    func deletarPasso(passo: PassoReceita) throws {
        context.delete(passo)
        try context.save()
    }
}
