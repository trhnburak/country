//
//  SavedTableViewController.swift
//  adesso
//
//  Created by Burak Turhan on 13.11.2022.
//

import UIKit
import CoreData

class SavedTableViewController: UITableViewController {

    var selectedCode: String?

    var savedName = [String]() {
        didSet {

            DispatchQueue.main.async {
                self.savedTableView?.reloadData()
            }

        }
    }

    var savedCode = [String]() {
        didSet {

            DispatchQueue.main.async {
                self.savedTableView?.reloadData()
            }

        }
    }

    @IBOutlet var savedTableView: UITableView! {
        didSet {

            savedTableView.delegate = self
            savedTableView.dataSource = self

        }

    }

    // MARK: - Swift Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.savedCode.removeAll()
        self.savedName.removeAll()

        fetch()
        self.tableView.reloadData()

    }

    // MARK: - CoreData Functions

    private func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        let managedObjectContext = appDelegate?.persistentContainer.viewContext

         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountry")
        do {

            guard let fetched = try? managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] else { return }

            for fetch in fetched {
                if let code = fetch.value(forKey: "code") as? String {

                    for val in self.savedCode where val == code {
                        self.savedCode.removeAll()
                    }
                    self.savedCode.append(code)

                }
                if let name = fetch.value(forKey: "name") as? String {

                    for val in self.savedName where val == name {
                        self.savedName.removeAll()

                    }
                    self.savedName.append(name)

                }
            }
            self.tableView.reloadData()

        } catch let nserror as NSError {
            print("ERROR: Coredata error \(nserror)")
        }

    }

    private func delete(code: String) {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        let managedObjectContext = appDelegate?.persistentContainer.viewContext

         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountry")

        fetchRequest.predicate = NSPredicate(format: "code = %@", code)
        do {

            guard let fetched = try? managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] else { return }

            for fetch in fetched {
                if let code = fetch.value(forKey: "code") as? String {

            print(fetch)

                    managedObjectContext?.delete(fetch)

                    do {

                        try managedObjectContext?.save()
                        self.savedCode.removeAll()
                        self.savedName.removeAll()
                        self.fetch()

                    } catch let nserror as NSError {
                        print("ERROR: Coredata error \(nserror)")
                    }

                }
               /* if let name = fetch.value(forKey: "name") as? String{
                    self.savedName.append(name)
                }*/
            }

        } catch let nserror as NSError {
            print("ERROR: Coredata error \(nserror)")
        }

    }

    private func saveCountries(name: String, code: String) {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        guard let managedObjectContext1 = appDelegate?.persistentContainer.viewContext else { return }

        let managedObjectContext = managedObjectContext1

        let entity = NSEntityDescription.entity(forEntityName: "SavedCountry", in: managedObjectContext)

        let savedCountries = NSManagedObject(entity: entity!, insertInto: managedObjectContext)

        savedCountries.setValue(name, forKey: "name")
        savedCountries.setValue(code, forKey: "code")
        savedCountries.setValue(1, forKey: "is_saved")

        do {
            try? managedObjectContext.save()
            self.fetch()

        } catch let nserror as NSError {
            print("ERROR: Coredata error \(nserror)")
        }

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        if let viewController = segue.destination as? DetailViewController {
            viewController.code = selectedCode

        }
        let backItem = UIBarButtonItem()
           backItem.title = ""
           navigationItem.backBarButtonItem = backItem
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SavedTableViewController {
    override func numberOfSections(in savedTableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ savedTableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return savedName.count
    }

    override func tableView(_ savedTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = savedTableView.dequeueReusableCell(withIdentifier: "savedCell", for: indexPath) as? SavedTableViewCell else {
            return UITableViewCell()
        }

        let cellName = savedName[indexPath.row]
        let cellCode = savedCode[indexPath.row]

        cell.backgroundColor = .lightGray

        cell.savedCountryLabel.textColor = .black
        cell.savedCountryLabel.text = cellName

        cell.saveButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        cell.saveButton.setTitle("", for: .normal)
        cell.saveButton.tintColor = .darkGray

        savedCode.forEach { code in
            if code == cellCode {
                cell.saveButton.tintColor = UIColor.black
            }
        }

        // let savedCountryData = saved[indexPath.row]
       /* if(savedCountryData.value(forKey: "is_saved") as! Int == 1){
           
        }*/

        // Save Button Action Which is Star
        cell.saveButtonAction = { _ in
           print("tapped")
            var name = self.savedName[indexPath.row]
            var code = self.savedCode[indexPath.row]

            if  cell.saveButton.tintColor == UIColor.darkGray {
                cell.saveButton.tintColor = UIColor.black
               self.saveCountries(name: name ?? "", code: code ?? "")

                print("saved")
            } else {
                cell.saveButton.tintColor = UIColor.darkGray
                self.delete(code: code ?? "")

                print("deleted")
            }

            self.tableView.reloadData()

            }

        return cell

    }

    override func tableView(_ savedTableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }

    override func tableView(_ savedTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)

        selectedCode = savedCode[indexPath.row]

        performSegue(withIdentifier: "detailSavedSegue", sender: nil)
    }

    override func tableView(_ savedTableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
}
