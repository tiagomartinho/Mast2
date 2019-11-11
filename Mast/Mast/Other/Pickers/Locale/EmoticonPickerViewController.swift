import UIKit

extension UIAlertController {

    /// Add Locale Picker
    ///
    /// - Parameters:
    ///   - type: country, phoneCode or currency
    ///   - action: for selected locale
    
    func addEmoticonPicker(type: EmoticonPickerViewController.Kind, selection: @escaping EmoticonPickerViewController.Selection) {
        var info: String?
        let selection: EmoticonPickerViewController.Selection = selection
        let buttonSelect: UIAlertAction = UIAlertAction(title: "Search", style: .default) { action in
            selection(info)
        }
        buttonSelect.isEnabled = false
        
        let vc = EmoticonPickerViewController(type: type) { new in
            info = new
            buttonSelect.isEnabled = new != nil
        }
        set(vc: vc)
//        addAction(buttonSelect)
    }
}

final class EmoticonPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    public typealias Selection = (String?) -> Swift.Void
    
    public enum Kind {
        case country
        case phoneCode
        case currency
    }
    
    fileprivate var type: Kind
    fileprivate var selection: Selection?
    
    fileprivate var orderedInfo = [String: [LocaleInfo]]()
    fileprivate var sortedInfoKeys = [String]()
    fileprivate var selectedInfo: LocaleInfo?
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(style: .whiteLarge))

    fileprivate let layout = ColumnFlowLayout(
        cellsPerRow: 7,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.bounces = true
        $0.backgroundColor = UIColor.clear
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
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
        
    }
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicatorView)
        definesPresentationContext = true
        
//        self.collectionView.frame.size.height = 600
        self.collectionView.register(ImageCell3.self, forCellWithReuseIdentifier: "ImageCell3")
        self.collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.sizeToFit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
        preferredContentSize.height = collectionView.contentSize.height
    }

    //MARK: CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GlobalStruct.allEmoticons.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = 7
        let y = (self.view.bounds.width) - 20
        let z = CGFloat(y)/CGFloat(x)
        return CGSize(width: z - 5, height: z - 5)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell3", for: indexPath) as! ImageCell3
        cell.image.image = nil
        let imageURL = GlobalStruct.allEmoticons[indexPath.row].url
        cell.configure()
        cell.image.sd_setImage(with: imageURL, completed: nil)
        cell.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor(named: "baseGray")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        GlobalStruct.emoticonToAdd = GlobalStruct.allEmoticons[indexPath.row].shortcode
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addEmoji"), object: self)
        self.indicatorView.stopAnimating()
        self.alertController?.dismiss(animated: true)
    }
}
