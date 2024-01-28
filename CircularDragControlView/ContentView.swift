//
//  ContentView.swift
//  CircularDragControlView
//
//  Created by Mate Tohai on 28/01/2024.
//

import SwiftUI
import Foundation

struct CircularDragControlView: View {
    @State private var mid: CGPoint = CGPoint(x: 0, y: 0)
    @State private var pos: CGPoint = CGPoint(x: 50, y: 50)
    
    @GestureState private var fingerPos: CGPoint? = nil
    
    @GestureState private var startPos: CGPoint? = nil
    
    // Used for snapping to mid
    @State private var incrementalStartPos: CGPoint = CGPoint(x: 50, y: 50)
    @State private var cycles: UInt16 = 0
    
    @State private var distance: Int = 0
    @State private var angle: Int = 0
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                // Refresh incrementalStartPos every 200 cycles
                if cycles >= 200 {
                    incrementalStartPos = pos
                    cycles = 0
                }
                cycles += 1
                var newPos = startPos ?? pos
                
                // Go to real position
                if (startPos == nil) { // If firt cycle
                    newPos.x += value.translation.width
                    newPos.y += value.translation.height
                    
                } else if (incrementalStartPos.x < mid.x + 5 && incrementalStartPos.x > mid.x - 5) { // If started near mid
                    newPos.x += value.translation.width
                    newPos.y += value.translation.height
                    
                } else if !(pos.x < mid.x + 10 && pos.x > mid.x - 10) { // If not near mid (x)
                    newPos.x += value.translation.width
                    newPos.y += value.translation.height
                    
                } else if !(pos.y < mid.y + 10 && pos.y > mid.y - 10) { // If not near mid (y)
                    newPos.x += value.translation.width
                    newPos.y += value.translation.height
                    
                }
                // Snap to mid
                else {
                    newPos = mid
                }
                
                self.pos = newPos
                
                self.angle = 180 - Int(atan2(pos.x - mid.x, pos.y - mid.y) * (180.0 / .pi))
                self.distance = Int(sqrt(pow(pos.x - mid.x, 2) + pow(pos.y - mid.y, 2)))
                
                print(self.distance, self.angle)
                
            }
            .updating($startPos) { (value, startPos, transaction) in
                startPos = startPos ?? pos
            }
    }
    
    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerPos) { (value, fingerPos, transaction) in
                fingerPos = value.location
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    VStack {
                        Text("\(angle)°, \(distance)")
                        Spacer()
                    }
                    Spacer()
                }
                Path { path in
                    path.move(to: mid)
                    path.addLine(to: pos)
                }
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
                Circle()
                    .stroke(Color.gray)
                    .frame(width: 60, height: 60)
                    .position(mid)
                
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .position(pos)
                    .gesture(
                        simpleDrag.simultaneously(with: fingerDrag)
                    )
            }
            .onAppear {
                mid = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                pos = mid
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        GroupBox {
            CircularDragControlView()
        }
        .aspectRatio(contentMode: .fit)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


