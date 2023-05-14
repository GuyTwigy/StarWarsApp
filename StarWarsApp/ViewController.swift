//
//  ViewController.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import UIKit

class MainVC: UIViewController {
    
    //MARK: properties
    var arrPeople: [SinglePeople] = []
    var model: PeopleViewModel?
    var totalPeople = Int()
    var fav: SinglePeople?
    var isFromSearch: Bool = false
    
    //MARK: outlets
    @IBOutlet weak var tblPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureDataModel()
        setupSearchBar()
    }
    
    func setupTableView() {
        tblPeople.delegate = self
        tblPeople.dataSource = self
        tblPeople.register(UINib(nibName: PeopleCell.nibName, bundle: nil), forCellReuseIdentifier: PeopleCell.nibName)
        tblPeople.estimatedRowHeight = 200
        tblPeople.rowHeight = UITableView.automaticDimension
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func configureDataModel() {
        loader.isHidden = false
        loader.startAnimating()
        model = PeopleViewModel(updateHandler: { [weak self] peopleData in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    self?.loader.stopAnimating()
                    self?.loader.isHidden = true
                    return
                }
                
                self.totalPeople = peopleData.count
                self.arrPeople.append(contentsOf: peopleData)
                self.tblPeople.reloadData()
                self.loader.stopAnimating()
                self.loader.isHidden = true
            }
        }, updateSortedArrHandler: { [weak self] sortedArr in
            guard let self else {
                return
            }
            
            self.arrPeople = sortedArr
            self.checkIfFav()
            self.tblPeople.reloadData()
            self.loader.stopAnimating()
            self.loader.isHidden = true
        })
    }
    
    func checkIfFav() {
        if let fav {
            if let index = arrPeople.firstIndex(where: { $0.name == fav.name && $0.height == fav.height }) {
                arrPeople[index].isFavorite = true
            }
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeopleCell.nibName, for: indexPath) as! PeopleCell
        if let height = arrPeople[indexPath.row].height, let heightInt = Int(height) {
            cell.cellHeightConstraint.constant = CGFloat(heightInt)
        } else {
            cell.cellHeightConstraint.constant = 70
        }
        cell.peopleNameLbl.text = arrPeople[indexPath.row].name
        cell.heightLbl.text = arrPeople[indexPath.row].height
        if arrPeople[indexPath.row].isFavorite ?? false {
            cell.favoriteImage.isHidden = false
        }
        if indexPath.row == 0 {
            cell.topSeperatorView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = arrPeople.firstIndex(where: { $0.isFavorite == true }) {
            arrPeople[index].isFavorite = false
        }
        arrPeople[indexPath.row].isFavorite = true
        fav = arrPeople[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let model else {
            return
        }
        
        if indexPath.row >= arrPeople.count - 2 && !model.isLoading && indexPath.row < model.totalPeople && !isFromSearch {
            if !model.isReachedMax {
                loader.isHidden = false
                loader.startAnimating()
                model.getData()
            } else {
                model.sortArrByHeight()
            }
        } else if model.isReachedMax {
            model.sortArrByHeight()
        }
    }
}

extension MainVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let model {
            model.reset()
        }
        isFromSearch = true
        loader.isHidden = false
        loader.startAnimating()
        NetworkManager.shared.searchPeople(searchText: searchText) { [weak self] peopleData in
            guard let peopleData, let self else {
                return
            }
            
            self.arrPeople.removeAll()
            self.arrPeople = peopleData.results
            self.checkIfFav()
            self.tblPeople.reloadData()
            self.loader.stopAnimating()
            self.loader.isHidden = true
            if searchText.isEmpty {
                self.isFromSearch = false
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
}
