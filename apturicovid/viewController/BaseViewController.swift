import UIKit
import RxSwift

class BaseViewController: UIViewController {
    private var notificationDisposable: Disposable?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationDisposable = NotificationCenter.default.rx
            .notification(.languageDidChange).subscribe(onNext: { [weak self] (_) in
            self?.translate()
        }, onError: justPrintError)
        overrideUserInterfaceStyle = .light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        translate()
    }
    
    func translate() {
        // override this to translate VC labels
    }
    
    func showBasicAlert(message: String) {
        DispatchQueue.main.async {
            if let statusBarNotification = UIStoryboard(name: "StatusBarNotification", bundle: nil).instantiateInitialViewController() as? StatusBarNotification {
                statusBarNotification.text = message
                self.showSlideViewController(slideVC: statusBarNotification, direction: .top)
            }
        }
    }
    
    func showSlideViewController(slideVC: SlideViewController, direction: SlideControllerDirection) {
        self.view.addSubview(slideVC.view)
        self.addChild(slideVC)
        slideVC.view.layoutIfNeeded()
        
        let horizontal = direction == .left || direction == .right
        let vertical = direction == .top || direction == .bottom
        
        let hotizontalMultiplier: CGFloat = (direction == .left) ? -1 : 1
        let verticalMultiplier: CGFloat = (direction == .top) ? -1 : 1
        
        let screenSize = UIScreen.main.bounds.size
        let horizontalPoint = horizontal ? screenSize.width * hotizontalMultiplier : 0.0
        let verticalPoint = vertical ? screenSize.height * verticalMultiplier : 0.0
        
        slideVC.view.frame = CGRect(x: horizontalPoint, y: verticalPoint, width: screenSize.width, height: screenSize.height)
        
        if direction != .top { view.endEditing(true) }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            slideVC.view.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        })
    }
}
