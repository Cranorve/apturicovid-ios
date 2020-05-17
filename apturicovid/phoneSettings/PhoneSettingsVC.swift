import UIKit
import SVProgressHUD

class PhoneSettingsVC: BaseViewController {
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var nextButton: RoundedButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let phoneView = PhoneSetupView().fromNib() as! PhoneSetupView
    
    @IBAction func onBackTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNextButtonTap(_ sender: Any) {
        SVProgressHUD.show()
        RestClient.shared.requestPhoneVerification(phoneNumber: phoneView.getPhoneNumber().number)
            .subscribe(onNext: { (response) in
                SVProgressHUD.dismiss()
                if let response = response {
                    DispatchQueue.main.async {
                        guard let vc = UIStoryboard(name: "CodeEntry", bundle: nil).instantiateInitialViewController() as? CodeEntryVC else { return }
                        vc.requestResponse = response
                        vc.phoneNumber = self.phoneView.getPhoneNumber()
                        vc.mode = .sms
                        vc.presentedFromSettings = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }, onError: { error in
                SVProgressHUD.dismiss()
                justPrintError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func deletePhoneAndClose() {
        LocalStore.shared.phoneNumber = nil
        navigationController?.popViewController(animated: true)
    }
    
    private func presentAnonymousPrompt() {
        let alert = UIAlertController(title: "anonymous_prompt_title".translated, message: "anonymous_prompt_description".translated, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "remain_anonymous".translated, style: .default, handler: { (_) in
            self.deletePhoneAndClose()
        }))
        alert.addAction(UIAlertAction(title: "cancel".translated, style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        
        mainStackView.addArrangedSubview(phoneView)
        
        if let phone = LocalStore.shared.phoneNumber {
            phoneView.fill(with: phone)
        }
        
        phoneView
            .anonymousTapObservable
            .subscribe(onNext: { (_) in
                self.presentAnonymousPrompt()
            })
            .disposed(by: disposeBag)
        
        phoneView
            .phoneValidObservable
            .subscribe(onNext: { (valid) in
                self.nextButton.isEnabled = valid
            })
            .disposed(by: disposeBag)
        
        phoneView
            .phoneInfoTapObservable
            .subscribe(onNext: { _ in
                guard let vc = self.storyboard?.instantiateViewController(identifier: "PhoneInfoVC") else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let keyboardFrame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                
                self.bottomConstraint.constant = keyboardFrame.height - 15
                
                }, onError: justPrintError)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidHideNotification)
            .subscribe(onNext: { [weak self] (_) in
                self?.bottomConstraint.constant = 30
                }, onError: justPrintError)
            .disposed(by: disposeBag)
    }
}