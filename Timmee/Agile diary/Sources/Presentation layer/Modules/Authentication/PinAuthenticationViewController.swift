//
//  PinAuthenticationViewController.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import Foundation
import UIComponents
import class UIKit.UILabel
import class UIKit.UIDevice
import enum UIKit.UIStatusBarStyle
import class UIKit.UICollectionView
import class UIKit.UIViewController
import struct LocalAuthentication.LAError
import class LocalAuthentication.LAContext

final class PinAuthenticationViewController: BaseViewController {
    
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var pinCodeView: PinCodeView!
    @IBOutlet private var numberPadView: UICollectionView!
    
    private let numberPadAdapter = NumberPadAdapter()
    
    private var enteredPinCode: [Int] = []
    
    private var isBiometricsAlertShown: Bool = false
    
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
    
    override func prepare() {
        super.prepare()
        
        pinCodeView.pinCodeLength = pinCodeLength
        
        numberPadAdapter.items = padItems
        numberPadAdapter.output = self
        
        numberPadView.delegate = numberPadAdapter
        numberPadView.dataSource = numberPadAdapter
        
        showMessage("enter_password".localized)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBiometricsAuthenticationIfPossible()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        messageLabel.textColor = AppTheme.current.colors.activeElementColor
        pinCodeView.emptyDotColor = AppTheme.current.colors.inactiveElementColor
        pinCodeView.filledDotColor = AppTheme.current.colors.activeElementColor
        pinCodeView.wrongPinCodeDotColor = AppTheme.current.colors.wrongElementColor
        pinCodeView.rightPinCodeDotColor = AppTheme.current.colors.selectedElementColor
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
        
        let pinCodeHash = pinCode.reduce("") { $0 + String($1) }.sha256()
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

private extension PinAuthenticationViewController {
    
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

private extension PinAuthenticationViewController {
    
    func showBiometricsAuthenticationIfPossible() {
        guard UserProperty.biometricsAuthenticationEnabled.bool(), isBiometricsAuthenticationAvailable, !isBiometricsAlertShown else { return }
        isBiometricsAlertShown = true
        showBiometricsAuthenticationAlert()
    }
    
    func showBiometricsAuthenticationAlert() {
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                  localizedReason: biometricsType.localizedReason)
        { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isBiometricsAlertShown = false
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
