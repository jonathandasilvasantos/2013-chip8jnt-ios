//
//  ViewController.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chip8Canvas.h"

@interface ViewController : UIViewController
@property (nonatomic, strong) IBOutlet Chip8Canvas *canvas;

-(void)bitwise;

@end
