//
//  CountryTableViewCell.swift
//  adesso
//
//  Created by Burak Turhan on 10.11.2022.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    var saveButtonAction: ((Any) -> Void)?

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderColor = UIColor.black.cgColor
        backView.layer.cornerRadius = 12
        backView.layer.borderWidth = 2
        backView.backgroundColor = UIColor.clear

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func setSave(_ sender: UIButton) {

        self.saveButtonAction?(sender)

    }

}
