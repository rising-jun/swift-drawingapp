//
//  ViewController.swift
//  DrawingApp
//
//  Created by 김동준 on 2022/02/28.
//

import UIKit
import os

class DrawingViewController: UIViewController{
    private let logger = Logger()
    private var plane: PlaneModelManageable?
    private lazy var rectangleAddButton = RectangleAddButton(frame: CGRect(x: view.center.x - 100, y: view.frame.maxY - 144.0, width: 100, height: 100))
    private lazy var imageAddButton = ImageAddButton(frame: CGRect(x: view.center.x, y: view.frame.maxY - 144.0, width: 100, height: 100))
    private var customViews: [AnyHashable: CustomBaseViewSetable] = [:]
    private let notificationCenter = NotificationCenter.default
    private lazy var photoPickerController = UIImagePickerController()
    private var customViewFactory: CustomViewMakeable?
    private lazy var photoPickerDelegate = PhotoPickerDelegate(imageDataSendable: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rectangleAddButton)
        view.addSubview(imageAddButton)
        setRectangleButtonEvent()
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTappedGesture))
        view.addGestureRecognizer(viewTapGesture)
        addInputNotificationObserver()
        addOutputNotificationObserver()
    }
    
    func setRectangleChangeable(plane: PlaneModelManageable, customViewFactory: CustomViewMakeable){
        self.plane = plane
        self.customViewFactory = customViewFactory
    }
    
    private func addInputNotificationObserver(){
        notificationCenter.addObserver(self, selector: #selector(addRectangleViewToSubView), name: Plane.Notification.Event.addedRectangle, object: plane)
        notificationCenter.addObserver(self, selector: #selector(addPhotoViewToSubView), name: Plane.Notification.Event.addedPhoto, object: plane)
        notificationCenter.addObserver(self, selector: #selector(propertyAction), name: PropertySetViewController.Notification.Event.propertyAction, object: nil)
    }
    
    private func addOutputNotificationObserver(){
        notificationCenter.addObserver(self, selector: #selector(rectangleColorChanged), name: Plane.Notification.Event.changedRectangleColor, object: plane)
        notificationCenter.addObserver(self, selector: #selector(customViewAlphaChanged), name: Plane.Notification.Event.updateCustomViewAlpha, object: plane)
    }
    
    @objc private func viewTappedGesture(){
        plane?.deSelectTargetCustomView()
    }
    
    private func setRectangleButtonEvent(){
        rectangleAddButton.addTarget(self, action: #selector(rectangleAddButtonTapped), for: .touchUpInside)
        imageAddButton.addTarget(self, action: #selector(imageAddButtonTapped), for: .touchUpInside)
    }
    
    @objc func rectangleAddButtonTapped(sender: Any){
        plane?.addRandomRectnagleViewModel()
    }
    
    @objc func imageAddButtonTapped(sender: Any){
        setPhotoPickerState()
        present(photoPickerController, animated: true, completion: nil)
    }
    
    private func setPhotoPickerState(){
        photoPickerController.sourceType = .photoLibrary
        photoPickerController.allowsEditing = false
        photoPickerController.delegate = photoPickerDelegate
    }

    @objc private func addRectangleViewToSubView(_ notification: Foundation.Notification){
        guard let rectangleViewModel = notification.userInfo?[Plane.Notification.Key.rectangle] as? RectangleViewModelMutable else {
            return
        }
        guard let customView = customViewFactory?.makeRectangleView(size: rectangleViewModel.getSize(), point: rectangleViewModel.getPoint()) else {
            return
        }
        setRectangleViewColor(customView: customView, rectangleModel: rectangleViewModel)
        setViewAlpha(customView: customView, customViewModel: rectangleViewModel)
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rectangleTappedGesture))
        customView.addGestureRecognizer(viewTapGesture)
        if let rectangle = rectangleViewModel as? Rectangle {
            customViews[rectangle] = customView
        }
        view.addSubview(customView)
    }
    
    func setViewAlpha(customView: CustomBaseViewSetable, customViewModel: CustomViewModelMutable){
        customView.setAlpha(alpha: customViewModel.getAlpha())
    }
    
    func setRectangleViewColor(customView: RectangleViewSetable, rectangleModel: RectangleViewModelMutable){
        customView.setRGBColor(rgb: rectangleModel.getColorRGB())
    }
    
    @objc private func addPhotoViewToSubView(_ notification: Foundation.Notification){
        guard let photoViewModel = notification.userInfo?[Plane.Notification.Key.photo] as? PhotoViewModelMutable else {
            return
        }
        guard let customView = customViewFactory?.makePhotoView(size: photoViewModel.getSize(), point: photoViewModel.getPoint()) else { return }
        customView.setImage(imageData: photoViewModel.getImageData())
        setViewAlpha(customView: customView, customViewModel: photoViewModel)
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoTappedGesture))
        customView.addGestureRecognizer(viewTapGesture)
        if let photo = photoViewModel as? Photo{
            customViews[photo] = customView
        }
        view.addSubview(customView)
    }
    
    @objc func rectangleTappedGesture(sender: UITapGestureRecognizer){
        let touchedPoint = sender.location(in: self.view)
        let viewPoint = ViewPoint(x: Int(touchedPoint.x), y: Int(touchedPoint.y))
        plane?.selectTargetCustomView(point: viewPoint)
    }
    
    @objc func photoTappedGesture(sender: UITapGestureRecognizer){
        let touchedPoint = sender.location(in: self.view)
        let viewPoint = ViewPoint(x: Int(touchedPoint.x), y: Int(touchedPoint.y))
        plane?.selectTargetCustomView(point: viewPoint)
    }
    
    @objc private func rectangleColorChanged(_ notification: Foundation.Notification){
        guard let rectangleViewModel = notification.userInfo?[Plane.Notification.Key.rectangle] as? RectangleViewModelMutable else {
            return
        }
        if let rectangle = rectangleViewModel as? Rectangle{
            guard let rectangleView = customViews[rectangle] as? RectangleView else { return }
            rectangleView.setRGBColor(rgb: rectangleViewModel.getColorRGB())
        }
    }
    
    @objc private func customViewAlphaChanged(_ notification: Foundation.Notification){
        guard let customViewModelMutable = notification.userInfo?[Plane.Notification.Key.customViewModel] as? CustomViewModelMutable else {
            return
        }
        if let customModel = customViewModelMutable as? CustomViewModel{
            customViews[customModel]?.setAlpha(alpha: customViewModelMutable.getAlpha())
        }
    }
    
    private func plusViewAlpha(){
        plane?.plusCustomViewAlpha()
    }
    
    private func minusViewAlpha(){
        plane?.minusCustomViewAlpha()
    }
    
    @objc private func propertyAction(_ notification: Foundation.Notification) {
        guard let action = notification.userInfo?[PropertySetViewController.Notification.Key.action] as? PropertySetViewController.PropertyViewAction else { return }
        switch action{
        case .colorChangedTapped:
            plane?.changeRectangleRandomColor()
        case .alphaPlusTapped:
            plusViewAlpha()
        case .alphaMinusTapped:
            minusViewAlpha()
        }
    }
}
extension DrawingViewController: ImageDataSendable{
    func sendImageData(imageData: Data){
       plane?.addRandomPhotoViewModel(imageData: imageData)
    }
}
protocol ImageDataSendable{
    func sendImageData(imageData: Data)
}
