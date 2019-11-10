import UIKit

extension UIAlertController {

    /// Add Locale Picker
    ///
    /// - Parameters:
    ///   - type: country, phoneCode or currency
    ///   - action: for selected locale
    
    func addLocalePicker(type: LocalePickerViewController.Kind, selection: @escaping LocalePickerViewController.Selection) {
        var info: Status?
        let selection: LocalePickerViewController.Selection = selection
        let buttonSelect: UIAlertAction = UIAlertAction(title: "Search", style: .default) { action in
            selection(info)
        }
        buttonSelect.isEnabled = false
        
        let vc = LocalePickerViewController(type: type) { new in
            info = new
            buttonSelect.isEnabled = new != nil
        }
        set(vc: vc)
//        addAction(buttonSelect)
    }
}

final class LocalePickerViewController: UIViewController {
    
    // MARK: UI Metrics
    
    struct UI {
        static let rowHeight = CGFloat(UITableView.automaticDimension)
        static let separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
    }
    
    // MARK: Properties
    
    public typealias Selection = (Status?) -> Swift.Void
    
    public enum Kind {
        case country
        case phoneCode
        case currency
    }
    
    fileprivate var type: Kind
    fileprivate var selection: Selection?
    
    fileprivate var orderedInfo = [String: [LocaleInfo]]()
    fileprivate var sortedInfoKeys = [String]()
    fileprivate var filteredInfo: [Status] = []
    fileprivate var selectedInfo: LocaleInfo?
    
    //fileprivate var searchBarIsActive: Bool = false
    
    fileprivate lazy var searchView: UIView = UIView()
    
    fileprivate lazy var searchController: UISearchController = { [unowned self] in
        $0.searchResultsUpdater = self
        $0.searchBar.delegate = self
        $0.dimsBackgroundDuringPresentation = false
        /// true if search bar in tableView header
        $0.hidesNavigationBarDuringPresentation = true
        $0.searchBar.searchBarStyle = .minimal
        $0.searchBar.textField?.textColor = UIColor(named: "baseBlack")!
        $0.searchBar.textField?.clearButtonMode = .whileEditing
        return $0
    }(UISearchController(searchResultsController: nil))
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorColor = UI.separatorColor
        $0.bounces = true
        $0.backgroundColor = nil
        $0.tableFooterView = UIView()
        $0.sectionIndexBackgroundColor = .clear
        $0.sectionIndexTrackingBackgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(style: .whiteLarge))
    
    // MARK: Initialize
    
    required init(type: Kind, selection: @escaping Selection) {
        self.type = type
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // http://stackoverflow.com/questions/32675001/uisearchcontroller-warning-attempting-to-load-the-view-of-a-view-controller/
        let _ = searchController.view
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicatorView)
        
        searchView.addSubview(searchController.searchBar)
        tableView.tableHeaderView = searchView
        
        //extendedLayoutIncludesOpaqueBars = true
        //edgesForExtendedLayout = .bottom
        definesPresentationContext = true
        tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        
        updateInfo()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 57
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
        preferredContentSize.height = tableView.contentSize.height
    }
    
    func updateInfo() {
        indicatorView.startAnimating()
        
        LocaleStore.fetch { [unowned self] result in
            switch result {
                
            case .success(let orderedInfo):
                let data: [String: [LocaleInfo]] = orderedInfo
                /*
                 switch self.type {
                 case .currency:
                 data = data.filter { i in
                 guard let code = i.currencyCode else { return false }
                 return Locale.commonISOCurrencyCodes.contains(code)
                 }.sorted { $0.currencyCode < $1.currencyCode }
                 default: break }
                 */
                
                self.orderedInfo = data
                self.sortedInfoKeys = Array(self.orderedInfo.keys).sorted(by: <)
                
                DispatchQueue.main.async {
                    self.indicatorView.stopAnimating()
                    self.tableView.reloadData()
                }
                
            case .error(let error):
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(style: .alert, title: error.title, message: error.message)
                    alert.addAction(title: "OK", style: .cancel) { action in
                        self.indicatorView.stopAnimating()
                        self.alertController?.dismiss(animated: true)
                    }
                    alert.show()
                }
            }
        }
    }
    
//    func info(at indexPath: IndexPath) -> LocaleInfo? {
//        if searchController.isActive {
//            return filteredInfo[indexPath.row]
//        }
//        let key: String = sortedInfoKeys[indexPath.section]
//        if let info = orderedInfo[key]?[indexPath.row] {
//            return info
//        }
//        return nil
//    }
    
    func indexPathOfSelectedInfo() -> IndexPath? {
        guard let selectedInfo = selectedInfo else { return nil }
        if searchController.isActive {
            for row in 0 ..< filteredInfo.count {
                if filteredInfo[row].id == selectedInfo.id {
                    return IndexPath(row: row, section: 0)
                }
            }
        }
        for section in 0 ..< sortedInfoKeys.count {
            if let orderedInfo = orderedInfo[sortedInfoKeys[section]] {
                for row in 0 ..< orderedInfo.count {
                    if orderedInfo[row].id == selectedInfo.id {
                        return IndexPath(row: row, section: section)
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - UISearchResultsUpdating

extension LocalePickerViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchController.isActive {
//            filteredInfo = []
            let request = Timelines.tag(searchText)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        GlobalStruct.statusSearch = stat
                        if searchText.count > 0 {
                            self.filteredInfo = stat
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        tableView.reloadData()
        
        guard let selectedIndexPath = indexPathOfSelectedInfo() else { return }
        Log("selectedIndexPath = \(selectedIndexPath)")
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
}

// MARK: - UISearchBarDelegate

extension LocalePickerViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

    }
}

// MARK: - TableViewDelegate

extension LocalePickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selection = self.filteredInfo[indexPath.row]
    }
}

// MARK: - TableViewDataSource

extension LocalePickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive { return 1 }
        return sortedInfoKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive { return filteredInfo.count }
//        if let infoForSection = orderedInfo[sortedInfoKeys[section]] {
//            return infoForSection.count
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top , animated: false)
        return sortedInfoKeys.index(of: title)!
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive { return nil }
        return sortedInfoKeys
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive { return nil }
        return sortedInfoKeys[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
        if self.filteredInfo.isEmpty {
            
        } else {
            cell.configure(self.filteredInfo[indexPath.row])
        }
        return cell
    }
}
