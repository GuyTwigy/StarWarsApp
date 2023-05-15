//
//  PeopleCell.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import UIKit

class PeopleCell: UITableViewCell {

    static let nibName = "PeopleCell"
    
    @IBOutlet weak var peopleNameLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSeperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        peopleNameLbl.text = ""
        heightLbl.text = ""
        favoriteImage.isHidden = true
        topSeperatorView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
