//
//  DetailViewController.swift
//  adesso
//
//  Created by Burak Turhan on 11.11.2022.
//

import UIKit
import Alamofire
import Kingfisher
import WebKit
import CoreData
import SafariServices
import SVGKit

class DetailViewController: UIViewController {

    var code: String?
    var respModel: DataClass?
    var savedCode = [String]()
    var savedName = [String]()
    

    @IBOutlet var detailView: UIView!

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var informationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        getModel(with: code)
        fetch()
        title = respModel?.name
        countryCodeLabel.text = respModel?.code
        
        let favButton = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(saveButtonTapped(_ :)))
        favButton.tintColor = UIColor.darkGray
        navigationItem.rightBarButtonItems = [favButton]
        
        
        DispatchQueue.global().async { [weak self] in
            guard let flagUrl = self?.respModel?.flagImageURI else { return }
            let flag: SVGKImage = SVGKImage(contentsOf: URL(string: flagUrl))
            
                      
                            DispatchQueue.main.async {
                                self?.detailImageView.image = flag.uiImage
                                self?.detailImageView.contentMode = .scaleAspectFill
                            }
                        
                    }
                
        
        
       
        
      informationButton.layer.cornerRadius = 2

        for val in self.savedCode where val == respModel?.code {
            favButton.tintColor = UIColor.black
        }
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let backButtonImage = UIImage(named: "left")
        self.navigationController?.navigationBar.backIndicatorImage = backButtonImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage

        // title = respModel?.name

    }

    func getModel(with code: String?) {

        guard let countryCode = code else { return }

        let request =  AF.request("https://wft-geo-db.p.rapidapi.com/v1/geo/countries/\(String(describing: countryCode))/?rapidapi-key=31edfab498msh1708eb1cc2064cbp1aece4jsnc27c88b535f1").validate(statusCode: 200..<300)

        request.responseDecodable(of: CountryDetailModel.self) { (response) in

            switch response.result {
            case .success:

                print("Detail Fetch Successful")

                guard let country = response.value else { return }
                self.respModel = country.data

                self.viewDidLoad()
                self.viewWillAppear(true)

            case let .failure(error):
                debugPrint(error)
            }
        }

    }

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

    func showWiki(_ wiki: String) {
        if let url = URL(string: "https://www.wikidata.org/wiki/\(wiki)") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @objc private func saveButtonTapped(_ sender: UIBarButtonItem){
        print("tapped")

        var name  = respModel?.name
        var code = respModel?.code
        if(self.savedCode.isEmpty){
            sender.tintColor = .black
            saveCountries(name: name ?? "", code: code ?? "")
            print("saved")
        }else{
            for val in self.savedCode{
                
                if(val != respModel?.code){
                    sender.tintColor = .black
                    saveCountries(name: name ?? "", code: code ?? "")
                    print("saved")
                
                }else{
                    sender.tintColor = .darkGray
                    self.delete(code: code ?? "")
                    print("deleted")
                   
                }
                
            }
        }
     
    }

    @IBAction func informationButtonTapped(_ sender: Any) {

        var wikiCode = respModel?.wikiDataID

        guard let wikiCodeOptional = wikiCode else { return }

        self.showWiki(wikiCodeOptional)
    }

}
