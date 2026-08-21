//
//  DividerDoApp.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
import SwiftUI

struct DividerPersonalizado: View {
    var body: some View {
        Rectangle()
            .fill(Color(.corDivider))
            .frame(height: 2)
    }
}
#Preview{
    DividerPersonalizado()
}
