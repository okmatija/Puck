b2Vec2 :: Vector2;
b2Vec3 :: Vector3;

#scope_module

int8 :: s8;
int16 :: s16;
int32 :: s32;
uint8 :: u8;
uint16 :: u16;
uint32 :: u32;

#import "Basic";
#import "Math";

#if OS == .WINDOWS {
    #load "windows.jai";
    #import "Windows";
} else {
    #assert(false); // @Incomplete
}