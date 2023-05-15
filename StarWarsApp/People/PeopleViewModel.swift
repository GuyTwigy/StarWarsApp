//
//  PeopleViewModel.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import Foundation

class PeopleViewModel {
    typealias UpdateHandler = ([SinglePeople]) -> ()
    typealias UpdateSortedArrHandler = ([SinglePeople]) -> ()
    
    private var updateHandler: UpdateHandler?
    private var updateSortedArrHandler: UpdateSortedArrHandler?
    var peopleArr = [SinglePeople]()
    var pageNum = 1
    var totalPeople = Int()
    var isLoading: Bool = false
    var isReachedMax: Bool = false
    var isSorted: Bool = false
    var isFromSearch: Bool = false
    var peopleArrCount: Int {
        return peopleArr.count
    }
    
    //MARK: - Initializers
    init(updateHandler: UpdateHandler? = nil, updateSortedArrHandler: UpdateSortedArrHandler? = nil) {
        self.updateHandler = updateHandler
        self.updateSortedArrHandler = updateSortedArrHandler
        getPeopleData()
    }
    
    // MARK: - Services
    func getPeopleData() {
        self.isLoading = true
        NetworkManager.shared.getPeopleOrSearch(type: .people, pageNum: pageNum, searchText: nil) { [weak self] peopledata in
            guard let peopledata, let self, let total = peopledata.count else {
                self?.isLoading = false
                return
            }
            
            DispatchQueue.main.async {
                if self.pageNum == 1 {
                    self.totalPeople = total
                }
                self.peopleArr.append(contentsOf: peopledata.results)
                if self.peopleArrCount >= self.totalPeople {
                    self.isReachedMax = true
                }
                self.pageNum += 1
                self.isLoading = false
                self.updateHandler?(peopledata.results)
            }
        }
    }
    
    func getDataFromSearchBar(searchText: String) {
        reset()
        isFromSearch = true
        NetworkManager.shared.getPeopleOrSearch(type: .search, pageNum: pageNum, searchText: searchText) { [weak self] peopleData in
            guard let peopleData, let self else {
                return
            }
            
            self.peopleArr = peopleData.results
            if searchText.isEmpty {
                self.isFromSearch = false
            }
            self.updateSortedArrHandler?(self.peopleArr)
        }
    }
    
    func sortArrByHeight() {
        if !isSorted {
            isSorted = true
            peopleArr.sort( by: { Int($1.height ?? "") ?? 0 > Int($0.height ?? "") ?? 0 })
            updateSortedArrHandler?(peopleArr)
        }
    }
    
    func reset() {
        isLoading = false
        pageNum = 1
        peopleArr.removeAll()
    }
}

enum modelTypeCall {
    case people
    case search
}
