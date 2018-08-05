
import UIKit

class StoreItemListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    // add item controller property
    var storeItemController = StoreItemController()
    
    var items = [StoreItem]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchMatchingItems() {
        
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            let query: [String: String] = [
                "term": searchTerm,
                "media": mediaType,
                "limit": "50",
                "lang": "en_us"
            ]
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            storeItemController.fetchItems(matching: query) { (items) in
                if let items = items {
                    DispatchQueue.main.async {
                        self.items = items
                        self.tableView.reloadData()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.artist
        cell.imageView?.image = UIImage(named: "gray")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let url = item.imageURL {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            task.resume()
        }
        
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}
