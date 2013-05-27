//
//  Chip8jntUtils.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "Chip8jntUtils.h"

@implementation Chip8jntUtils

- (void)listAllRoms {

    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.ch8'"];
    NSArray *onlyRoms = [dirContents filteredArrayUsingPredicate:fltr];
    
    NSLog(@"%@", onlyRoms);
}

@end
