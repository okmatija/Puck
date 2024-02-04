// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
apply_transform :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
}



Tuple2 :: struct (T : Type = s8) {
    x, y : T; // @Cleanup i, j should be primary

#place x; component : [2]T = ---;

#place x; i : T = ---;
#place y; j : T = ---;

#place x; a : T = ---;
#place y; b : T = ---;

#place x; w : T = ---;
#place y; h : T = ---;
}


Tuple3 :: struct (T : Type = s8) {
    i, j, k : T;
    #place i; component : [3] T = ---;

#place i; x : T = ---;
#place j; y : T = ---;
#place k; z : T = ---;

#place i; a : T = ---;
#place j; b : T = ---;
#place k; c : T = ---;
}