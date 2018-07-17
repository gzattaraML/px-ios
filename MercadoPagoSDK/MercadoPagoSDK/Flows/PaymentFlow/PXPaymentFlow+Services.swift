//
//  PXPaymentFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
extension PXPaymentFlow {
    func createPaymentWithPlugin(plugin: PXPaymentPluginComponent?) {
        guard let paymentData = model.paymentData, let plugin = plugin else {
            return
        }

        model.paymentPlugin?.didReceive?(pluginStore: PXCheckoutStore.sharedInstance)

        if let createPayment = plugin.createPayment {
            let paymentPluginResult = createPayment(PXCheckoutStore.sharedInstance, self as PXPaymentFlowHandlerProtocol)

            if paymentPluginResult.statusDetail == RejectedStatusDetail.INVALID_ESC && fallo == false {
                paymentErrorHandler?.escError()
                fallo = true
                return
            }

            // TODO: REMOVE mock status detail
            sleep(5)

            let paymentResult = PaymentResult(status: paymentPluginResult.status, statusDetail: RejectedStatusDetail.OTHER_REASON, paymentData: paymentData, payerEmail: nil, paymentId: paymentPluginResult.receiptId, statementDescription: nil)
            model.paymentResult = paymentResult
            executeNextStep()
        } else if let createPaymentForBussinessResult = plugin.createPaymentWithBusinessResult {
            let businessResult = createPaymentForBussinessResult(PXCheckoutStore.sharedInstance, self as PXPaymentFlowHandlerProtocol)
            model.businessResult = businessResult
            executeNextStep()
        } else {
            showErrorScreen(message: "Hubo un error".localized, errorDetails: "", retry: false)
        }
    }

    func createPayment() {
        guard let paymentData = model.paymentData, let checkoutPreference = model.checkoutPreference else {
            return
        }

        var paymentBody: [String: Any]
        if MercadoPagoCheckoutViewModel.servicePreference.isUsingDeafaultPaymentSettings() {
            let mpPayment = MercadoPagoCheckoutViewModel.createMPPayment(preferenceId: checkoutPreference.preferenceId, paymentData: paymentData, binaryMode: model.binaryMode)
            paymentBody = mpPayment.toJSON()
        } else {
            paymentBody = paymentData.toJSON()
        }

        var createPaymentQuery: [String: String]? = [:]
        if let paymentAdditionalInfo = MercadoPagoCheckoutViewModel.servicePreference.getPaymentAddionalInfo() as? [String: String] {
            createPaymentQuery = paymentAdditionalInfo
        } else {
            createPaymentQuery = nil
        }

        model.mercadoPagoServicesAdapter.createPayment(url: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURL(), uri: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURI(), paymentData: paymentBody as NSDictionary, query: createPaymentQuery, callback: { (payment) in
            guard let paymentData = self.model.paymentData else {
                return
            }
            let paymentResult = PaymentResult(payment: payment, paymentData: paymentData)
            self.model.paymentResult = paymentResult
            self.executeNextStep()

        }, failure: { [weak self] (error) in

            let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue)

            // ESC error
            if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_WITH_ESC.rawValue) {
                self?.paymentErrorHandler?.escError()

                // Identification number error
            } else if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_IDENTIFICATION_NUMBER.rawValue) {
                self?.paymentErrorHandler?.identificationError()

            } else {
                self?.showErrorScreen(error: mpError)
            }

        })
    }

    func getInstructions() {
        guard let paymentResult = model.paymentResult else {
            fatalError("Get Instructions - Payment Result does no exist")
        }

        guard let paymentId = paymentResult.paymentId else {
            fatalError("Get Instructions - Payment Id does no exist")
        }

        guard let paymentTypeId = paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId else {
            fatalError("Get Instructions - Payment Method Type Id does no exist")
        }

        model.mercadoPagoServicesAdapter.getInstructions(paymentId: paymentId, paymentTypeId: paymentTypeId, callback: { [weak self] (instructionsInfo) in
            self?.model.instructionsInfo = instructionsInfo
            self?.executeNextStep()

            }, failure: {[weak self] (error) in

                let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTRUCTIONS.rawValue)
                self?.showErrorScreen(error: mpError)

        })
    }
}
