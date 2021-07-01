//
//  ViewController.swift
//  n-eczane
//
//  Created by Enes Bilaloğulları on 14.06.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var distArray = [String]()
    var addressArray = [String]()
    var phoneArray = [String]()
    var locArray = [String]()
    @IBOutlet weak var currDate: UILabel!
    
    var il: String = "Edirne"
    
    @IBOutlet weak var txtSehir: UITextField!
    @IBOutlet weak var btnGetir: UIButton!
    
    @IBAction func btnSearchButton(_ sender: Any) {
        if txtSehir.text?.isEmpty != true {
            il.removeAll()
            il = txtSehir.text!.lowercased()
            title = "\(il) Nöbetçi Eczaneler".capitalized
            
            print("btn \(il)")
            txtSehir.text = ""
            
            nameArray.removeAll()
            distArray.removeAll()
            addressArray.removeAll()
            phoneArray.removeAll()
            locArray.removeAll()
            tableView.reloadData()
            
            getJsonUrl()
        }
        
        else{
            let alert = UIAlertController(title: "Uyarı!", message: "Lütfen bir şehir adı giriniz.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { (action: UIAlertAction!) in
                  print("uyari kapatıldı")
            }))

            present(alert, animated: true, completion: nil)
        }
        
        var il: String = "Edirne"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        formatter.timeZone = TimeZone(abbreviation: "UTC+3")!
        formatter.locale = Locale(identifier: "tr-TR")
        
        let utcTimeZoneStr = formatter.string(from: date)
        print("geçerli tarih: \(utcTimeZoneStr)")
        
        currDate.text = "\(utcTimeZoneStr) tarihi için nönetçi eczaneler"
        
        title = "\(il.capitalized) Nöbetçi Eczaneler".capitalized
        print("viewdidload \(il)")
        
        btnGetir.backgroundColor = .systemBlue
        btnGetir.layer.cornerRadius = 5
        btnGetir.tintColor = .white
        
        getJsonUrl()
    }
    
    func getJsonUrl() {
        print("getJsonUrl fonksiyonu çalıştı...")
        
        let headers = [
            "content-type": "application/json",
            "authorization": "apikey 5gyLhZBpLq69c6wp7O6PGb:7A1CBSyOom7sGrGIfRVas6"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.collectapi.com/health/dutyPharmacy?il=\(il)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        
        print("session başlatıldı...")
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            }
            else {
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    //print(jsonResponse!["result"])
                    
                    if let eczaArray = jsonResponse!.value(forKey: "result") as? NSArray {
                        for ecza in eczaArray{
                            if let eczaDict = ecza as? NSDictionary {
                                if let name = eczaDict.value(forKey: "name") {
                                    self.nameArray.append(name as! String)
                                }
                                if let name = eczaDict.value(forKey: "dist") {
                                    self.distArray.append(name as! String)
                                }
                                if let name = eczaDict.value(forKey: "address") {
                                    self.addressArray.append(name as! String)
                                }
                                if let name = eczaDict.value(forKey: "phone") {
                                    self.phoneArray.append(name as! String)
                                }
                                if let name = eczaDict.value(forKey: "loc") {
                                    self.locArray.append(name as! String)
                                }
                            }
                        }
                    }
                    
                    OperationQueue.main.addOperation({
                        self.tableView.reloadData()
                    })
                    
                }
                catch {
                    print("do try catch hatası")
                }
            }
        })
        dataTask.resume()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        cell.lblName.text = nameArray[indexPath.row].uppercased()
        
        if cell.lblName.text!.hasSuffix("Sİ") || cell.lblName.text!.hasSuffix("SI")  == true {
            print("including the word")
        }
        else{
            cell.lblName.text!.append(" ECZANESİ")
        }
        
        cell.lblDist.text = distArray[indexPath.row].capitalized
        cell.lblAddress.text = addressArray[indexPath.row].capitalized
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.nameString = nameArray[indexPath.row]
        detailVC.distString = distArray[indexPath.row]
        detailVC.addressString = addressArray[indexPath.row]
        detailVC.phoneString = phoneArray[indexPath.row]
        detailVC.locString = locArray[indexPath.row]
        
//      self.navigationController?.pushViewController(detailVC, animated: true)
        
        let navController = UINavigationController(rootViewController: detailVC)
        self.present(navController, animated:true, completion: nil)
    }
}
