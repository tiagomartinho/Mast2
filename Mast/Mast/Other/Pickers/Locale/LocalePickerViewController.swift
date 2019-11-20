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
    
    fileprivate var whichSegment: Int = 0
    fileprivate var type: Kind
    fileprivate var selection: Selection?
    
    fileprivate var orderedInfo = [String: [LocaleInfo]]()
    fileprivate var sortedInfoKeys = [String]()
    fileprivate var filteredInfo: [Status] = []
    fileprivate var filteredInfo2: [Account] = []
    fileprivate var selectedInfo: LocaleInfo?
    
    fileprivate let segment: UISegmentedControl = UISegmentedControl(items: ["Toots".localized, "Users".localized])
    
    fileprivate lazy var searchView: UIView = UIView()
    
    fileprivate lazy var searchController: UISearchController = { [unowned self] in
        $0.searchBar.backgroundColor = UIColor(named: "baseWhite")!
        $0.searchResultsUpdater = self
        $0.searchBar.delegate = self
        $0.searchBar.showsCancelButton = false
        $0.dimsBackgroundDuringPresentation = true
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
        definesPresentationContext = true
        tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        tableView.register(MuteBlockCell.self, forCellReuseIdentifier: "MuteBlockCell")
        
        self.segment.selectedSegmentIndex = 0
        self.segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        
        updateInfo()
        
        delay(0.5) { self.searchController.searchBar.becomeFirstResponder() }
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 57
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
        self.segment.frame = CGRect(x: 15, y: 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
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
    
    func indexPathOfSelectedInfo() -> IndexPath? {
        if self.whichSegment == 0 {
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
        } else {
            guard let selectedInfo = selectedInfo else { return nil }
            if searchController.isActive {
                for row in 0 ..< filteredInfo2.count {
                    if filteredInfo2[row].id == selectedInfo.id {
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
}

// MARK: - UISearchResultsUpdating

extension LocalePickerViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchController.isActive {
            if searchText == "" {
                self.filteredInfo = []
                self.filteredInfo2 = []
                self.tableView.reloadData()
            }
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
            let request2 = Accounts.search(query: searchText)
            GlobalStruct.client.run(request2) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        GlobalStruct.statusSearch2 = stat
                        if searchText.count > 0 {
                            self.filteredInfo2 = stat
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
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
        self.filteredInfo = []
        self.filteredInfo2 = []
        self.tableView.reloadData()
    }
}

// MARK: - TableViewDelegate

extension LocalePickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "rightAr"), object: self)
        if self.whichSegment == 0 {
            let selection = self.filteredInfo[indexPath.row]
            GlobalStruct.statusSearched = [selection]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewSearchDetail"), object: self)
            self.indicatorView.stopAnimating()
            self.alertController?.dismiss(animated: true)
        } else {
            let selection = self.filteredInfo2[indexPath.row]
            GlobalStruct.statusSearched2 = [selection]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewSearchDetail2"), object: self)
            self.indicatorView.stopAnimating()
            self.alertController?.dismiss(animated: true)
        }
    }
}

// MARK: - TableViewDataSource

extension LocalePickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive { return 1 }
        return sortedInfoKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.whichSegment == 0 {
            if searchController.isActive { return filteredInfo.count }
        } else {
            if searchController.isActive { return filteredInfo2.count }
        }
        return 0
    }
    
    @objc func changeSegment(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.whichSegment = 0
            self.tableView.reloadData()
        }
        if segment.selectedSegmentIndex == 1 {
            self.whichSegment = 1
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = GlobalStruct.baseDarkTint
        vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45)
        vw.addSubview(self.segment)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.filteredInfo.isEmpty {
            return 0
        } else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.whichSegment == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            if self.filteredInfo.isEmpty {
                
            } else {
                cell.configure(self.filteredInfo[indexPath.row])
            }
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuteBlockCell", for: indexPath) as! MuteBlockCell
            if self.filteredInfo2.isEmpty {

            } else {
                cell.configure(self.filteredInfo2[indexPath.row])
            }
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        }
    }
}
