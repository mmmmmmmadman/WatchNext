#import "ObjCExceptionCatcher.h"

@implementation ObjCExceptionCatcher

+ (BOOL)executeBlock:(void(NS_NOESCAPE ^)(void))block {
    @try {
        block();
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"[ObjCExceptionCatcher] Caught exception: %@ - %@", exception.name, exception.reason);
        return NO;
    }
}

@end
