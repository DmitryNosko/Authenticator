//
//  CircleCloseButton.swift
//  Authenticator
//
//  Created by Roman Knyukh on 27.03.24.
//

import UIKit

final class CircleButton: UIButton {
    private let backgroundView = UIView()
    private let iconImageView = UIImageView()

    init(image: UIImage?) {
        iconImageView.image = image
        super.init(frame: .zero)
        assemble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CircleButton {
    func assemble() {
        addSubviews()
        setConstraints()
        setupUI()
    }

    func addSubviews() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(iconImageView)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(54)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    func setupUI() {
        clipsToBounds = true

        with(backgroundView) {
            $0.frame.size = CGSize(width: 54, height: 54)
            $0.layer.cornerRadius = 27
            $0.clipsToBounds = true
            $0.applyGradient(with: [.white.withAlphaComponent(0), .white.withAlphaComponent(0.1)], gradient: .horizontal)
        }
    }
}
