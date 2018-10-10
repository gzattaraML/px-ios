//
//  PXResultAddCardSuccessViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Diego Flores Domenech on 24/9/18.
//

import UIKit

final class PXResultAddCardSuccessViewModel: PXResultViewModelInterface {
    
    let buttonCallback: () -> ()
    
    init(buttonCallback: @escaping () -> ()) {
        self.buttonCallback = buttonCallback
    }
    
    func getPaymentData() -> PXPaymentData {
        return PXPaymentData()
    }
    
    func primaryResultColor() -> UIColor {
        return ThemeManager.shared.successColor()
    }
    
    func setCallback(callback: @escaping (PaymentResult.CongratsState) -> Void) {
        
    }
    
    func getPaymentStatus() -> String {
        return ""
    }
    
    func getPaymentStatusDetail() -> String {
        return ""
    }
    
    func getPaymentId() -> String? {
        return nil
    }
    
    func isCallForAuth() -> Bool {
        return false
    }
    
    func buildHeaderComponent() -> PXHeaderComponent {
        let props = PXHeaderProps(labelText: nil, title: NSAttributedString(string: "add_card_congrats_title".localized_beta, attributes: [NSAttributedStringKey.font: UIFont.ml_regularSystemFont(ofSize: 26)]), backgroundColor: ThemeManager.shared.successColor(), productImage: UIImage(named: "card_icon", in: ResourceManager.shared.getBundle(), compatibleWith: nil), statusImage: UIImage(named: "ok_badge", in: ResourceManager.shared.getBundle(), compatibleWith: nil))
        let header = PXHeaderComponent(props: props)
        return header
    }
    
    func buildFooterComponent() -> PXFooterComponent {
        let buttonAction = PXAction(label: "add_card_go_to_my_cards".localized_beta, action: self.buttonCallback)
        let props = PXFooterProps(buttonAction: buttonAction, linkAction: nil, primaryColor: UIColor.ml_meli_blue(), animationDelegate: nil)
        let footer = PXFooterComponent(props: props)
        return footer
    }
    
    func buildReceiptComponent() -> PXReceiptComponent? {
        return nil
    }
    
    func buildBodyComponent() -> PXComponentizable? {
        return nil
    }
    
    func buildTopCustomView() -> UIView? {
        return nil
    }
    
    func buildBottomCustomView() -> UIView? {
        return nil
    }
    
    func trackInfo() {
        
    }

}
