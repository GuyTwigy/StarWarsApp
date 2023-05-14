//
//  ViewController.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import UIKit

class MainVC: UIViewController {

    //MARK: properties
    var pageNum: Int = 1
    var arrPeople: [SinglePeople] = []
    var totalPeople: Int = 0
    var model: PeopleModelData?
    var isSorted: Bool = false
    var favIndex = (String(), String())
    var isLoading: Bool = false
    
    //MARK: outlets
    @IBOutlet weak var tblPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
//    init(model: PeopleModelData? = nil) {
//        self.model = model
//        super.init(nibName: "MainVC", bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getData()
        loader.isHidden = true
    }
    
    func setupTableView() {
        tblPeople.delegate = self
        tblPeople.dataSource = self
        tblPeople.register(UINib(nibName: PeopleCell.nibName, bundle: nil), forCellReuseIdentifier: PeopleCell.nibName)
        tblPeople.estimatedRowHeight = 200
        tblPeople.rowHeight = UITableView.automaticDimension
    }
    
    
    
    
    func getData() {
        self.isLoading = true
        loader.isHidden = false
        loader.startAnimating()
        NetworkManager.shared.getPeople(pageNum: pageNum) { [weak self] peopledata in
            guard let peopledata, let self, let total = peopledata.count else {
                self?.isLoading = false
                self?.loader.isHidden = true
                self?.loader.startAnimating()
                print("something went wrong")
                
                return
            }
            
            DispatchQueue.main.async {
                if self.pageNum == 1 {
                    self.totalPeople = total
                }
                self.arrPeople.append(contentsOf: peopledata.results)
                self.tblPeople.reloadData()
                self.pageNum += 1
                self.loader.stopAnimating()
                self.loader.isHidden = true
                self.isLoading = false
            }
        }
    }
    
    func sortArrByHeight() {
        if !isSorted {
            isSorted = true
            arrPeople.sort( by: { Int($1.height ?? "") ?? 0 > Int($0.height ?? "") ?? 0 })
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                
                self.tblPeople.reloadData()
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
        }
        cell.peopleNameLbl.text = arrPeople[indexPath.row].name
        cell.heightLbl.text = arrPeople[indexPath.row].height
        if arrPeople[indexPath.row].isFavorite ?? false {
            cell.favoriteImage.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = arrPeople.firstIndex(where: { $0.isFavorite == true }) {
            arrPeople[index].isFavorite = false
        }
        arrPeople[indexPath.row].isFavorite = true
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= arrPeople.count - 2 && !isLoading && indexPath.row < totalPeople {
            getData()
        } else if arrPeople.count >= totalPeople {
            sortArrByHeight()
        }
    }
}
