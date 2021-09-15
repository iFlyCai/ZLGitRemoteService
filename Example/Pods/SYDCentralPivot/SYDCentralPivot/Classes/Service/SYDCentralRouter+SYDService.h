#import "SYDCentralRouter.h"

@interface SYDCentralRouter (SYDService)

- (id _Nullable) sendMessageToService:(const NSString * _Nonnull) serviceKey withSEL:(SEL _Nonnull) message withPara:(NSArray * _Nullable) paramArray isInstanceMessage:(BOOL) isInstanceMessage;

@end