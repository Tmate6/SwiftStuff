//
//  ContentView.swift
//  ArrangeableWidgets
//
//  Created by Mate Tohai on 2023. 06. 30..
//

import SwiftUI

struct Widget: Identifiable {
    var id: UUID = UUID()
    var width: Int = 1
}

struct ContentView: View {
    @State private var originalSelected: Int? = nil
    @State private var selected: Int? = nil
    @State private var position: CGPoint = .zero
    @State private var widgets: [Widget] = [Widget(), Widget(width: 3), Widget(), Widget(width: 2)]
    
    var body: some View {
        GroupBox {
            GeometryReader { geometry in
                Grid(horizontalSpacing: 10) {
                    GridRow {
                        ForEach(1...widgets.reduce(0) { $0 + $1.width }, id: \.self) { _ in
                            Spacer()
                                .frame(maxWidth: .infinity, maxHeight: 0)
                        }
                    }
                    GridRow {
                        ForEach(widgets) { widget in
                            GroupBox {
                                Image(systemname: "placeholdertext.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(originalSelected == (widgets.firstIndex(where: {$0.id == widget.id})!) ? Color.secondary : selected == widgets.firstIndex(where: {$0.id == widget.id}) ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .gridCellColumns(widget.width)
                            .frame(height: geometry.size.height)
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            position = value.location
                            let segmentWidth = geometry.size.width / CGFloat(widgets.reduce(0) { $0 + $1.width })
                            
                            var previousAddedCoumns: Int = 0
                            
                            for widget in widgets {
                                if Int(position.x / segmentWidth) < (widgets.firstIndex(where: {$0.id == widget.id})! + previousAddedCoumns + widget.width) && Int(position.x / segmentWidth) > (widgets.firstIndex(where: {$0.id == widget.id})! + previousAddedCoumns - widget.width) {
                                    selected = widgets.firstIndex(where: {$0.id == widget.id})!
                                    break
                                }
                                previousAddedCoumns += widget.width - 1
                            }
                            if originalSelected == nil {
                                originalSelected = selected
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                let movedWidget = widgets[originalSelected!]
                                widgets.remove(at: originalSelected!)
                                widgets.insert(movedWidget, at: selected!)
                                selected = nil
                                originalSelected = nil
                            }
                        }
                )
            }
        }
        .frame(height: 100)
        .padding(10)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
