//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI

struct CriarReceitaView: View {
    @State private var viewModel: CriarReceitaViewModel
        
    init(viewModel: CriarReceitaViewModel) {
        self.viewModel = viewModel
    } // <--- 1. We closed the init right here!
    
    var body: some View {
        // 2. We wrap everything inside a Form so the Sections know how to draw themselves
        Form {
            // MARK: - Adicionar Ingrediente
            Section(header: Text("Adicionar Ingredientes")) {
                
                // Um campo de texto livre para o usuário digitar o que quiser!
                TextField("O que vai na receita? (Ex: Chocolate)", text: $viewModel.nomeIngredienteTexto)
                
                HStack {
                    TextField("Qtd (ex: 2.5)", text: $viewModel.quantidadeTexto)
                        .keyboardType(.decimalPad)
                    TextField("Medida (ex: Gramas)", text: $viewModel.medidaTexto)
                }
                
                Button("Adicionar à Receita") {
                    viewModel.adicionarNaLista()
                }
                .foregroundColor(.orange)
                .disabled(viewModel.nomeIngredienteTexto.isEmpty || viewModel.quantidadeTexto.isEmpty || viewModel.medidaTexto.isEmpty)
            }
            
            // MARK: - Lista de Ingredientes Adicionados
            if !viewModel.ingredientesAdicionados.isEmpty {
                Section(header: Text("Ingredientes na Receita")) {
                    ForEach(viewModel.ingredientesAdicionados) { item in
                        HStack {
                            Text(item.nome) // Mostra o nome que ele digitou
                            Spacer()
                            Text("\(item.quantidade, specifier: "%.1f") \(item.medida)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}
