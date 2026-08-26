////
////  ContentView.swift
////  Omi
////
////  Created by Leonardo Gonçalves da Silva on 14/08/26.
////
//
//import SwiftUI
//
//struct ContentViewCoreDataTestes: View {
//    // É o contexto do Persistence, lida com a persistência no CoreData
//    @Environment(\.managedObjectContext) private var contexto
//    
//    @State private var mostrarForm: Bool = false
//        
//    var body: some View {
//        NavigationStack {
//            VStack{
//                LivroReceitasViewSimples(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
//            }
//            .navigationTitle("Minhas Receitas")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button{
//                        mostrarForm.toggle()
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                    .sheet(isPresented: $mostrarForm) {
//                        CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: contexto), modo: .criar))
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    // recebe o .preview que é uma inicialização em ambiente controlado, ambiente de pre-visualização. Em ambiente de produção/buildado o banco tem outros elementos.
//    ContentViewCoreDataTestes()
//        .environment(\.managedObjectContext, ReceitaRepositorioCoreData.preview)
//}
