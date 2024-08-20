//
//  CommonInfoView.swift
//  Authenticator
//
//  Created by Roman Knyukh Personal on 3/25/24.
//

import UIKit

final class CommonInfoView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    
    init(with imageName: String, title: String, subTitle: String) {
        titleLabel.text = title
        subLabel.text = subTitle
        imageView.image = UIImage(named: imageName)
        super.init(frame: .zero)
        assemble()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CommonInfoView {
    func assemble() {
        addSubviews()
        configureViews()
        setConstraints()
    }
    
    func addSubviews() {
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(subLabel)
    }
    
    func configureViews() {
        with(self) {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20.scaled()
            $0.layer.shadowRadius = 4.scaled()
            $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            $0.layer.masksToBounds = false
            $0.layer.shadowOpacity = 0.4
            $0.layer.shadowOffset = CGSize.zero
        }
        
        with(imageView) {
            $0.contentMode = .scaleAspectFit
        }
        
        with(titleLabel) {
            $0.textColor = .black
            $0.font = .systemFont(ofSize: 32, weight: .bold)
            $0.textAlignment = .center
        }
        
        with(subLabel) {
            $0.textColor = UIColor.hex("#CCCCCC")
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
    }
    
    func setConstraints() {
        self.snp.makeConstraints {
            $0.height.equalToScaledValue(360)
            $0.width.equalToScaledValue(335)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().scaledOffset(20)
            $0.height.equalToScaledValue(200)
            $0.width.equalToScaledValue(222)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).scaledOffset(2)
            $0.height.equalToScaledValue(40)
            $0.centerX.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).scaledOffset(10)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().scaledOffset(22)
            $0.trailing.equalToSuperview().scaledOffset(-22)
        }
    }
}
