//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI
import CoreData

struct CriarReceitaView: View {
    // Declaração para informar o context a ser observado (o mesmo em todas as views que precisam de contexto)
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var voltar
    
    @Bindable var viewModel: CriarReceitaViewModel // Pq é um ObservableObject, então não precisa de init no viewModel aqui
    
    var body: some View {
        NavigationView{
            Form{
                Section("Título") {
                    TextField("Titulo:", text: $viewModel.titulo)
                }
                Section("Descrição") {
                    TextEditor(text: $viewModel.descricao)
                        .frame(minHeight: 200)
                }
                
                Section("Ingredientes") {
                    TextField("Ingrediente", text: $viewModel.nomeIngredienteTexto)
                    TextField("Quantidade", text: $viewModel.quantidadeTexto)
                    TextField("Medida", text: $viewModel.medidaTexto)

                    Button("Adicionar Ingrediente") {
                        viewModel.adicionarIngrediente()
                    }

                    ForEach(viewModel.ingredientesAdicionados) { item in
                        Text("\(item.quantidade) \(item.medida) - \(item.nome)")
                    }
                }
                
                Section("Passos") {
                    TextField("Nome do passo", text: $viewModel.nomeDoPasso)
                    TextEditor(text: $viewModel.descricaoDoPasso)

                    TextField("Tempo", text: $viewModel.tempoPassoTexto)

                    Button("Adicionar Passo") {
                        viewModel.adicionarPasso()
                    }

                    ForEach(viewModel.passosAdicionados) { passo in
                        Text("\(passo.etapa). \(passo.nome)")
                    }
                }
            }
            .navigationTitle("Anotar receita")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        viewModel.salvarReceitaNoBanco()
                        voltar()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        voltar()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}


#Preview {
    //Criando contexto fake pro preview
    let context = PersistenceController.preview.container.viewContext
    // Repo teste para o preview
    let repo = ReceitasRepo(context: context)
    //Criando viewModels fake pro preview
    let viewModel = CriarReceitaViewModel(repo: repo)
    // Gerando o preview com dados fake
    CriarReceitaView(viewModel: viewModel)
        .environment(\.managedObjectContext, context)
}

