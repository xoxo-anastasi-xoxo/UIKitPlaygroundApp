//
//  DispatchGroupViewController.swift
//  UIKitPlaygroundApp
//
//  Created by Anastasia Kazantseva on 04.04.2024.
//

import UIKit

class DispatchGroupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let stack = UIStackView(arrangedSubviews: [loadButton, loadAllButton, cleanButton])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = ColorPalette4384.dirtyGreen.withAlphaComponent(0.8)

        [imageView1, imageView2, imageView3, imageView4, stack].forEach {
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView1.topAnchor.constraint(equalTo: view.topAnchor),
            imageView1.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            imageView2.topAnchor.constraint(equalTo: view.topAnchor),
            imageView2.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            imageView3.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView3.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView3.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            imageView4.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView4.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView4.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView4.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: 150)

        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        loadButton.addTarget(self, action: #selector(load), for: .touchUpInside)
        loadAllButton.addTarget(self, action: #selector(loadAll), for: .touchUpInside)
        cleanButton.addTarget(self, action: #selector(clean), for: .touchUpInside)
    }

    private let images = [
        BigImages.whale,
        BigImages.shark,
        BigImages.seaLion,
        BigImages.whale
    ]
    private let dispatchGroup = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 1)

    private let imageView1 = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorPalette4384.dirtyGreenLight
        return view
    }()
    private let imageView2 = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorPalette4384.pinkLight
        return view
    }()
    private let imageView3 = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorPalette4384.coral
        return view
    }()
    private let imageView4 = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorPalette4384.coralBright
        return view
    }()

    private var loadButton = {
        let view = UIButton()
        view.setTitle("Load", for: .normal)
        return view
    }()
    private var loadAllButton = {
        let view = UIButton()
        view.setTitle("Load All", for: .normal)
        return view
    }()
    private var cleanButton = {
        let view = UIButton()
        view.setTitle("Clean", for: .normal)
        return view
    }()

    @objc private func load() {
        for index in 0..<images.count {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard
                    let self,
                    let url = URL(string: self.images[index].rawValue),
                    let imgData = try? Data(contentsOf: url, options: .uncached)
                else { return }

                let image = UIImage(data: imgData)

                DispatchQueue.main.async {
                    switch index {
                    case 0:
                        self.imageView1.image = image
                    case 1:
                        self.imageView2.image = image
                    case 2:
                        self.imageView3.image = image
                    default:
                        self.imageView4.image = image
                    }
                }
            }
        }
    }
    @objc private func loadAll() {
        var loadedImages: [UIImage?] = Array(repeating: nil, count: images.count)
        for index in 0..<images.count {
            DispatchQueue.global(qos: .utility).async(group: dispatchGroup) { [weak self] in
                print("\(index) Start loading...")
                guard
                    let self,
                    let url = URL(string: self.images[index].rawValue),
                    let imgData = try? Data(contentsOf: url, options: .uncached)
                else { return }

                print("\(index) Finish loading...")

                semaphore.wait()
                print("\(index) Start setting result...")
                loadedImages[index] = UIImage(data: imgData)
                print("\(index) Finish setting result...")
                semaphore.signal()
            }
        }
        dispatchGroup.notify(queue: .main) {
            for index in 0..<loadedImages.count {
                switch index {
                case 0:
                    self.imageView1.image = loadedImages[index]
                case 1:
                    self.imageView2.image = loadedImages[index]
                case 2:
                    self.imageView3.image = loadedImages[index]
                default:
                    self.imageView4.image = loadedImages[index]
                }
            }
        }
    }
    @objc private func clean() {
        [imageView1, imageView2, imageView3, imageView4].forEach {
            $0.image = nil
        }
    }

}
