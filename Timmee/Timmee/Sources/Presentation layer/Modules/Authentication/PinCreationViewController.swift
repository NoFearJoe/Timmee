//
//  PinCreationViewController.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import Foundation
import class UIKit.UILabel
import class UIKit.UIBarButtonItem
import class UIKit.UIViewController
import class UIKit.UICollectionView
import enum UIKit.UIStatusBarStyle
import class UIKit.UIStoryboardSegue
import class LocalAuthentication.LAContext

final class PinCreationViewController: UIViewController {
    
    enum PinEnterState {
        case pin1
        case pin2
        case complete
        case failed
    }
    
    @IBOutlet fileprivate var messageLabel: UILabel!
    @IBOutlet fileprivate var pinCodeView: PinCodeView!
    @IBOutlet fileprivate var numberPadView: UICollectionView!
    
    fileprivate let numberPadAdapter = NumberPadAdapter()
    
    fileprivate var enteredPinCode1: [Int] = []
    fileprivate var enteredPinCode2: [Int] = []
    
    fileprivate var pinEnterState = PinEnterState.failed {
        didSet {
            guard pinEnterState != oldValue else { return }
            switch pinEnterState {
            case .pin1:
                pinCodeView.clear()
                enteredPinCode1.removeAll()
                enteredPinCode2.removeAll()
                showMessage("create_password".localized)
            case .pin2:
                pinCodeView.clear()
                enteredPinCode2.removeAll()
                showMessage("repeat_password".localized)
            case .complete:
                UserProperty.pinCode.setString(getPinCodeHash())
                pinCodeView.showPinCodeRight()
                hideMessage()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    self.performCompletion()
                }
            case .failed:
                pinCodeView.showPinCodeWrong()
                showMessage("passwords_are_not_equal".localized)
            }
        }
    }
    
    fileprivate lazy var padItems: [NumberPadItem] = {
        var items = [NumberPadItem]()
        
        (1...9).forEach { items.append(NumberPadItem(kind: .number(value: $0))) }
        
        items.append(NumberPadItem(kind: .clear))
        items.append(NumberPadItem(kind: .number(value: 0)))
        items.append(NumberPadItem(kind: .cancel))
        
        return items
    }()
    
    var pinCodeLength: Int = 4
    
    var onComplete: (() -> Void)?
    
    var isRemovePinCodeButtonVisible: Bool = false {
        didSet {
            if isRemovePinCodeButtonVisible {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "remove".localized, style: .done, target: self, action: #selector(removePinCode))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
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
        
        pinEnterState = .pin1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBiometricsActivation" {
            guard let viewController = segue.destination as? BiometricsActivationController else { return }
            viewController.onComplete = onComplete
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension PinCreationViewController: NumberPadAdapterOutput {
    
    func didSelectItem(with kind: NumberPadItem.Kind) {
        switch kind {
        case .number(let value):
            switch pinEnterState {
            case .pin1:
                guard enteredPinCode1.count < pinCodeLength else { return }
                enteredPinCode1.append(value)
            case .pin2:
                guard enteredPinCode2.count < pinCodeLength else { return }
                enteredPinCode2.append(value)
            default: return
            }
            
            pinCodeView.fillNext()
            updatePinEnterState()
        case .clear:
            switch pinEnterState {
            case .pin1:
                guard enteredPinCode1.count > 0 else { return }
                enteredPinCode1.removeLast()
                pinCodeView.removeLast()
            case .pin2:
                guard enteredPinCode2.count > 0 else { return }
                if enteredPinCode2.count == pinCodeLength {
                    enteredPinCode2.removeAll()
                    pinCodeView.clear()
                    updatePinEnterState()
                } else {
                    enteredPinCode2.removeLast()
                    pinCodeView.removeLast()
                }
            case .failed:
                enteredPinCode2.removeAll()
                pinCodeView.clear()
                updatePinEnterState()
            case .complete: break
            }
        case .cancel:
            UserProperty.pinCode.setValue(nil)
            pinEnterState = .pin1
            pinCodeView.clear()
        case .biometrics: break
        }
    }
    
}

fileprivate extension PinCreationViewController {
    
    func updatePinEnterState() {
        switch (enteredPinCode1.count, enteredPinCode2.count) {
        case (0, 0): pinEnterState = .pin1
        case (pinCodeLength, 0):
            guard pinEnterState != .pin2 else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                self.pinEnterState = .pin2
            }
        case (pinCodeLength, pinCodeLength):
            pinEnterState = arePinCodesEqual() ? .complete : .failed
        default: break
        }
    }
    
    func arePinCodesEqual() -> Bool {
        return enteredPinCode1.count == pinCodeLength
            && enteredPinCode2.count == pinCodeLength
            && enteredPinCode1 == enteredPinCode2
    }
    
    func getPinCodeHash() -> String {
        return enteredPinCode1.reduce("", { $0 + String($1) }).sha256()
    }
    
}

fileprivate extension PinCreationViewController {
    
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
    
    func performCompletion() {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                         error: nil) {
            performSegue(withIdentifier: "ShowBiometricsActivation", sender: nil)
        } else {
            closeAuthorization()
        }
    }
    
    @objc func removePinCode() {
        UserProperty.pinCode.setValue(nil)
        closeAuthorization()
    }
    
}

fileprivate extension PinCreationViewController {
    
    func setupAppearance() {
        navigationController?.navigationBar.barTintColor = AppTheme.current.backgroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.backgroundTintColor
        
        view.backgroundColor = AppTheme.current.backgroundColor
        messageLabel.textColor = AppTheme.current.backgroundTintColor
        
        pinCodeView.emptyDotColor = AppTheme.current.secondaryBackgroundTintColor
        pinCodeView.filledDotColor = AppTheme.current.specialColor
        pinCodeView.wrongPinCodeDotColor = AppTheme.current.redColor
        pinCodeView.rightPinCodeDotColor = AppTheme.current.greenColor
    }
    
}
