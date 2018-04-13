//
//  Test.swift
//  TTITransition
//
//  Created by 1 on 12.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import Foundation

class Car {
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        
        engine.transport = self
    }
    
    func start() {
        engine.start()
    }
    
    func run() {
        engine.makeForce()
    }
    

}

extension Car : Transport {
    func engineWillBroke(engine: Engine) {
        
    }
    
    func engineWillBroke() { //  сломался
        // катапултировать водителя
    }
}

class Mercedes : Car {
    
}

class Engine {
    
    weak var transport: Transport?
    
    func start() {
        
    }
    
    func makeForce() {
        if true { // что-то сломалось
            transport?.engineWillBroke(engine: self)
        }
    }
    
    func finish() {
        
    }
}

protocol Transport : class {
    func engineWillBroke(engine: Engine)
}

class Flyer : Transport {
    let engine: Engine
    let engine2: Engine
    
    init(engine: Engine, engine2: Engine) {
        self.engine = engine
        self.engine2 = engine2
        
        engine.transport = self
        engine2.transport = self
    }
    
    func start() {
        engine.start()
    }
    
    func fly() {
        engine.makeForce()
    }
    
    func engineWillBroke(engine: Engine) { //  сломался
        // катапултировать водителя
        engine.finish()
    }
}
