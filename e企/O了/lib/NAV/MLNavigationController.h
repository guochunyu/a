//
//  MLNavigationController.h
//  MultiLayerNavigation
//

//

#import <UIKit/UIKit.h>

@interface MLNavigationController : UINavigationController <UIGestureRecognizerDelegate>

// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign)BOOL canDragBack;

@end
