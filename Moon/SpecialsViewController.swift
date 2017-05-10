//
//  SpecialsViewController.swift
//  
//
//  Created by Evan Noble on 5/10/17.
//
//

import UIKit

class SpecialsViewController: UIViewController {
    
    let specialCellIdenifier = "SpecialCell"
    
    class func instantiateFromStoryboard() -> SpecialsViewController {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        // swiftlint:disable:next force_cast
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! SpecialsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SpecialsViewController: UITableViewDelegate {
    
}

extension SpecialsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: specialCellIdenifier, for: indexPath)
        return cell
    }
}
