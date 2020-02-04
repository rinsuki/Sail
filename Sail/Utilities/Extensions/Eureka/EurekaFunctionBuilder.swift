//
//  EurekaFunctionBuilder.swift
//  Sail
//
//  Created by user on 2019/09/02.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Eureka

@_functionBuilder struct EurekaSectionBuilder {
    static func buildBlock(_ contents: Section...) -> Array<Section> {
        return contents
    }
}

extension Form {
    func add(@EurekaSectionBuilder child: () -> Section) {
        self.append(child())
    }
    
    func add(@EurekaSectionBuilder child: () -> Array<Section>) {
        self.append(contentsOf: child())
    }
}

@_functionBuilder struct EurekaRowBuilder {
    static func buildBlock(_ contents: BaseRow...) -> Array<BaseRow> {
        return contents
    }
}

extension Section {
    convenience init(header: String? = nil, footer: String? = nil, @EurekaRowBuilder child: () -> BaseRow) {
        self.init(header: header, footer: footer) { [child()] }
    }
    
    convenience init(header: String? = nil, footer: String? = nil, @EurekaRowBuilder child: () -> Array<BaseRow>) {
        self.init()
        if let header = header { self.header = HeaderFooterView(stringLiteral: header) }
        if let footer = footer { self.footer = HeaderFooterView(stringLiteral: footer) }
        self.append(contentsOf: child())
    }
}
