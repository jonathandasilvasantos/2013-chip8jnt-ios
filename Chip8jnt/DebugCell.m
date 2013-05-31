//
//  DebugCell.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 31/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "DebugCell.h"

@implementation DebugCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
