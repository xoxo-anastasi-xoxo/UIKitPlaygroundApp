//
//  ViewController.swift
//  UIKitPlaygroundApp
//
//  Created by Anastasia Kazantseva on 30.03.2024.
//

import UIKit

// MARK: - ViewController

class GCDImageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(photoView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        syncButton.addAction(UIAction { [weak self] _ in self?.synchronousDownload() }, for: .touchUpInside)
        stack.addArrangedSubview(syncButton)
        asyncButton.addAction(UIAction { [weak self] _ in self?.simpleAsynchronousDownload() }, for: .touchUpInside)
        stack.addArrangedSubview(asyncButton)
        asyncAdvancedButton.addAction(UIAction { [weak self] _ in self?.asynchronousDownload() }, for: .touchUpInside)
        stack.addArrangedSubview(asyncAdvancedButton)
        cleanButton.addAction(UIAction { [weak self] _ in self?.clean() }, for: .touchUpInside)
        stack.addArrangedSubview(cleanButton)

        view.addSubview(sliderView)
        sliderView.addTarget(self, action: #selector(setTransparencyOfImage(sender:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalTo: view.widthAnchor),
            photoView.heightAnchor.constraint(equalTo: view.heightAnchor),
            photoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            photoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stack.widthAnchor.constraint(equalTo: view.widthAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            sliderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            sliderView.heightAnchor.constraint(equalToConstant: 50),
            sliderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sliderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - ViewController: private

    private var photoView = {
        let view = UIImageView()
        view.backgroundColor = .purple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var sliderView = {
        let view = UISlider()
        view.value = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var syncButton = {
        let view = UIButton()
        view.setTitle("Sync", for: .normal)
        return view
    }()
    private var asyncButton = {
        let view = UIButton()
        view.setTitle("Async Simple", for: .normal)
        return view
    }()
    private var asyncAdvancedButton = {
        let view = UIButton()
        view.setTitle("Async Advanced", for: .normal)
        return view
    }()
    private var cleanButton = {
        let view = UIButton()
        view.setTitle("Clean", for: .normal)
        return view
    }()

    @objc func setTransparencyOfImage(sender: UISlider) {
        photoView.alpha = CGFloat(sender.value)
    }

    // this method downloads a huge image, blocking the main queue and the UI
    // (for instructional purposes only, never do this in a production app)
    @objc private func synchronousDownload() {

        // use url to get the data for the image
        if let url = URL(string: BigImages.palm.rawValue), let imgData = try? Data(contentsOf: url, options: .uncached) {
            // turn data into an image
            let image = UIImage(data: imgData)

            // display it
            self.photoView.image = image
        }
    }

    // this method avoids blocking by creating a background queue, without blocking the UI
    @objc private func simpleAsynchronousDownload() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: BigImages.building.rawValue), let imgData = try? Data(contentsOf: url, options: .uncached) {
                // turn data into an image
                let image = UIImage(data: imgData)

                DispatchQueue.main.async {
                    // display it
                    self.photoView.image = image
                }
            }
        }
    }

    @objc private func asynchronousDownload() {
        withBigImage { image in
            // all set and done, run the completion closure!
            DispatchQueue.main.async(execute: { () -> Void in
                self.photoView.image = image
            })
        }
    }

    // This code downloads the huge image in a global queue and uses a completion closure.
    func withBigImage(completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in

            if let url = URL(string: BigImages.city.rawValue), let imgData = try? Data(contentsOf: url, options: .uncached), let img = UIImage(data: imgData) {

                handler(img)
            }
        }
    }

    @objc private func clean() {
        self.photoView.image = nil
    }
}

