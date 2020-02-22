//
//  VideoTableViewCell.swift
//  AVFoundationDemo
//
//  Created by yier on 2020/2/20.
//  Copyright © 2020 yier. All rights reserved.
//

import Foundation
import UIKit

class VideoTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let previewImageView = UIImageView()
    let subtitleLabel = UILabel()
    
    var video: Video? = nil {
        didSet{
            updateViews()
        }
    }
    
    //Sizing
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK - Table Cell Height
    class func height(for viewModel: Video) -> CGFloat{
        let previewHeight: CGFloat = 200
        let padding: CGFloat = 16

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.text = viewModel.title
        let titleHeight = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .infinity)).height

        label.text = viewModel.subtitle
        label.font = UIFont.systemFont(ofSize: 14.0)
        let subtitleHeight = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .infinity)).height

        return padding + titleHeight + padding + previewHeight + padding + subtitleHeight + padding
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = .blue
    }
}
