//
//  ResultProducer.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 13.06.2022.
//

protocol ResultProducer {
    var delegate: ResultDelegate? { get set }
    func run()
}
