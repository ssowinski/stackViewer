//
//  SearchTableViewCell.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 13.03.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Model
    var search: Search? {
        didSet {
            updateUI()
        }
    }
    
    private let userBlock = UIView()
    private let vavBlock = UIView()
    private let dataAndTagBlock = UIView()
    
    private let userImage = UIImageView()
    private let userNameLabel = UILabel()
    private let votesLabel = UILabel()
    private let answerLabel = UILabel()
    private let viewsLabel = UILabel()
    //    private let tagsCollectionView = UICollectionView()
    private var tagsLabels = [UILabel]()
    private var lastActivityDateLabel = UILabel()
    private let titleLabels = UILabel()
    
    private struct Const {
        static let PlaceholderImageName = "placeholder"
        static let ScoreLabelPrefix = "Socore"
        static let AnswerLabelPrefix = "Answer"
        static let ViewsLabelPrefix = "Views"
        static let UserImgHeightAndWidth: CGFloat = 40
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI(){
        userImage.image = UIImage(named: Const.PlaceholderImageName)
        userNameLabel.text = search?.owner?.displayName
        
        if let score = search?.score {
            votesLabel.text = "\(Const.ScoreLabelPrefix):\(score)"
        }
        
        if let answer = search?.answerCount, let isAnswered = search?.isAnswered {
            answerLabel.text = "\(Const.AnswerLabelPrefix):\(answer)"
            answerLabel.backgroundColor = isAnswered ? UIColor.greenColor() : UIColor.clearColor()
        }
        
        if let views = search?.viewCount {
            viewsLabel.text = "\(Const.ViewsLabelPrefix):\(views)"
        }
        
        tagsLabels.removeAll()
        if let tags = search?.tags {
            for tag in tags {
                let tagLabel = UILabel()
                tagLabel.text = tag
                tagLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                tagLabel.backgroundColor = UIColor.brownColor()
                tagLabel.textColor = UIColor.whiteColor()
                tagLabel.sizeToFit()
                tagsLabels.append(tagLabel)
            }
        }
        
        titleLabels.text = search?.title
        
        if let lastActivityDate = search?.lastActivityDate {
            lastActivityDateLabel.text = "\(lastActivityDate.getString(.MediumStyle, timeFormatterStyle: .ShortStyle))"
        }
    }
    
    
    private func setAllLabelSubviewFor(view : UIView, labelHandler : UILabel ->Void) {
        for subview in view.subviews {
            if let labelView = subview as? UILabel {
                labelHandler(labelView)
            }
        }
    }
    
    private func layoutUI() {
        
        contentView.addSubview(lastActivityDateLabel)
        contentView.addSubview(userBlock)
        contentView.addSubview(vavBlock)
        contentView.addSubview(dataAndTagBlock)
        userBlock.addSubview(userImage)
        userBlock.addSubview(userNameLabel)
        vavBlock.addSubview(votesLabel)
        vavBlock.addSubview(answerLabel)
        vavBlock.addSubview(viewsLabel)
        let fillSpaceView = UIView()
        vavBlock.addSubview(fillSpaceView)
        
        
        //        dataAndTagBlock.addSubview(lastActivityDateLabel)
        //        dataAndTagBlock.addSubview(tagsCollectionView)
        contentView.addSubview(titleLabels)
        
        titleLabels.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleLabels.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        titleLabels.numberOfLines = 0
        
        lastActivityDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        userNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        
        setAllLabelSubviewFor(vavBlock) { (labelView) -> Void in
            labelView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            labelView.setContentHuggingPriority(1000, forAxis: .Vertical)
        }
        
        fillSpaceView.translatesAutoresizingMaskIntoConstraints = false
        
        userBlock.translatesAutoresizingMaskIntoConstraints = false
        vavBlock.translatesAutoresizingMaskIntoConstraints = false
        dataAndTagBlock.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        votesLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        viewsLabel.translatesAutoresizingMaskIntoConstraints = false
        //        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        lastActivityDateLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabels.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            
            lastActivityDateLabel.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor),
            lastActivityDateLabel.leadingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.leadingAnchor),
            lastActivityDateLabel.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor),
            lastActivityDateLabel.bottomAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.topAnchor),
            
            
            //            userBlock.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor),
            userBlock.leadingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.leadingAnchor),
            userBlock.bottomAnchor.constraintEqualToAnchor(titleLabels.layoutMarginsGuide.topAnchor),
            
            userImage.topAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.topAnchor),
            userImage.leadingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.leadingAnchor),
            userImage.widthAnchor.constraintEqualToConstant(Const.UserImgHeightAndWidth),
            userImage.heightAnchor.constraintEqualToConstant(Const.UserImgHeightAndWidth),
            userImage.trailingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.trailingAnchor),
            
            userNameLabel.topAnchor.constraintEqualToAnchor(userImage.bottomAnchor),
            userNameLabel.leadingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.leadingAnchor),
            userNameLabel.trailingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.trailingAnchor),
            userNameLabel.bottomAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.bottomAnchor),
            
            vavBlock.topAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.topAnchor),
            vavBlock.leadingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.trailingAnchor),
            vavBlock.heightAnchor.constraintEqualToAnchor(userBlock.heightAnchor),
            
            votesLabel.topAnchor.constraintEqualToAnchor(vavBlock.topAnchor),
            votesLabel.leadingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.leadingAnchor),
            votesLabel.trailingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.trailingAnchor),
            
            answerLabel.topAnchor.constraintEqualToAnchor(votesLabel.bottomAnchor),
            answerLabel.leadingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.leadingAnchor),
            answerLabel.widthAnchor.constraintEqualToAnchor(votesLabel.widthAnchor),
            
            viewsLabel.topAnchor.constraintEqualToAnchor(answerLabel.bottomAnchor),
            viewsLabel.leadingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.leadingAnchor),
            viewsLabel.widthAnchor.constraintEqualToAnchor(votesLabel.widthAnchor),
            
            fillSpaceView.topAnchor.constraintEqualToAnchor(viewsLabel.bottomAnchor),
            fillSpaceView.leadingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.leadingAnchor),
            fillSpaceView.widthAnchor.constraintEqualToAnchor(votesLabel.widthAnchor),
            fillSpaceView.bottomAnchor.constraintEqualToAnchor(vavBlock.bottomAnchor),
            
            dataAndTagBlock.topAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.topAnchor),
            dataAndTagBlock.leadingAnchor.constraintEqualToAnchor(vavBlock.layoutMarginsGuide.trailingAnchor),
            dataAndTagBlock.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor),
            dataAndTagBlock.heightAnchor.constraintEqualToAnchor(userBlock.heightAnchor),
            
            
            //            lastActivityDateLabel.bottomAnchor.constraintEqualToAnchor(tagsCollectionView.layoutMarginsGuide.topAnchor),
            
            //            tagsCollectionView.leadingAnchor.constraintEqualToAnchor(dataAndTagBlock.layoutMarginsGuide.leadingAnchor),
            //            tagsCollectionView.trailingAnchor.constraintEqualToAnchor(dataAndTagBlock.layoutMarginsGuide.trailingAnchor),
            //            tagsCollectionView.bottomAnchor.constraintEqualToAnchor(dataAndTagBlock.layoutMarginsGuide.bottomAnchor),
            
            titleLabels.leadingAnchor.constraintEqualToAnchor(userBlock.layoutMarginsGuide.leadingAnchor),
            titleLabels.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor),
            titleLabels.bottomAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.bottomAnchor)
            ])
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
