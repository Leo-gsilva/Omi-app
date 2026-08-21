////
////  DetalhesReceitaViewModel.swift
////  Omi
////
////  Created by Leonardo Gonçalves da Silva on 19/08/26.
////
import SwiftUI
import Observation
//
//// pelo que li, é mais tranquilo implementar o coredata usando o ObservedObject
@Observable
class DetalhesReceitaViewModel {
    let receita: ReceitaModel
//    var passo: [PassoReceita] = []
//    var ingredientes: [IngredienteDaReceita] = []
    
    private let repo: ReceitaRepositorioCoreData
    
    init(receita: ReceitaModel, repo: ReceitaRepositorioCoreData) {
        self.receita = receita
        self.repo = repo
    }
    
//    func carregarDetalhes() {
//        do{
//            self.passo = try repo.buscarPassos(para: receita)
//            
//            if let relacoes = receita.ingredientesDaReceita as? Set<IngredienteDaReceita> {
//                self.ingredientes = Array(relacoes).sorted{
//                    ($0.ingrediente?.nome ?? "") < ($1.ingrediente?.nome ?? "")
//                }
//            }
//        }catch {
//            print("Erro ao carregar detalhes: \(error)")
//        }
//    }
}
