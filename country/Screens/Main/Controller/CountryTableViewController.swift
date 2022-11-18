//
//  CountryTableViewController.swift
//  adesso
//
//  Created by Burak Turhan on 10.11.2022.
//

import UIKit
import Alamofire
import CoreData

class CountryTableViewController: UITableViewController, UITabBarDelegate, UITabBarControllerDelegate {

    var offset = 0
    var respModel = [Data]()
    var selectedCode: String?
    var savedName = [String]() {
        didSet {

            DispatchQueue.main.async {
                self.countryTableView?.reloadData()
            }

        }
    }

    var savedCode = [String]() {
        didSet {

            DispatchQueue.main.async {
                self.countryTableView?.reloadData()
            }

        }
    }

    @IBOutlet weak var countryTableView: UITableView! {
        didSet {

            countryTableView.delegate = self
            countryTableView.dataSource = self

        }

    }

    // MARK: - Swift Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
      
      title = "Countries"
        

        getModel()
        fetch()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for val in self.savedCode {
            print(val)
        }
        self.savedCode.removeAll()
        self.savedName.removeAll()

        fetch()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

    // MARK: - CoreData Functions

     func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        let managedObjectContext = appDelegate?.persistentContainer.viewContext

         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCountry")
        do {

            guard let fetched = try? managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] else { return }

            for fetch in fetched {
                print(fetch)
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

    // MARK: - Alamofire Functions

    private func getModel() {
        let request = AF.request("https://wft-geo-db.p.rapidapi.com/v1/geo/countries/?rapidapi-key=31edfab498msh1708eb1cc2064cbp1aece4jsnc27c88b535f1&limit=10&offset=\(offset)").validate(statusCode: 200..<300)

        request.responseDecodable(of: CountryModel.self) { (response) in
            switch response.result {
            case .success:

                print("Fetch Successful")

                guard let countries = response.value else { return }
                
                if self.respModel != nil {
                    self.respModel.append(contentsOf: countries.data ?? [])
                } else {
                
                    self.respModel = countries.data ?? []
                }

               
                self.tableView.reloadData()

            case let .failure(error):
                debugPrint(error)
            }
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
extension CountryTableViewController {
    override func numberOfSections(in countryTableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ countryTableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return respModel.count
    }

    override func tableView(_ countryTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = countryTableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as? CountryTableViewCell else {
            return UITableViewCell()
        }

        let country = respModel[indexPath.row]

        cell.backgroundColor = .lightGray

        cell.countryNameLabel.textColor = .black
        cell.countryNameLabel.text = country.name

        cell.saveButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        cell.saveButton.setTitle("", for: .normal)
        cell.saveButton.tintColor = .darkGray

        for val in self.savedCode where val == country.code {
            cell.saveButton.tintColor = UIColor.black
        }

        // let savedCountryData = saved[indexPath.row]
       /* if(savedCountryData.value(forKey: "is_saved") as! Int == 1){
           
        }*/

        // Save Button Action Which is Star
        cell.saveButtonAction = { _ in
           print("tapped")
            var name = country.name
            var code = country.code

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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)

        selectedCode = respModel[indexPath.row].code

        performSegue(withIdentifier: "detailSegue", sender: nil)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        if indexPath.row >= (self.respModel.count ) - 5 {
            offset = offset + 1
            getModel()
        }
    
    }
}
