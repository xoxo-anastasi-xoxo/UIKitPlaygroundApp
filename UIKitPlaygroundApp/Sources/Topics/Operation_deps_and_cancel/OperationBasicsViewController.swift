//
//  OperationBasicsViewController.swift
//  UIKitPlaygroundApp
//
//  Created by Anastasia Kazantseva on 09.04.2024.
//  Goal: to see dependencies and cancelation in action
//

import UIKit

// MARK: ViewController

class OperationBasicsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        for i in 0..<11 {
            for j in 0..<11 {
                view.addSubview(grid[i][j])
                let topConstraint: NSLayoutConstraint
                let leftConstraint: NSLayoutConstraint
                if i == 0 {
                    topConstraint = grid[i][j].topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
                } else {
                    topConstraint = grid[i][j].topAnchor.constraint(equalTo: grid[i - 1][j].bottomAnchor)
                }
                if j == 0 {
                    leftConstraint = grid[i][j].leftAnchor.constraint(equalTo: view.leftAnchor)
                } else {
                    leftConstraint = grid[i][j].leftAnchor.constraint(equalTo: grid[i][j - 1].rightAnchor)
                }
                NSLayoutConstraint.activate([
                    topConstraint,
                    leftConstraint,
                    grid[i][j].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/11),
                    grid[i][j].heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/11)
                ])
            }
        }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        addNewButton(with: "Draw!", for: stack, actionHandler: { [weak self] _ in self?.draw() })
        addNewButton(with: "Draw by 11 blocks!", for: stack, actionHandler: { [weak self] _ in self?.draw(by: 11) })
        addNewButton(with: "Draw by 3 lines!", for: stack, actionHandler: { [weak self] _ in self?.draw2(by: 3) })
        addNewButton(with: "Draw line by line!", for: stack, actionHandler: { [weak self] _ in self?.draw3() })
        addNewButton(with: "Draw contour first!", for: stack, actionHandler: { [weak self] _ in self?.draw4() })
        addNewButton(with: "Draw with real cancellation!", for: stack, actionHandler: { [weak self] _ in self?.draw5() })
        addNewButton(with: "Cancel!", for: stack, actionHandler: { [weak self] _ in self?.cancel() })
        addNewButton(with: "Clear!", for: stack, actionHandler: { [weak self] _ in self?.clear() })

        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalTo: view.widthAnchor),
            stack.topAnchor.constraint(equalTo: grid[grid.count - 1][grid.count - 1].bottomAnchor, constant: 50),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private let colorGrid = [
        [0,0,0,0,0,0,0,0,0,0,0],
        [0,0,2,2,0,0,0,2,2,0,0],
        [0,2,1,1,2,0,2,1,1,2,0],
        [0,2,1,1,1,2,1,1,1,2,0],
        [0,2,1,1,1,1,1,1,1,2,0],
        [0,2,1,1,1,1,1,1,1,2,0],
        [0,0,2,1,1,1,1,1,2,0,0],
        [0,0,0,2,1,1,1,2,0,0,0],
        [0,0,0,0,2,1,2,0,0,0,0],
        [0,0,0,0,0,2,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0]
    ]
    private let queue = OperationQueue()

    private lazy var grid = {
        var result: [[UIView]] = []
        for i in 0..<11 {
            result.append([])
            for j in 0..<11 {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = ColorPalette4384.dirtyGreenLight
                result[i].append(view)
            }
        }
        return result
    }()

    private func addNewButton(
        with title: String,
        for stack: UIStackView,
        actionHandler: @escaping (UIAction) -> Void
    ) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(ColorPalette4384.dirtyGreen, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(button)
        button.addAction(
            UIAction(handler: actionHandler),
            for: .touchUpInside
        )
    }

    private func draw(by maxOperationsCount: Int = -1) {
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = maxOperationsCount
        for i in 0..<11 {
            for j in 0..<11 {
                queue.addOperation {
                    sleep(UInt32(Int.random(in: 1...3)))
                    DispatchQueue.main.sync { [weak self] in
                        guard let self, self.colorGrid[i][j] > 0 else { return }
                        self.grid[i][j].backgroundColor = ColorPalette4384.coral
                    }
                }
            }
        }
    }
    private func draw2(by maxOperationsCount: Int = -1) {
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = maxOperationsCount
        for i in 0..<11 {
            let operation = BlockOperation()
            for j in 0..<11 {
                operation.addExecutionBlock {
                    sleep(UInt32(Int.random(in: 1...3)))
                    DispatchQueue.main.sync { [weak self] in
                        guard let self, self.colorGrid[i][j] > 0 else { return }
                        self.grid[i][j].backgroundColor = ColorPalette4384.coral
                    }
                }
            }
            queue.addOperation(operation)
        }
    }
    private func draw3() {
        queue.qualityOfService = .utility
        var previousOperation: BlockOperation? = nil
        for i in 0..<11 {
            let operation = BlockOperation()
            for j in 0..<11 {
                operation.addExecutionBlock {
                    sleep(UInt32(Int.random(in: 1...3)))
                    DispatchQueue.main.sync { [weak self] in
                        guard let self, self.colorGrid[i][j] > 0 else { return }
                        self.grid[i][j].backgroundColor = ColorPalette4384.coral
                    }
                }
            }
            if let previousOperation {
                operation.addDependency(previousOperation)
            }
            queue.addOperation(operation)
            previousOperation = operation
        }
    }

    private func draw4() {
        queue.qualityOfService = .utility
        let mainOperation = BlockOperation()
        for i in 0..<11 {
            for j in 0..<11 {
                guard self.colorGrid[i][j] == 2 else { continue }
                mainOperation.addExecutionBlock {
                    sleep(UInt32(Int.random(in: 1...3)))
                    DispatchQueue.main.sync { [weak self] in
                        guard let self else { return }
                        self.grid[i][j].backgroundColor = ColorPalette4384.coralBright
                    }
                }
            }
        }
        queue.addOperation(mainOperation)

        for i in 0..<11 {
            for j in 0..<11 {
                guard self.colorGrid[i][j] == 1 else { continue }
                let operation = BlockOperation {
                    sleep(UInt32(Int.random(in: 1...3)))
                    DispatchQueue.main.sync { [weak self] in
                        guard let self else { return }
                        self.grid[i][j].backgroundColor = ColorPalette4384.coral
                    }
                }
                operation.addDependency(mainOperation)
                queue.addOperation(operation)
            }
        }
    }
    private func draw5(by maxOperationsCount: Int = -1) {
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = maxOperationsCount
        for i in 0..<11 {
            for j in 0..<11 {
                guard self.colorGrid[i][j] > 0 else { continue }
                queue.addOperation(CancellableDrawOperation(for: grid[i][j]))
            }
        }
    }
    private func cancel() {
        queue.cancelAllOperations()
    }
    private func clear() {
        queue.cancelAllOperations()

        for i in 0..<11 {
            for j in 0..<11 {
                grid[i][j].backgroundColor = ColorPalette4384.dirtyGreenLight
            }
        }
    }
}

// MARK: Operation

fileprivate class CancellableDrawOperation: Operation {
    init(for view: UIView) {
        self.view = view
    }

    override func main() {
        sleep(UInt32(Int.random(in: 1...3)))
        guard !isCancelled else { return }
        DispatchQueue.main.sync { [weak self] in
            guard let self, !self.isCancelled else { return }
            self.view.backgroundColor = ColorPalette4384.coral
        }
    }

    private let view: UIView
}
