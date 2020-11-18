//
//  DBWssTest.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/6/30.
//

#import "DBWssTest.h"
#import "SRWebSocket.h"

@interface DBWssTest() <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket * tempWebSocket;

@end

@implementation DBWssTest

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static DBWssTest *_shareInstance;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[DBWssTest alloc] init];
    });

    return _shareInstance;
}

- (void)openWSSConnectWithIPStr:(NSString *)ipStr {
    _tempWebSocket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", ipStr]]];
    _tempWebSocket.delegate = self;
    [_tempWebSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(socketBindFailed)]){
        [self.delegate socketBindFailed];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSError *err;
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:jsonData
    options:NSJSONReadingMutableContainers error:&err];
    
    NSString *data = [msgDic objectForKey:@"data"];
    if(data.length > 0){
        if([self.delegate respondsToSelector:@selector(refreshViewWithData:)]){
            [self.delegate refreshViewWithData:data];
        }
    }
}


@end
