//
//  SavedTableViewCell.swift
//  adesso
//
//  Created by Burak Turhan on 13.11.2022.
//

import UIKit

class SavedTableViewCell: UITableViewCell {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var savedCountryLabel: UILabel!

    @IBOutlet weak var backView: UIView!

    var saveButtonAction: ((Any) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.borderColor = UIColor.black.cgColor
        backView.layer.cornerRadius = 12
        backView.layer.borderWidth = 2
        backView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func saveTapped(_ sender: Any) {

        self.saveButtonAction?(sender)
    }

}
