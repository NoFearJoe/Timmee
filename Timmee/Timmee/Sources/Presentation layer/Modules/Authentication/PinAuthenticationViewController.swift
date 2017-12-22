//
//  PinAuthenticationViewController.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import Foundation
import class UIKit.UILabel
import class UIKit.UIDevice
import enum UIKit.UIStatusBarStyle
import class UIKit.UICollectionView
import class UIKit.UIViewController
import struct LocalAuthentication.LAError
import class LocalAuthentication.LAContext

final class PinAuthenticationViewController: UIViewController {
    
    @IBOutlet fileprivate var messageLabel: UILabel!
    @IBOutlet fileprivate var pinCodeView: PinCodeView!
    @IBOutlet fileprivate var numberPadView: UICollectionView!
    
    fileprivate let numberPadAdapter = NumberPadAdapter()
    
    fileprivate var enteredPinCode: [Int] = []
    
    fileprivate lazy var padItems: [NumberPadItem] = {
        var items = [NumberPadItem]()
        
        (1...9).forEach { items.append(NumberPadItem(kind: .number(value: $0))) }
        
        items.append(NumberPadItem(kind: .clear))
        items.append(NumberPadItem(kind: .number(value: 0)))
        
        if UserProperty.biometricsAuthenticationEnabled.bool() {
            items.append(NumberPadItem(kind: .biometrics))
        }
        
        return items
    }()
    
    fileprivate lazy var biometricsType: BiometricsType = {
        return UIDevice.current.biometricsType
    }()
    
    fileprivate lazy var localAuthenticationContext = LAContext()
    
    var pinCodeLength: Int = 4
    
    var onComplete: (() -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinCodeView.pinCodeLength = pinCodeLength
        
        numberPadAdapter.items = padItems
        numberPadAdapter.output = self
        
        numberPadView.delegate = numberPadAdapter
        numberPadView.dataSource = numberPadAdapter
        
        showMessage("enter_password".localized)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        showBiometricsAuthenticationIfPossible()
    }
    
}

extension PinAuthenticationViewController: NumberPadAdapterOutput {
    
    func didSelectItem(with kind: NumberPadItem.Kind) {
        switch kind {
        case .number(let value):
            guard enteredPinCode.count < pinCodeLength else { return }
            enteredPinCode.append(value)
            pinCodeView.fillNext()
            validatePinCode(enteredPinCode)
        case .clear:
            if enteredPinCode.count == pinCodeLength || enteredPinCode.count == 0 {
                enteredPinCode.removeAll()
                pinCodeView.clear()
                showMessage("enter_password".localized)
            } else {
                enteredPinCode.removeLast()
                pinCodeView.removeLast()
            }
        case .biometrics:
            showBiometricsAuthenticationIfPossible()
        case .cancel: break
        }
    }
    
}

fileprivate extension PinAuthenticationViewController {
    
    func validatePinCode(_ pinCode: [Int]) {
        guard pinCode.count == pinCodeLength else { return }
        
        let pinCodeHash = pinCode.reduce("") { $0.0 + String($0.1) }.sha256()
        let validPinCodeHash = getValidPinCodeHash()
        
        if pinCodeHash == validPinCodeHash {
            pinCodeView.showPinCodeRight()
            closeAuthorization()
        } else {
            showMessage("wrong_password".localized)
            pinCodeView.showPinCodeWrong()
        }
    }
    
    func getValidPinCodeHash() -> String {
        return UserProperty.pinCode.string()
    }
    
}

fileprivate extension PinAuthenticationViewController {
    
    func showMessage(_ text: String) {
        messageLabel.text = text
        messageLabel.isHidden = false
    }
    
    func hideMessage() {
        messageLabel.isHidden = true
    }
    
    func closeAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.onComplete?()
        }
    }
    
}

fileprivate extension PinAuthenticationViewController {
    
    func showBiometricsAuthenticationIfPossible() {
        if UserProperty.biometricsAuthenticationEnabled.bool(), isBiometricsAuthenticationAvailable {
            showBiometricsAuthenticationAlert()
        }
    }
    
    func showBiometricsAuthenticationAlert() {
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                  localizedReason: biometricsType.localizedReason)
        { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.pinCodeView.showPinCodeRight()
                    self.closeAuthorization()
                } else if let error = error as? LAError, error.code == LAError.authenticationFailed {
                    self.showMessage("wrong_password".localized)
                    self.pinCodeView.showPinCodeWrong()
                }
            }
        }
    }
    
    var isBiometricsAuthenticationAvailable: Bool {
        return localAuthenticationContext
            .canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               error: nil)
    }
    
}

fileprivate extension PinAuthenticationViewController {

    func setupAppearance() {
        navigationController?.navigationBar.barTintColor = AppTheme.current.backgroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.backgroundTintColor
        
        view.backgroundColor = AppTheme.current.backgroundColor
        messageLabel.textColor = AppTheme.current.backgroundTintColor
        
        pinCodeView.emptyDotColor = AppTheme.current.secondaryBackgroundTintColor
        pinCodeView.filledDotColor = AppTheme.current.backgroundTintColor
        pinCodeView.wrongPinCodeDotColor = AppTheme.current.redColor
        pinCodeView.rightPinCodeDotColor = AppTheme.current.greenColor
    }

}
