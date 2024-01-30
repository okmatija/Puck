// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
apply_transform :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
}



Tuple2 :: struct {
    x, y : int; // @Cleanup i, j should be primary

#place x; component : [2]int = ---;

#place x; i : int = ---;
#place y; j : int = ---;

#place x; w : int = ---;
#place y; h : int = ---;
}


Tuple3 :: struct (T : Type = s8) {
    i, j, k : T;
    #place i; component : [3] T = ---;
}