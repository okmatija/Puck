// @Cleanup inline these....
// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that

// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
b2Mul :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
}

/// Multiply two rotations: q * r
b2Mul :: (q : b2Rot, r : b2Rot) -> b2Rot {
	// [qc -qs] * [rc -rs] = [qc*rc-qs*rs -qc*rs-qs*rc]
	// [qs  qc]   [rs  rc]   [qs*rc+qc*rs -qs*rs+qc*rc]
	// s = qs * rc + qc * rs
	// c = qc * rc - qs * rs
	qr : b2Rot;
	qr.s = q.s * r.c + q.c * r.s;
	qr.c = q.c * r.c - q.s * r.s;
	return qr;
}

/// Rotate a vector
b2Mul :: (q : b2Rot, v : b2Vec2) -> b2Vec2 {
	return .{q.c * v.x - q.s * v.y, q.s * v.x + q.c * v.y};
}

// v2 = A.q.Rot(B.q.Rot(v1) + B.p) + A.p
//    = (A.q * B.q).Rot(v1) + A.q.Rot(B.p) + A.p
b2Mul :: (A : b2Transform, B : b2Transform) -> b2Transform {
	C : b2Transform;
	C.q = b2Mul(A.q, B.q);
	C.p = b2Mul(A.q, B.p) + A.p;
	return C;
}



Tuple2 :: struct (T : Type) {
    x, y : T; // @Cleanup i, j should be primary

#place x; component : [2]T = ---;

#place x; i : T = ---;
#place y; j : T = ---;

#place x; a : T = ---;
#place y; b : T = ---;

#place x; w : T = ---;
#place y; h : T = ---;
}


Tuple3 :: struct (T : Type) {
    i, j, k : T;
    #place i; component : [3] T = ---;

#place i; x : T = ---;
#place j; y : T = ---;
#place k; z : T = ---;

#place i; a : T = ---;
#place j; b : T = ---;
#place k; c : T = ---;
}