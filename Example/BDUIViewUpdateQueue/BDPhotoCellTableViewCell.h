//
//  BDPhotoCellTableViewCell.h
//  BDUIViewUpdateQueue
//
//  Created by Norsez Orankijanan on 5/22/15.
//  Copyright (c) 2015 Norsez Orankijanan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDPhotoCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
