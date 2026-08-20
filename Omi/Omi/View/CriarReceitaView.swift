//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI

struct CriarReceitaView: View {
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
    CriarReceitaView(viewModel: .preview)
}

