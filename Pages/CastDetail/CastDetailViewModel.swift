//
//  CastDetailViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//

import Foundation

final class CastDetailViewModel {
    private let personId: Int
    private(set) var personDetail: PersonDetail?
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(personId: Int) {
        self.personId = personId
    }
    
    func fetchPersonDetail() {
        MovieService.shared.fetchPersonDetail(id: personId) { [weak self] result in
            switch result {
            case .success(let detail):
                self?.personDetail = detail
                DispatchQueue.main.async {
                    self?.onUpdate?()  
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?(error)
                }
            }
        }
    }
}
