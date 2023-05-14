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
    
    enum GroupsType {
        case allGroups
        case myGroups
    }
    
    private var updateHandler: UpdateHandler?
    private var updateSortedArrHandler: UpdateSortedArrHandler?
    var peopleArr = [SinglePeople]()
    var pageNum = 1
    var totalPeople = Int()
    var isLoading: Bool = false
    var isReachedMax: Bool = false
    var isSorted: Bool = false
    var peopleArrCount: Int {
        return peopleArr.count
    }
    
    //MARK: - Initializers
    init(updateHandler: UpdateHandler? = nil, updateSortedArrHandler: UpdateSortedArrHandler? = nil) {
        self.updateHandler = updateHandler
        self.updateSortedArrHandler = updateSortedArrHandler
        getData()
    }
    
    // MARK: - Services
    func getData() {
        self.isLoading = true
        NetworkManager.shared.getPeople(pageNum: pageNum) { [weak self] peopledata in
            guard let peopledata, let self, let total = peopledata.count else {
                self?.isLoading = false
                return
            }
            
            DispatchQueue.main.async {
                if self.pageNum == 1 {
                    self.totalPeople = total
                }
                self.peopleArr.append(contentsOf: peopledata.results)
                if self.peopleArrCount == self.totalPeople {
                    self.isReachedMax = true
                }
                self.pageNum += 1
                self.isLoading = false
                self.updateHandler?(peopledata.results)
            }
        }
    }
    
    func sortArrByHeight() {
        if !isSorted {
            isSorted = true
            peopleArr.sort( by: { Int($1.height ?? "") ?? 0 > Int($0.height ?? "") ?? 0 })
            updateSortedArrHandler?(peopleArr)
        }
    }
}
