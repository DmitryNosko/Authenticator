//
//  TabBarActionButton.swift
//  Authenticator
//
//  Created by Roman Knyukh on 27.03.24.
//

import UIKit

final class TabBarActionButton: UIButton {
    private let buttonTitlelabel = UILabel()
    private let iconImageView = UIImageView()

    init(title: String, imageName: String) {
        self.iconImageView.image = UIImage(named: imageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.buttonTitlelabel.text = title
        super.init(frame: .zero)
        assemble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TabBarActionButton {
    func assemble() {
        addSubviews()
        setupUI()
        setupConstraints()
    }

    func addSubviews() {
        self.addSubview(buttonTitlelabel)
        self.addSubview(iconImageView)
    }

    func setupUI() {
        with(self) {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 28.scaled()
        }

        with(buttonTitlelabel) {
            $0.textAlignment = .center
            $0.font = .outfit(ofSize: 20, weight: .medium)
            $0.textColor = .white
        }
    }

    func setupConstraints() {
        self.snp.makeConstraints {
            $0.height.equalToScaledValue(72)
        }

        buttonTitlelabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalToScaledValue(24)
        }

        iconImageView.snp.makeConstraints {
            $0.centerY.equalTo(buttonTitlelabel.snp.centerY)
            $0.trailing.equalTo(buttonTitlelabel.snp.leading).scaledOffset(-10)
            $0.height.width.equalToScaledValue(20)
        }
    }
}
