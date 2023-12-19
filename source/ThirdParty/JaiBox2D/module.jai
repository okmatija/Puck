//
// This file was auto-generated using the following command:
//
// jai ./generate.jai
//



b2_lengthUnitsPerMeter :: 1.0;

b2_maxPolygonVertices :: 8;

b2_pi :: 3.14159265359;

b2_maxManifoldPoints :: 2;

b2_aabbMultiplier :: 4.0;

b2_maxSubSteps :: 8;

b2_maxTOIContacts :: 32;

b2_baumgarte :: 0.2;
b2_toiBaumgarte :: 0.75;

b2_timeToSleep :: 0.5;

b2_nullNode :: -1;

// nocommit Remove these typedefs, or prefix them?
#scope_file

int8 :: s8;
int16 :: s16;
int32 :: s32;
uint8 :: u8;
uint16 :: u16;
uint32 :: u32;
uintptr_t :: u64;

#scope_export

/// You can define this to inject whatever data you want in b2Body
b2BodyUserData :: struct {
    Constructor :: (this: *b2BodyUserData) -> void #cpp_method #foreign box2d "??0b2BodyUserData@@QEAA@XZ";

    /// For legacy compatibility
    pointer: uintptr_t;
}

/// You can define this to inject whatever data you want in b2Fixture
b2FixtureUserData :: struct {
    Constructor :: (this: *b2FixtureUserData) -> void #cpp_method #foreign box2d "??0b2FixtureUserData@@QEAA@XZ";

    /// For legacy compatibility
    pointer: uintptr_t;
}

/// You can define this to inject whatever data you want in b2Joint
b2JointUserData :: struct {
    Constructor :: (this: *b2JointUserData) -> void #cpp_method #foreign box2d "??0b2JointUserData@@QEAA@XZ";

    /// For legacy compatibility
    pointer: uintptr_t;
}

/// Default allocation functions
b2Alloc_Default :: (size: int32) -> *void #foreign box2d "?b2Alloc_Default@@YAPEAXH@Z";
b2Free_Default :: (mem: *void) -> void #foreign box2d "?b2Free_Default@@YAXPEAX@Z";

/// Version numbering scheme.
/// See http://en.wikipedia.org/wiki/Software_versioning
b2Version :: struct {
    major:    int32; ///< significant changes
    minor:    int32; ///< incremental changes
    revision: int32; ///< bug fixes
}

b2Block :: struct {}
b2Chunk :: struct {}

/// This is a small object allocator used for allocating small
/// objects that persist for more than one time step.
/// See: http://www.codeproject.com/useritems/Small_Block_Allocator.asp
b2BlockAllocator :: struct {
    Constructor :: (this: *b2BlockAllocator) -> void #cpp_method #foreign box2d "??0b2BlockAllocator@@QEAA@XZ";
    Destructor :: (this: *b2BlockAllocator) -> void #cpp_method #foreign box2d "??1b2BlockAllocator@@QEAA@XZ";

    /// Allocate memory. This will use b2Alloc if the size is larger than b2_maxBlockSize.
    Allocate :: (this: *b2BlockAllocator, size: int32) -> *void #cpp_method #foreign box2d "?Allocate@b2BlockAllocator@@QEAAPEAXH@Z";

    /// Free memory. This will use b2Free if the size is larger than b2_maxBlockSize.
    Free :: (this: *b2BlockAllocator, p: *void, size: int32) -> void #cpp_method #foreign box2d "?Free@b2BlockAllocator@@QEAAXPEAXH@Z";

    Clear :: (this: *b2BlockAllocator) -> void #cpp_method #foreign box2d "?Clear@b2BlockAllocator@@QEAAXXZ";

    m_chunks:     *b2Chunk;
    m_chunkCount: int32;
    m_chunkSpace: int32;

    m_freeLists:  [14] *b2Block;
}

/// A 2D column vector.
b2Vec2 :: Vector2;
// b2Vec2 :: struct {
//     /// Default constructor does nothing (for performance).
//     Constructor :: (this: *b2Vec2) -> void #cpp_method #foreign box2d "??0b2Vec2@@QEAA@XZ";

//     /// Construct using coordinates.
//     Constructor :: (this: *b2Vec2, xIn: float, yIn: float) -> void #cpp_method #foreign box2d "??0b2Vec2@@QEAA@MM@Z";

//     /// Set this vector to all zeros.
//     SetZero :: (this: *b2Vec2) -> void #cpp_method #foreign box2d "?SetZero@b2Vec2@@QEAAXXZ";

//     /// Set this vector to some specified coordinates.
//     Set :: (this: *b2Vec2, x_: float, y_: float) -> void #cpp_method #foreign box2d "?Set@b2Vec2@@QEAAXMM@Z";

//     /// Get the length of this vector (the norm).
//     Length :: (this: *b2Vec2) -> float #cpp_method #foreign box2d "?Length@b2Vec2@@QEBAMXZ";

//     /// Get the length squared. For performance, use this instead of
//     /// b2Vec2::Length (if possible).
//     LengthSquared :: (this: *b2Vec2) -> float #cpp_method #foreign box2d "?LengthSquared@b2Vec2@@QEBAMXZ";

//     /// Convert this vector into a unit vector. Returns the length.
//     Normalize :: (this: *b2Vec2) -> float #cpp_method #foreign box2d "?Normalize@b2Vec2@@QEAAMXZ";

//     /// Does this vector contain finite coordinates?
//     IsValid :: (this: *b2Vec2) -> bool #cpp_method #foreign box2d "?IsValid@b2Vec2@@QEBA_NXZ";

//     /// Get the skew vector such that dot(skew_vec, other) == cross(vec, other)
//     Skew :: (this: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?Skew@b2Vec2@@QEBA?AU1@XZ";

//     x: float;
//     y: float;
// }

// xy :: (vec: b2Vec2) -> Vector2 {
//     return xy(vec.x, vec.y);
// }

// xy :: (vec: Vector2) -> b2Vec2 {
//     r: b2Vec2 = ---;
//     r.x = vec.x;
//     r.y = vec.y;
//     return r;
// }

/// Negate this vector.
// operator- :: (this: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "??Gb2Vec2@@QEBA?AU0@XZ";
// operator- :: (this: b2Vec2) -> b2Vec2 #no_context {
//     return operator-(*this);
// }

// /// Read from and indexed element.
// operator_parens :: (this: /*const*/ *b2Vec2, i: int32) -> float #cpp_method #foreign box2d "??Rb2Vec2@@QEBAMH@Z";
// operator_parens :: (this: b2Vec2, i: int32) -> float #no_context {
//     return operator_parens(*this, i);
// }

// /// Write to an indexed element.
// operator_parens_1 :: (this: *b2Vec2, i: int32) -> *float #cpp_method #foreign box2d "??Rb2Vec2@@QEAAAEAMH@Z";
// operator_parens_1 :: (this: b2Vec2, i: int32) -> *float #no_context {
//     return operator_parens_1(*this, i);
// }

/// Add a vector to this vector.
// operator+= :: (this: *b2Vec2, v: *b2Vec2) -> void #cpp_method #foreign box2d "??Yb2Vec2@@QEAAXAEBU0@@Z";
// operator+= :: (this: *b2Vec2, v: b2Vec2) #no_context {
//     operator+=(this, *v);
// }

/// Subtract a vector from this vector.
// operator-= :: (this: *b2Vec2, v: *b2Vec2) -> void #cpp_method #foreign box2d "??Zb2Vec2@@QEAAXAEBU0@@Z";
// operator-= :: (this: *b2Vec2, v: b2Vec2) #no_context {
//     operator-=(this, *v);
// }

/// Multiply this vector by a scalar.
// operator*= :: (this: *b2Vec2, a: float) -> void #cpp_method #foreign box2d "??Xb2Vec2@@QEAAXM@Z";

/// A 2D column vector with 3 elements.
b2Vec3 :: Vector3;
// b2Vec3 :: struct {
//     /// Default constructor does nothing (for performance).
//     Constructor :: (this: *b2Vec3) -> void #cpp_method #foreign box2d "??0b2Vec3@@QEAA@XZ";

//     /// Construct using coordinates.
//     Constructor :: (this: *b2Vec3, xIn: float, yIn: float, zIn: float) -> void #cpp_method #foreign box2d "??0b2Vec3@@QEAA@MMM@Z";

//     /// Set this vector to all zeros.
//     SetZero :: (this: *b2Vec3) -> void #cpp_method #foreign box2d "?SetZero@b2Vec3@@QEAAXXZ";

//     /// Set this vector to some specified coordinates.
//     Set :: (this: *b2Vec3, x_: float, y_: float, z_: float) -> void #cpp_method #foreign box2d "?Set@b2Vec3@@QEAAXMMM@Z";

//     x: float;
//     y: float;
//     z: float;
// }

/// Negate this vector.
// operator- :: (this: *b2Vec3) -> b2Vec3 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "??Gb2Vec3@@QEBA?AU0@XZ";
// operator- :: (this: b2Vec3) -> b2Vec3 #no_context {
//     return operator-(*this);
// }

/// Add a vector to this vector.
// operator+= :: (this: *b2Vec3, v: *b2Vec3) -> void #cpp_method #foreign box2d "??Yb2Vec3@@QEAAXAEBU0@@Z";
// operator+= :: (this: *b2Vec3, v: b2Vec3) #no_context {
//     operator+=(this, *v);
// }

/// Subtract a vector from this vector.
// operator-= :: (this: *b2Vec3, v: *b2Vec3) -> void #cpp_method #foreign box2d "??Zb2Vec3@@QEAAXAEBU0@@Z";
// operator-= :: (this: *b2Vec3, v: b2Vec3) #no_context {
//     operator-=(this, *v);
// }

/// Multiply this vector by a scalar.
// operator*= :: (this: *b2Vec3, s: float) -> void #cpp_method #foreign box2d "??Xb2Vec3@@QEAAXM@Z";

/// A 2-by-2 matrix. Stored in column-major order.
b2Mat22 :: struct {
    /// The default constructor does nothing (for performance).
    Constructor :: (this: *b2Mat22) -> void #cpp_method #foreign box2d "??0b2Mat22@@QEAA@XZ";

    /// Construct this matrix using columns.
    Constructor :: (this: *b2Mat22, c1: *b2Vec2, c2: *b2Vec2) -> void #cpp_method #foreign box2d "??0b2Mat22@@QEAA@AEBUb2Vec2@@0@Z";
    Constructor :: (this: *b2Mat22, c1: b2Vec2, c2: b2Vec2) #no_context {
        Constructor(this, *c1, *c2);
    }

    /// Construct this matrix using scalars.
    Constructor :: (this: *b2Mat22, a11: float, a12: float, a21: float, a22: float) -> void #cpp_method #foreign box2d "??0b2Mat22@@QEAA@MMMM@Z";

    /// Initialize this matrix using columns.
    Set :: (this: *b2Mat22, c1: *b2Vec2, c2: *b2Vec2) -> void #cpp_method #foreign box2d "?Set@b2Mat22@@QEAAXAEBUb2Vec2@@0@Z";
    Set :: (this: *b2Mat22, c1: b2Vec2, c2: b2Vec2) #no_context {
        Set(this, *c1, *c2);
    }

    /// Set this to the identity matrix.
    SetIdentity :: (this: *b2Mat22) -> void #cpp_method #foreign box2d "?SetIdentity@b2Mat22@@QEAAXXZ";

    /// Set this matrix to all zeros.
    SetZero :: (this: *b2Mat22) -> void #cpp_method #foreign box2d "?SetZero@b2Mat22@@QEAAXXZ";

    GetInverse :: (this: *b2Mat22) -> b2Mat22 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetInverse@b2Mat22@@QEBA?AU1@XZ";

    /// Solve A * x = b, where b is a column vector. This is more efficient
    /// than computing the inverse in one-shot cases.
    Solve :: (this: *b2Mat22, b: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?Solve@b2Mat22@@QEBA?AUb2Vec2@@AEBU2@@Z";
    Solve :: (this: *b2Mat22, b: b2Vec2) -> b2Vec2 #no_context {
        return Solve(this, *b);
    }

    ex: b2Vec2;
    ey: b2Vec2;
}

/// A 3-by-3 matrix. Stored in column-major order.
b2Mat33 :: struct {
    /// The default constructor does nothing (for performance).
    Constructor :: (this: *b2Mat33) -> void #cpp_method #foreign box2d "??0b2Mat33@@QEAA@XZ";

    /// Construct this matrix using columns.
    Constructor :: (this: *b2Mat33, c1: *b2Vec3, c2: *b2Vec3, c3: *b2Vec3) -> void #cpp_method #foreign box2d "??0b2Mat33@@QEAA@AEBUb2Vec3@@00@Z";
    Constructor :: (this: *b2Mat33, c1: b2Vec3, c2: b2Vec3, c3: b2Vec3) #no_context {
        Constructor(this, *c1, *c2, *c3);
    }

    /// Set this matrix to all zeros.
    SetZero :: (this: *b2Mat33) -> void #cpp_method #foreign box2d "?SetZero@b2Mat33@@QEAAXXZ";

    /// Solve A * x = b, where b is a column vector. This is more efficient
    /// than computing the inverse in one-shot cases.
    Solve33 :: (this: *b2Mat33, b: *b2Vec3) -> b2Vec3 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?Solve33@b2Mat33@@QEBA?AUb2Vec3@@AEBU2@@Z";
    Solve33 :: (this: *b2Mat33, b: b2Vec3) -> b2Vec3 #no_context {
        return Solve33(this, *b);
    }

    /// Solve A * x = b, where b is a column vector. This is more efficient
    /// than computing the inverse in one-shot cases. Solve only the upper
    /// 2-by-2 matrix equation.
    Solve22 :: (this: *b2Mat33, b: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?Solve22@b2Mat33@@QEBA?AUb2Vec2@@AEBU2@@Z";
    Solve22 :: (this: *b2Mat33, b: b2Vec2) -> b2Vec2 #no_context {
        return Solve22(this, *b);
    }

    /// Get the inverse of this matrix as a 2-by-2.
    /// Returns the zero matrix if singular.
    GetInverse22 :: (this: *b2Mat33, M: *b2Mat33) -> void #cpp_method #foreign box2d "?GetInverse22@b2Mat33@@QEBAXPEAU1@@Z";

    /// Get the symmetric inverse of this matrix as a 3-by-3.
    /// Returns the zero matrix if singular.
    GetSymInverse33 :: (this: *b2Mat33, M: *b2Mat33) -> void #cpp_method #foreign box2d "?GetSymInverse33@b2Mat33@@QEBAXPEAU1@@Z";

    ex: b2Vec3;
    ey: b2Vec3;
    ez: b2Vec3;
}

/// Rotation
b2Rot :: struct {
    Constructor :: (this: *b2Rot) -> void #cpp_method #foreign box2d "??0b2Rot@@QEAA@XZ";

    /// Initialize from an angle in radians
    Constructor :: (this: *b2Rot, angle: float) -> void #cpp_method #foreign box2d "??0b2Rot@@QEAA@M@Z";

    /// Set using an angle in radians.
    Set :: (this: *b2Rot, angle: float) -> void #cpp_method #foreign box2d "?Set@b2Rot@@QEAAXM@Z";

    /// Set to the identity rotation
    SetIdentity :: (this: *b2Rot) -> void #cpp_method #foreign box2d "?SetIdentity@b2Rot@@QEAAXXZ";

    /// Get the angle in radians
    GetAngle :: (this: *b2Rot) -> float #cpp_method #foreign box2d "?GetAngle@b2Rot@@QEBAMXZ";

    /// Get the x-axis
    GetXAxis :: (this: *b2Rot) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetXAxis@b2Rot@@QEBA?AUb2Vec2@@XZ";

    /// Get the u-axis
    GetYAxis :: (this: *b2Rot) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetYAxis@b2Rot@@QEBA?AUb2Vec2@@XZ";

    /// Sine and cosine
    s: float;
    /// Sine and cosine
    c: float;
}

/// A transform contains translation and rotation. It is used to represent
/// the position and orientation of rigid frames.
b2Transform :: struct {
    /// The default constructor does nothing.
    Constructor :: (this: *b2Transform) -> void #cpp_method #foreign box2d "??0b2Transform@@QEAA@XZ";

    /// Initialize using a position vector and a rotation.
    Constructor :: (this: *b2Transform, position: *b2Vec2, rotation: *b2Rot) -> void #cpp_method #foreign box2d "??0b2Transform@@QEAA@AEBUb2Vec2@@AEBUb2Rot@@@Z";
    Constructor :: (this: *b2Transform, position: b2Vec2, rotation: b2Rot) #no_context {
        Constructor(this, *position, *rotation);
    }

    /// Set this to the identity transform.
    SetIdentity :: (this: *b2Transform) -> void #cpp_method #foreign box2d "?SetIdentity@b2Transform@@QEAAXXZ";

    /// Set this based on the position and angle.
    Set :: (this: *b2Transform, position: *b2Vec2, angle: float) -> void #cpp_method #foreign box2d "?Set@b2Transform@@QEAAXAEBUb2Vec2@@M@Z";
    Set :: (this: *b2Transform, position: b2Vec2, angle: float) #no_context {
        Set(this, *position, angle);
    }

    p: b2Vec2;
    q: b2Rot;
}

/// This describes the motion of a body/shape for TOI computation.
/// Shapes are defined with respect to the body origin, which may
/// no coincide with the center of mass. However, to support dynamics
/// we must interpolate the center of mass position.
b2Sweep :: struct {
    /// Get the interpolated transform at a specific time.
    /// @param transform the output transform
    /// @param beta is a factor in [0,1], where 0 indicates alpha0.
    GetTransform :: (this: *b2Sweep, transform: *b2Transform, beta: float) -> void #cpp_method #foreign box2d "?GetTransform@b2Sweep@@QEBAXPEAUb2Transform@@M@Z";

    /// Advance the sweep forward, yielding a new initial state.
    /// @param alpha the new initial time.
    Advance :: (this: *b2Sweep, alpha: float) -> void #cpp_method #foreign box2d "?Advance@b2Sweep@@QEAAXM@Z";

    /// Normalize the angles.
    Normalize :: (this: *b2Sweep) -> void #cpp_method #foreign box2d "?Normalize@b2Sweep@@QEAAXXZ";

    localCenter: b2Vec2; ///< local center of mass position
    c0:          b2Vec2; ///< center world positions
    c:           b2Vec2; ///< center world positions
    a0:          float; ///< world angles
    a:           float; ///< world angles

    /// Fraction of the current time step in the range [0,1]
    /// c0 and a0 are the positions at alpha0.
    alpha0:      float;
}

/// The features that intersect to form the contact point
/// This must be 4 bytes or less.
b2ContactFeature :: struct {
    Type :: enum s32 {
        vertex :: 0;
        face   :: 1;

        e_vertex :: vertex;
        e_face   :: face;
    }

    indexA: uint8; ///< Feature index on shapeA
    indexB: uint8; ///< Feature index on shapeB
    typeA:  uint8; ///< The feature type on shapeA
    typeB:  uint8; ///< The feature type on shapeB
}

/// Contact ids to facilitate warm starting.
b2ContactID :: union {
    cf:  b2ContactFeature;
    key: uint32; ///< Used to quickly compare contact ids.
}

/// A manifold point is a contact point belonging to a contact
/// manifold. It holds details related to the geometry and dynamics
/// of the contact points.
/// The local point usage depends on the manifold type:
/// -e_circles: the local center of circleB
/// -e_faceA: the local center of cirlceB or the clip point of polygonB
/// -e_faceB: the clip point of polygonA
/// This structure is stored across time steps, so we keep it small.
/// Note: the impulses are used for internal caching and may not
/// provide reliable contact forces, especially for high speed collisions.
b2ManifoldPoint :: struct {
    localPoint:     b2Vec2; ///< usage depends on manifold type
    normalImpulse:  float; ///< the non-penetration impulse
    tangentImpulse: float; ///< the friction impulse
    id:             b2ContactID; ///< uniquely identifies a contact point between two shapes
}

/// A manifold for two touching convex shapes.
/// Box2D supports multiple types of contact:
/// - clip point versus plane with radius
/// - point versus point with radius (circles)
/// The local point usage depends on the manifold type:
/// -e_circles: the local center of circleA
/// -e_faceA: the center of faceA
/// -e_faceB: the center of faceB
/// Similarly the local normal usage:
/// -e_circles: not used
/// -e_faceA: the normal on polygonA
/// -e_faceB: the normal on polygonB
/// We store contacts in this way so that position correction can
/// account for movement, which is critical for continuous physics.
/// All contact scenarios must be expressed in one of these types.
/// This structure is stored across time steps, so we keep it small.
b2Manifold :: struct {
    Type :: enum s32 {
        circles :: 0;
        faceA   :: 1;
        faceB   :: 2;

        e_circles :: circles;
        e_faceA   :: faceA;
        e_faceB   :: faceB;
    }

    points:      [2] b2ManifoldPoint; ///< the points of contact
    localNormal: b2Vec2; ///< not use for Type::e_points
    localPoint:  b2Vec2; ///< usage depends on manifold type
    type:        Type;
    pointCount:  int32; ///< the number of manifold points
}

/// This is used to compute the current state of a contact manifold.
b2WorldManifold :: struct {
    /// Evaluate the manifold with supplied transforms. This assumes
    /// modest motion from the original state. This does not change the
    /// point count, impulses, etc. The radii must come from the shapes
    /// that generated the manifold.
    Initialize :: (this: *b2WorldManifold, manifold: *b2Manifold, xfA: *b2Transform, radiusA: float, xfB: *b2Transform, radiusB: float) -> void #cpp_method #foreign box2d "?Initialize@b2WorldManifold@@QEAAXPEBUb2Manifold@@AEBUb2Transform@@M1M@Z";
    Initialize :: (this: *b2WorldManifold, manifold: *b2Manifold, xfA: b2Transform, radiusA: float, xfB: b2Transform, radiusB: float) #no_context {
        Initialize(this, manifold, *xfA, radiusA, *xfB, radiusB);
    }

    normal:      b2Vec2; ///< world vector pointing from A to B
    points:      [2] b2Vec2; ///< world contact point (point of intersection)
    separations: [2] float; ///< a negative value indicates overlap, in meters
}

/// This is used for determining the state of contact points.
b2PointState :: enum s32 {
    nullState    :: 0;
    addState     :: 1;
    persistState :: 2;
    removeState  :: 3;

    b2_nullState    :: nullState;
    b2_addState     :: addState;
    b2_persistState :: persistState;
    b2_removeState  :: removeState;
}

/// Compute the point states given two manifolds. The states pertain to the transition from manifold1
/// to manifold2. So state1 is either persist or remove while state2 is either add or persist.
b2GetPointStates :: (state1: *[2] b2PointState, state2: *[2] b2PointState, manifold1: *b2Manifold, manifold2: *b2Manifold) -> void #foreign box2d "?b2GetPointStates@@YAXQEAW4b2PointState@@0PEBUb2Manifold@@1@Z";

/// Used for computing contact manifolds.
b2ClipVertex :: struct {
    v:  b2Vec2;
    id: b2ContactID;
}

/// Ray-cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1).
b2RayCastInput :: struct {
    p1:          b2Vec2;
    p2:          b2Vec2;
    maxFraction: float;
}

/// Ray-cast output data. The ray hits at p1 + fraction * (p2 - p1), where p1 and p2
/// come from b2RayCastInput.
b2RayCastOutput :: struct {
    normal:   b2Vec2;
    fraction: float;
}

/// An axis aligned bounding box.
b2AABB :: struct {
    /// Verify that the bounds are sorted.
    IsValid :: (this: *b2AABB) -> bool #cpp_method #foreign box2d "?IsValid@b2AABB@@QEBA_NXZ";

    /// Get the center of the AABB.
    GetCenter :: (this: *b2AABB) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetCenter@b2AABB@@QEBA?AUb2Vec2@@XZ";

    /// Get the extents of the AABB (half-widths).
    GetExtents :: (this: *b2AABB) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetExtents@b2AABB@@QEBA?AUb2Vec2@@XZ";

    /// Get the perimeter length
    GetPerimeter :: (this: *b2AABB) -> float #cpp_method #foreign box2d "?GetPerimeter@b2AABB@@QEBAMXZ";

    /// Combine an AABB into this one.
    Combine :: (this: *b2AABB, aabb: *b2AABB) -> void #cpp_method #foreign box2d "?Combine@b2AABB@@QEAAXAEBU1@@Z";
    Combine :: (this: *b2AABB, aabb: b2AABB) #no_context {
        Combine(this, *aabb);
    }

    /// Combine two AABBs into this one.
    Combine :: (this: *b2AABB, aabb1: *b2AABB, aabb2: *b2AABB) -> void #cpp_method #foreign box2d "?Combine@b2AABB@@QEAAXAEBU1@0@Z";
    Combine :: (this: *b2AABB, aabb1: b2AABB, aabb2: b2AABB) #no_context {
        Combine(this, *aabb1, *aabb2);
    }

    /// Does this aabb contain the provided AABB.
    Contains :: (this: *b2AABB, aabb: *b2AABB) -> bool #cpp_method #foreign box2d "?Contains@b2AABB@@QEBA_NAEBU1@@Z";
    Contains :: (this: *b2AABB, aabb: b2AABB) -> bool #no_context {
        return Contains(this, *aabb);
    }

    RayCast :: (this: *b2AABB, output: *b2RayCastOutput, input: *b2RayCastInput) -> bool #cpp_method #foreign box2d "?RayCast@b2AABB@@QEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@@Z";
    RayCast :: (this: *b2AABB, output: *b2RayCastOutput, input: b2RayCastInput) -> bool #no_context {
        return RayCast(this, output, *input);
    }

    lowerBound: b2Vec2; ///< the lower vertex
    upperBound: b2Vec2; ///< the upper vertex
}

/// Compute the collision manifold between two circles.
b2CollideCircles :: (manifold: *b2Manifold, circleA: *b2CircleShape, xfA: *b2Transform, circleB: *b2CircleShape, xfB: *b2Transform) -> void #foreign box2d "?b2CollideCircles@@YAXPEAUb2Manifold@@PEBVb2CircleShape@@AEBUb2Transform@@12@Z";
b2CollideCircles :: (manifold: *b2Manifold, circleA: *b2CircleShape, xfA: b2Transform, circleB: *b2CircleShape, xfB: b2Transform) #no_context {
    b2CollideCircles(manifold, circleA, *xfA, circleB, *xfB);
}

/// Compute the collision manifold between a polygon and a circle.
b2CollidePolygonAndCircle :: (manifold: *b2Manifold, polygonA: *b2PolygonShape, xfA: *b2Transform, circleB: *b2CircleShape, xfB: *b2Transform) -> void #foreign box2d "?b2CollidePolygonAndCircle@@YAXPEAUb2Manifold@@PEBVb2PolygonShape@@AEBUb2Transform@@PEBVb2CircleShape@@2@Z";
b2CollidePolygonAndCircle :: (manifold: *b2Manifold, polygonA: *b2PolygonShape, xfA: b2Transform, circleB: *b2CircleShape, xfB: b2Transform) #no_context {
    b2CollidePolygonAndCircle(manifold, polygonA, *xfA, circleB, *xfB);
}

/// Compute the collision manifold between two polygons.
b2CollidePolygons :: (manifold: *b2Manifold, polygonA: *b2PolygonShape, xfA: *b2Transform, polygonB: *b2PolygonShape, xfB: *b2Transform) -> void #foreign box2d "?b2CollidePolygons@@YAXPEAUb2Manifold@@PEBVb2PolygonShape@@AEBUb2Transform@@12@Z";
b2CollidePolygons :: (manifold: *b2Manifold, polygonA: *b2PolygonShape, xfA: b2Transform, polygonB: *b2PolygonShape, xfB: b2Transform) #no_context {
    b2CollidePolygons(manifold, polygonA, *xfA, polygonB, *xfB);
}

/// Compute the collision manifold between an edge and a circle.
b2CollideEdgeAndCircle :: (manifold: *b2Manifold, polygonA: *b2EdgeShape, xfA: *b2Transform, circleB: *b2CircleShape, xfB: *b2Transform) -> void #foreign box2d "?b2CollideEdgeAndCircle@@YAXPEAUb2Manifold@@PEBVb2EdgeShape@@AEBUb2Transform@@PEBVb2CircleShape@@2@Z";
b2CollideEdgeAndCircle :: (manifold: *b2Manifold, polygonA: *b2EdgeShape, xfA: b2Transform, circleB: *b2CircleShape, xfB: b2Transform) #no_context {
    b2CollideEdgeAndCircle(manifold, polygonA, *xfA, circleB, *xfB);
}

/// Compute the collision manifold between an edge and a polygon.
b2CollideEdgeAndPolygon :: (manifold: *b2Manifold, edgeA: *b2EdgeShape, xfA: *b2Transform, circleB: *b2PolygonShape, xfB: *b2Transform) -> void #foreign box2d "?b2CollideEdgeAndPolygon@@YAXPEAUb2Manifold@@PEBVb2EdgeShape@@AEBUb2Transform@@PEBVb2PolygonShape@@2@Z";
b2CollideEdgeAndPolygon :: (manifold: *b2Manifold, edgeA: *b2EdgeShape, xfA: b2Transform, circleB: *b2PolygonShape, xfB: b2Transform) #no_context {
    b2CollideEdgeAndPolygon(manifold, edgeA, *xfA, circleB, *xfB);
}

/// Clipping for contact manifolds.
b2ClipSegmentToLine :: (vOut: *[2] b2ClipVertex, vIn: *[2] b2ClipVertex, normal: *b2Vec2, offset: float, vertexIndexA: int32) -> int32 #foreign box2d "?b2ClipSegmentToLine@@YAHQEAUb2ClipVertex@@QEBU1@AEBUb2Vec2@@MH@Z";
b2ClipSegmentToLine :: (vOut: *[2] b2ClipVertex, vIn: *[2] b2ClipVertex, normal: b2Vec2, offset: float, vertexIndexA: int32) -> int32 #no_context {
    return b2ClipSegmentToLine(vOut, vIn, *normal, offset, vertexIndexA);
}

/// Determine if two generic shapes overlap.
b2TestOverlap :: (shapeA: *b2Shape, indexA: int32, shapeB: *b2Shape, indexB: int32, xfA: *b2Transform, xfB: *b2Transform) -> bool #foreign box2d "?b2TestOverlap@@YA_NPEBVb2Shape@@H0HAEBUb2Transform@@1@Z";
b2TestOverlap :: (shapeA: *b2Shape, indexA: int32, shapeB: *b2Shape, indexB: int32, xfA: b2Transform, xfB: b2Transform) -> bool #no_context {
    return b2TestOverlap(shapeA, indexA, shapeB, indexB, *xfA, *xfB);
}

/// This holds the mass data computed for a shape.
b2MassData :: struct {
    /// The mass of the shape, usually in kilograms.
    mass:   float;

    /// The position of the shape's centroid relative to the shape's origin.
    center: b2Vec2;

    /// The rotational inertia of the shape about the local origin.
    I:      float;
}

/// @file
/// Structures and functions used for computing contact points, distance
/// queries, and TOI queries.
b2Shape :: struct {
    vtable: *b2Shape_VTable;
    Type :: enum s32 {
        circle    :: 0;
        edge      :: 1;
        polygon   :: 2;
        chain     :: 3;
        typeCount :: 4;

        e_circle    :: circle;
        e_edge      :: edge;
        e_polygon   :: polygon;
        e_chain     :: chain;
        e_typeCount :: typeCount;
    }

    /// Get the type of this shape. You can use this to down cast to the concrete shape.
    /// @return the shape type.
    GetType :: (this: *b2Shape) -> Type #cpp_method #foreign box2d "?GetType@b2Shape@@QEBA?AW4Type@1@XZ";

    m_type:   Type;

    /// Radius of a shape. For polygonal shapes this must be b2_polygonRadius. There is no support for
    /// making rounded polygons.
    m_radius: float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_Destructor :: (this: *b2Shape, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2Shape@@UEAA@XZ";
}
b2Shape_VTable :: struct #type_info_none {
    Destructor: (this: *b2Shape, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    Clone: (this: *b2Shape, allocator: *b2BlockAllocator) -> *b2Shape #cpp_method;

    GetChildCount: (this: *b2Shape) -> int32 #cpp_method;

    TestPoint: (this: *b2Shape, xf: *b2Transform, p: *b2Vec2) -> bool #cpp_method;

    RayCast: (this: *b2Shape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool #cpp_method;

    ComputeAABB: (this: *b2Shape, aabb: *b2AABB, xf: *b2Transform, childIndex: int32) -> void #cpp_method;

    ComputeMass: (this: *b2Shape, massData: *b2MassData, density: float) -> void #cpp_method;
}

b2Shape_Destructor :: inline (this: *b2Shape, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2Shape_Clone :: inline (this: *b2Shape, allocator: *b2BlockAllocator) -> *b2Shape { return this.vtable.Clone(this, allocator); }

b2Shape_GetChildCount :: inline (this: *b2Shape) -> int32 { return this.vtable.GetChildCount(this); }

b2Shape_TestPoint :: inline (this: *b2Shape, xf: *b2Transform, p: *b2Vec2) -> bool { return this.vtable.TestPoint(this, xf, p); }

b2Shape_RayCast :: inline (this: *b2Shape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool { return this.vtable.RayCast(this, output, input, transform, childIndex); }

b2Shape_ComputeAABB :: inline (this: *b2Shape, aabb: *b2AABB, xf: *b2Transform, childIndex: int32) { this.vtable.ComputeAABB(this, aabb, xf, childIndex); }

b2Shape_ComputeMass :: inline (this: *b2Shape, massData: *b2MassData, density: float) { this.vtable.ComputeMass(this, massData, density); }

vtable :: (obj: *b2Shape) -> *b2Shape_VTable { return obj.vtable; }


b2Controller :: struct {}

/// The body type.
/// static: zero mass, zero velocity, may be manually moved
/// kinematic: zero mass, non-zero velocity set by user, moved by solver
/// dynamic: positive mass, non-zero velocity determined by forces, moved by solver
b2BodyType :: enum s32 {
    staticBody    :: 0;
    kinematicBody :: 1;
    dynamicBody   :: 2;

    b2_staticBody    :: staticBody;
    b2_kinematicBody :: kinematicBody;
    b2_dynamicBody   :: dynamicBody;
}

/// A body definition holds all the data needed to construct a rigid body.
/// You can safely re-use body definitions. Shapes are added to a body after construction.
b2BodyDef :: struct {
    /// This constructor sets the body definition default values.
    Constructor :: (this: *b2BodyDef) -> void #cpp_method #foreign box2d "??0b2BodyDef@@QEAA@XZ";

    /// The body type: static, kinematic, or dynamic.
    /// Note: if a dynamic body would have zero mass, the mass is set to one.
    type:            b2BodyType;

    /// The world position of the body. Avoid creating bodies at the origin
    /// since this can lead to many overlapping shapes.
    position:        b2Vec2;

    /// The world angle of the body in radians.
    angle:           float;

    /// The linear velocity of the body's origin in world co-ordinates.
    linearVelocity:  b2Vec2;

    /// The angular velocity of the body.
    angularVelocity: float;

    /// Linear damping is use to reduce the linear velocity. The damping parameter
    /// can be larger than 1.0f but the damping effect becomes sensitive to the
    /// time step when the damping parameter is large.
    /// Units are 1/time
    linearDamping:   float;

    /// Angular damping is use to reduce the angular velocity. The damping parameter
    /// can be larger than 1.0f but the damping effect becomes sensitive to the
    /// time step when the damping parameter is large.
    /// Units are 1/time
    angularDamping:  float;

    /// Set this flag to false if this body should never fall asleep. Note that
    /// this increases CPU usage.
    allowSleep:      bool;

    /// Is this body initially awake or sleeping?
    awake:           bool;

    /// Should this body be prevented from rotating? Useful for characters.
    fixedRotation:   bool;

    /// Is this a fast moving body that should be prevented from tunneling through
    /// other moving bodies? Note that all bodies are prevented from tunneling through
    /// kinematic and static bodies. This setting is only considered on dynamic bodies.
    /// @warning You should use this flag sparingly since it increases processing time.
    bullet:          bool;

    /// Does this body start out enabled?
    enabled:         bool;

    /// Use this to store application specific body data.
    userData:        b2BodyUserData;

    /// Scale the gravity applied to this body.
    gravityScale:    float;
}

/// A rigid body. These are created via b2World::CreateBody.
b2Body :: struct {
    /// Creates a fixture and attach it to this body. Use this function if you need
    /// to set some fixture parameters, like friction. Otherwise you can create the
    /// fixture directly from a shape.
    /// If the density is non-zero, this function automatically updates the mass of the body.
    /// Contacts are not created until the next time step.
    /// @param def the fixture definition.
    /// @warning This function is locked during callbacks.
    CreateFixture :: (this: *b2Body, def: *b2FixtureDef) -> *b2Fixture #cpp_method #foreign box2d "?CreateFixture@b2Body@@QEAAPEAVb2Fixture@@PEBUb2FixtureDef@@@Z";

    /// Creates a fixture from a shape and attach it to this body.
    /// This is a convenience function. Use b2FixtureDef if you need to set parameters
    /// like friction, restitution, user data, or filtering.
    /// If the density is non-zero, this function automatically updates the mass of the body.
    /// @param shape the shape to be cloned.
    /// @param density the shape density (set to zero for static bodies).
    /// @warning This function is locked during callbacks.
    CreateFixture :: (this: *b2Body, shape: *b2Shape, density: float) -> *b2Fixture #cpp_method #foreign box2d "?CreateFixture@b2Body@@QEAAPEAVb2Fixture@@PEBVb2Shape@@M@Z";

    /// Destroy a fixture. This removes the fixture from the broad-phase and
    /// destroys all contacts associated with this fixture. This will
    /// automatically adjust the mass of the body if the body is dynamic and the
    /// fixture has positive density.
    /// All fixtures attached to a body are implicitly destroyed when the body is destroyed.
    /// @param fixture the fixture to be removed.
    /// @warning This function is locked during callbacks.
    DestroyFixture :: (this: *b2Body, fixture: *b2Fixture) -> void #cpp_method #foreign box2d "?DestroyFixture@b2Body@@QEAAXPEAVb2Fixture@@@Z";

    /// Set the position of the body's origin and rotation.
    /// Manipulating a body's transform may cause non-physical behavior.
    /// Note: contacts are updated on the next call to b2World::Step.
    /// @param position the world position of the body's local origin.
    /// @param angle the world rotation in radians.
    SetTransform :: (this: *b2Body, position: *b2Vec2, angle: float) -> void #cpp_method #foreign box2d "?SetTransform@b2Body@@QEAAXAEBUb2Vec2@@M@Z";
    SetTransform :: (this: *b2Body, position: b2Vec2, angle: float) #no_context {
        SetTransform(this, *position, angle);
    }

    /// Get the body transform for the body's origin.
    /// @return the world transform of the body's origin.
    GetTransform :: (this: *b2Body) -> *b2Transform #cpp_method #foreign box2d "?GetTransform@b2Body@@QEBAAEBUb2Transform@@XZ";

    /// Get the world body origin position.
    /// @return the world position of the body's origin.
    GetPosition :: (this: *b2Body) -> *b2Vec2 #cpp_method #foreign box2d "?GetPosition@b2Body@@QEBAAEBUb2Vec2@@XZ";

    /// Get the angle in radians.
    /// @return the current world rotation angle in radians.
    GetAngle :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetAngle@b2Body@@QEBAMXZ";

    /// Get the world position of the center of mass.
    GetWorldCenter :: (this: *b2Body) -> *b2Vec2 #cpp_method #foreign box2d "?GetWorldCenter@b2Body@@QEBAAEBUb2Vec2@@XZ";

    /// Get the local position of the center of mass.
    GetLocalCenter :: (this: *b2Body) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalCenter@b2Body@@QEBAAEBUb2Vec2@@XZ";

    /// Set the linear velocity of the center of mass.
    /// @param v the new linear velocity of the center of mass.
    SetLinearVelocity :: (this: *b2Body, v: *b2Vec2) -> void #cpp_method #foreign box2d "?SetLinearVelocity@b2Body@@QEAAXAEBUb2Vec2@@@Z";
    SetLinearVelocity :: (this: *b2Body, v: b2Vec2) #no_context {
        SetLinearVelocity(this, *v);
    }

    /// Get the linear velocity of the center of mass.
    /// @return the linear velocity of the center of mass.
    GetLinearVelocity :: (this: *b2Body) -> *b2Vec2 #cpp_method #foreign box2d "?GetLinearVelocity@b2Body@@QEBAAEBUb2Vec2@@XZ";

    /// Set the angular velocity.
    /// @param omega the new angular velocity in radians/second.
    SetAngularVelocity :: (this: *b2Body, omega: float) -> void #cpp_method #foreign box2d "?SetAngularVelocity@b2Body@@QEAAXM@Z";

    /// Get the angular velocity.
    /// @return the angular velocity in radians/second.
    GetAngularVelocity :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetAngularVelocity@b2Body@@QEBAMXZ";

    /// Apply a force at a world point. If the force is not
    /// applied at the center of mass, it will generate a torque and
    /// affect the angular velocity. This wakes up the body.
    /// @param force the world force vector, usually in Newtons (N).
    /// @param point the world position of the point of application.
    /// @param wake also wake up the body
    ApplyForce :: (this: *b2Body, force: *b2Vec2, point: *b2Vec2, wake: bool) -> void #cpp_method #foreign box2d "?ApplyForce@b2Body@@QEAAXAEBUb2Vec2@@0_N@Z";
    ApplyForce :: (this: *b2Body, force: b2Vec2, point: b2Vec2, wake: bool) #no_context {
        ApplyForce(this, *force, *point, wake);
    }

    /// Apply a force to the center of mass. This wakes up the body.
    /// @param force the world force vector, usually in Newtons (N).
    /// @param wake also wake up the body
    ApplyForceToCenter :: (this: *b2Body, force: *b2Vec2, wake: bool) -> void #cpp_method #foreign box2d "?ApplyForceToCenter@b2Body@@QEAAXAEBUb2Vec2@@_N@Z";
    ApplyForceToCenter :: (this: *b2Body, force: b2Vec2, wake: bool) #no_context {
        ApplyForceToCenter(this, *force, wake);
    }

    /// Apply a torque. This affects the angular velocity
    /// without affecting the linear velocity of the center of mass.
    /// @param torque about the z-axis (out of the screen), usually in N-m.
    /// @param wake also wake up the body
    ApplyTorque :: (this: *b2Body, torque: float, wake: bool) -> void #cpp_method #foreign box2d "?ApplyTorque@b2Body@@QEAAXM_N@Z";

    /// Apply an impulse at a point. This immediately modifies the velocity.
    /// It also modifies the angular velocity if the point of application
    /// is not at the center of mass. This wakes up the body.
    /// @param impulse the world impulse vector, usually in N-seconds or kg-m/s.
    /// @param point the world position of the point of application.
    /// @param wake also wake up the body
    ApplyLinearImpulse :: (this: *b2Body, impulse: *b2Vec2, point: *b2Vec2, wake: bool) -> void #cpp_method #foreign box2d "?ApplyLinearImpulse@b2Body@@QEAAXAEBUb2Vec2@@0_N@Z";
    ApplyLinearImpulse :: (this: *b2Body, impulse: b2Vec2, point: b2Vec2, wake: bool) #no_context {
        ApplyLinearImpulse(this, *impulse, *point, wake);
    }

    /// Apply an impulse to the center of mass. This immediately modifies the velocity.
    /// @param impulse the world impulse vector, usually in N-seconds or kg-m/s.
    /// @param wake also wake up the body
    ApplyLinearImpulseToCenter :: (this: *b2Body, impulse: *b2Vec2, wake: bool) -> void #cpp_method #foreign box2d "?ApplyLinearImpulseToCenter@b2Body@@QEAAXAEBUb2Vec2@@_N@Z";
    ApplyLinearImpulseToCenter :: (this: *b2Body, impulse: b2Vec2, wake: bool) #no_context {
        ApplyLinearImpulseToCenter(this, *impulse, wake);
    }

    /// Apply an angular impulse.
    /// @param impulse the angular impulse in units of kg*m*m/s
    /// @param wake also wake up the body
    ApplyAngularImpulse :: (this: *b2Body, impulse: float, wake: bool) -> void #cpp_method #foreign box2d "?ApplyAngularImpulse@b2Body@@QEAAXM_N@Z";

    /// Get the total mass of the body.
    /// @return the mass, usually in kilograms (kg).
    GetMass :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetMass@b2Body@@QEBAMXZ";

    /// Get the rotational inertia of the body about the local origin.
    /// @return the rotational inertia, usually in kg-m^2.
    GetInertia :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetInertia@b2Body@@QEBAMXZ";

    /// Get the mass data of the body.
    /// @return a struct containing the mass, inertia and center of the body.
    GetMassData :: (this: *b2Body, data: *b2MassData) -> void #cpp_method #foreign box2d "?GetMassData@b2Body@@QEBAXPEAUb2MassData@@@Z";

    /// Set the mass properties to override the mass properties of the fixtures.
    /// Note that this changes the center of mass position.
    /// Note that creating or destroying fixtures can also alter the mass.
    /// This function has no effect if the body isn't dynamic.
    /// @param data the mass properties.
    SetMassData :: (this: *b2Body, data: *b2MassData) -> void #cpp_method #foreign box2d "?SetMassData@b2Body@@QEAAXPEBUb2MassData@@@Z";

    /// This resets the mass properties to the sum of the mass properties of the fixtures.
    /// This normally does not need to be called unless you called SetMassData to override
    /// the mass and you later want to reset the mass.
    ResetMassData :: (this: *b2Body) -> void #cpp_method #foreign box2d "?ResetMassData@b2Body@@QEAAXXZ";

    /// Get the world coordinates of a point given the local coordinates.
    /// @param localPoint a point on the body measured relative the the body's origin.
    /// @return the same point expressed in world coordinates.
    GetWorldPoint :: (this: *b2Body, localPoint: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetWorldPoint@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetWorldPoint :: (this: *b2Body, localPoint: b2Vec2) -> b2Vec2 #no_context {
        return GetWorldPoint(this, *localPoint);
    }

    /// Get the world coordinates of a vector given the local coordinates.
    /// @param localVector a vector fixed in the body.
    /// @return the same vector expressed in world coordinates.
    GetWorldVector :: (this: *b2Body, localVector: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetWorldVector@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetWorldVector :: (this: *b2Body, localVector: b2Vec2) -> b2Vec2 #no_context {
        return GetWorldVector(this, *localVector);
    }

    /// Gets a local point relative to the body's origin given a world point.
    /// @param worldPoint a point in world coordinates.
    /// @return the corresponding local point relative to the body's origin.
    GetLocalPoint :: (this: *b2Body, worldPoint: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetLocalPoint@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetLocalPoint :: (this: *b2Body, worldPoint: b2Vec2) -> b2Vec2 #no_context {
        return GetLocalPoint(this, *worldPoint);
    }

    /// Gets a local vector given a world vector.
    /// @param worldVector a vector in world coordinates.
    /// @return the corresponding local vector.
    GetLocalVector :: (this: *b2Body, worldVector: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetLocalVector@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetLocalVector :: (this: *b2Body, worldVector: b2Vec2) -> b2Vec2 #no_context {
        return GetLocalVector(this, *worldVector);
    }

    /// Get the world linear velocity of a world point attached to this body.
    /// @param worldPoint a point in world coordinates.
    /// @return the world velocity of a point.
    GetLinearVelocityFromWorldPoint :: (this: *b2Body, worldPoint: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetLinearVelocityFromWorldPoint@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetLinearVelocityFromWorldPoint :: (this: *b2Body, worldPoint: b2Vec2) -> b2Vec2 #no_context {
        return GetLinearVelocityFromWorldPoint(this, *worldPoint);
    }

    /// Get the world velocity of a local point.
    /// @param localPoint a point in local coordinates.
    /// @return the world velocity of a point.
    GetLinearVelocityFromLocalPoint :: (this: *b2Body, localPoint: *b2Vec2) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetLinearVelocityFromLocalPoint@b2Body@@QEBA?AUb2Vec2@@AEBU2@@Z";
    GetLinearVelocityFromLocalPoint :: (this: *b2Body, localPoint: b2Vec2) -> b2Vec2 #no_context {
        return GetLinearVelocityFromLocalPoint(this, *localPoint);
    }

    /// Get the linear damping of the body.
    GetLinearDamping :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetLinearDamping@b2Body@@QEBAMXZ";

    /// Set the linear damping of the body.
    SetLinearDamping :: (this: *b2Body, linearDamping: float) -> void #cpp_method #foreign box2d "?SetLinearDamping@b2Body@@QEAAXM@Z";

    /// Get the angular damping of the body.
    GetAngularDamping :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetAngularDamping@b2Body@@QEBAMXZ";

    /// Set the angular damping of the body.
    SetAngularDamping :: (this: *b2Body, angularDamping: float) -> void #cpp_method #foreign box2d "?SetAngularDamping@b2Body@@QEAAXM@Z";

    /// Get the gravity scale of the body.
    GetGravityScale :: (this: *b2Body) -> float #cpp_method #foreign box2d "?GetGravityScale@b2Body@@QEBAMXZ";

    /// Set the gravity scale of the body.
    SetGravityScale :: (this: *b2Body, scale: float) -> void #cpp_method #foreign box2d "?SetGravityScale@b2Body@@QEAAXM@Z";

    /// Set the type of this body. This may alter the mass and velocity.
    SetType :: (this: *b2Body, type: b2BodyType) -> void #cpp_method #foreign box2d "?SetType@b2Body@@QEAAXW4b2BodyType@@@Z";

    /// Get the type of this body.
    GetType :: (this: *b2Body) -> b2BodyType #cpp_method #foreign box2d "?GetType@b2Body@@QEBA?AW4b2BodyType@@XZ";

    /// Should this body be treated like a bullet for continuous collision detection?
    SetBullet :: (this: *b2Body, flag: bool) -> void #cpp_method #foreign box2d "?SetBullet@b2Body@@QEAAX_N@Z";

    /// Is this body treated like a bullet for continuous collision detection?
    IsBullet :: (this: *b2Body) -> bool #cpp_method #foreign box2d "?IsBullet@b2Body@@QEBA_NXZ";

    /// You can disable sleeping on this body. If you disable sleeping, the
    /// body will be woken.
    SetSleepingAllowed :: (this: *b2Body, flag: bool) -> void #cpp_method #foreign box2d "?SetSleepingAllowed@b2Body@@QEAAX_N@Z";

    /// Is this body allowed to sleep
    IsSleepingAllowed :: (this: *b2Body) -> bool #cpp_method #foreign box2d "?IsSleepingAllowed@b2Body@@QEBA_NXZ";

    /// Set the sleep state of the body. A sleeping body has very
    /// low CPU cost.
    /// @param flag set to true to wake the body, false to put it to sleep.
    SetAwake :: (this: *b2Body, flag: bool) -> void #cpp_method #foreign box2d "?SetAwake@b2Body@@QEAAX_N@Z";

    /// Get the sleeping state of this body.
    /// @return true if the body is awake.
    IsAwake :: (this: *b2Body) -> bool #cpp_method #foreign box2d "?IsAwake@b2Body@@QEBA_NXZ";

    /// Allow a body to be disabled. A disabled body is not simulated and cannot
    /// be collided with or woken up.
    /// If you pass a flag of true, all fixtures will be added to the broad-phase.
    /// If you pass a flag of false, all fixtures will be removed from the
    /// broad-phase and all contacts will be destroyed.
    /// Fixtures and joints are otherwise unaffected. You may continue
    /// to create/destroy fixtures and joints on disabled bodies.
    /// Fixtures on a disabled body are implicitly disabled and will
    /// not participate in collisions, ray-casts, or queries.
    /// Joints connected to a disabled body are implicitly disabled.
    /// An diabled body is still owned by a b2World object and remains
    /// in the body list.
    SetEnabled :: (this: *b2Body, flag: bool) -> void #cpp_method #foreign box2d "?SetEnabled@b2Body@@QEAAX_N@Z";

    /// Get the active state of the body.
    IsEnabled :: (this: *b2Body) -> bool #cpp_method #foreign box2d "?IsEnabled@b2Body@@QEBA_NXZ";

    /// Set this body to have fixed rotation. This causes the mass
    /// to be reset.
    SetFixedRotation :: (this: *b2Body, flag: bool) -> void #cpp_method #foreign box2d "?SetFixedRotation@b2Body@@QEAAX_N@Z";

    /// Does this body have fixed rotation?
    IsFixedRotation :: (this: *b2Body) -> bool #cpp_method #foreign box2d "?IsFixedRotation@b2Body@@QEBA_NXZ";

    /// Get the list of all fixtures attached to this body.
    GetFixtureList :: (this: *b2Body) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureList@b2Body@@QEAAPEAVb2Fixture@@XZ";

    GetFixtureList_1 :: (this: /*const*/ *b2Body) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureList@b2Body@@QEBAPEBVb2Fixture@@XZ";

    /// Get the list of all joints attached to this body.
    GetJointList :: (this: *b2Body) -> *b2JointEdge #cpp_method #foreign box2d "?GetJointList@b2Body@@QEAAPEAUb2JointEdge@@XZ";

    GetJointList_1 :: (this: /*const*/ *b2Body) -> *b2JointEdge #cpp_method #foreign box2d "?GetJointList@b2Body@@QEBAPEBUb2JointEdge@@XZ";

    /// Get the list of all contacts attached to this body.
    /// @warning this list changes during the time step and you may
    /// miss some collisions if you don't use b2ContactListener.
    GetContactList :: (this: *b2Body) -> *b2ContactEdge #cpp_method #foreign box2d "?GetContactList@b2Body@@QEAAPEAUb2ContactEdge@@XZ";

    GetContactList_1 :: (this: /*const*/ *b2Body) -> *b2ContactEdge #cpp_method #foreign box2d "?GetContactList@b2Body@@QEBAPEBUb2ContactEdge@@XZ";

    /// Get the next body in the world's body list.
    GetNext :: (this: *b2Body) -> *b2Body #cpp_method #foreign box2d "?GetNext@b2Body@@QEAAPEAV1@XZ";

    GetNext_1 :: (this: /*const*/ *b2Body) -> *b2Body #cpp_method #foreign box2d "?GetNext@b2Body@@QEBAPEBV1@XZ";

    /// Get the user data pointer that was provided in the body definition.
    GetUserData :: (this: *b2Body) -> *b2BodyUserData #cpp_method #foreign box2d "?GetUserData@b2Body@@QEAAAEAUb2BodyUserData@@XZ";

    /// Get the parent world of this body.
    GetWorld :: (this: *b2Body) -> *b2World #cpp_method #foreign box2d "?GetWorld@b2Body@@QEAAPEAVb2World@@XZ";

    GetWorld_1 :: (this: /*const*/ *b2Body) -> *b2World #cpp_method #foreign box2d "?GetWorld@b2Body@@QEBAPEBVb2World@@XZ";

    /// Dump this body to a file
    Dump :: (this: *b2Body) -> void #cpp_method #foreign box2d "?Dump@b2Body@@QEAAXXZ";

    // m_flags
    e :: enum s32 {
        islandFlag        :: 1;
        awakeFlag         :: 2;
        autoSleepFlag     :: 4;
        bulletFlag        :: 8;
        fixedRotationFlag :: 16;
        enabledFlag       :: 32;
        toiFlag           :: 64;

        e_islandFlag        :: islandFlag;
        e_awakeFlag         :: awakeFlag;
        e_autoSleepFlag     :: autoSleepFlag;
        e_bulletFlag        :: bulletFlag;
        e_fixedRotationFlag :: fixedRotationFlag;
        e_enabledFlag       :: enabledFlag;
        e_toiFlag           :: toiFlag;
    }

    Constructor :: (this: *b2Body, bd: *b2BodyDef, world: *b2World) -> void #cpp_method #foreign box2d "??0b2Body@@AEAA@PEBUb2BodyDef@@PEAVb2World@@@Z";
    Destructor :: (this: *b2Body) -> void #cpp_method #foreign box2d "??1b2Body@@AEAA@XZ";

    SynchronizeFixtures :: (this: *b2Body) -> void #cpp_method #foreign box2d "?SynchronizeFixtures@b2Body@@AEAAXXZ";

    SynchronizeTransform :: (this: *b2Body) -> void #cpp_method #foreign box2d "?SynchronizeTransform@b2Body@@AEAAXXZ";

    // This is used to prevent connected bodies from colliding.
    // It may lie, depending on the collideConnected flag.
    ShouldCollide :: (this: *b2Body, other: *b2Body) -> bool #cpp_method #foreign box2d "?ShouldCollide@b2Body@@AEBA_NPEBV1@@Z";

    Advance :: (this: *b2Body, t: float) -> void #cpp_method #foreign box2d "?Advance@b2Body@@AEAAXM@Z";

    m_type:            b2BodyType;

    m_flags:           uint16;

    m_islandIndex:     int32;

    m_xf:              b2Transform; // the body origin transform
    m_sweep:           b2Sweep; // the swept motion for CCD

    m_linearVelocity:  b2Vec2;
    m_angularVelocity: float;

    m_force:           b2Vec2;
    m_torque:          float;

    m_world:           *b2World;
    m_prev:            *b2Body;
    m_next:            *b2Body;

    m_fixtureList:     *b2Fixture;
    m_fixtureCount:    int32;

    m_jointList:       *b2JointEdge;
    m_contactList:     *b2ContactEdge;

    m_mass:            float;
    m_invMass:         float;

    // Rotational inertia about the center of mass.
    m_I:               float;
    // Rotational inertia about the center of mass.
    m_invI:            float;

    m_linearDamping:   float;
    m_angularDamping:  float;
    m_gravityScale:    float;

    m_sleepTime:       float;

    m_userData:        b2BodyUserData;
}

/// This is a growable LIFO stack with an initial capacity of N.
/// If the stack size exceeds the initial capacity, the heap is used
/// to increase the size of the stack.
b2GrowableStack :: struct(T: Type, N: int32) {
    m_stack:    *T;
    m_array:    [T] T;
    m_count:    int32;
    m_capacity: int32;
}

/// A node in the dynamic tree. The client does not interact with this directly.
b2TreeNode :: struct {
    IsLeaf :: (this: *b2TreeNode) -> bool #cpp_method #foreign box2d "?IsLeaf@b2TreeNode@@QEBA_NXZ";

    /// Enlarged AABB
    aabb:     b2AABB;

    userData: *void;

    union {
        parent: int32;
        next:   int32;
    }

    child1:   int32;
    child2:   int32;

    // leaf = 0, free node = -1
    height:   int32;

    moved:    bool;
}

/// A dynamic AABB tree broad-phase, inspired by Nathanael Presson's btDbvt.
/// A dynamic tree arranges data in a binary tree to accelerate
/// queries such as volume queries and ray casts. Leafs are proxies
/// with an AABB. In the tree we expand the proxy AABB by b2_fatAABBFactor
/// so that the proxy AABB is bigger than the client object. This allows the client
/// object to move by small amounts without triggering a tree update.
///
/// Nodes are pooled and relocatable, so we use node indices rather than pointers.
b2DynamicTree :: struct {
    /// Constructing the tree initializes the node pool.
    Constructor :: (this: *b2DynamicTree) -> void #cpp_method #foreign box2d "??0b2DynamicTree@@QEAA@XZ";

    /// Destroy the tree, freeing the node pool.
    Destructor :: (this: *b2DynamicTree) -> void #cpp_method #foreign box2d "??1b2DynamicTree@@QEAA@XZ";

    /// Create a proxy. Provide a tight fitting AABB and a userData pointer.
    CreateProxy :: (this: *b2DynamicTree, aabb: *b2AABB, userData: *void) -> int32 #cpp_method #foreign box2d "?CreateProxy@b2DynamicTree@@QEAAHAEBUb2AABB@@PEAX@Z";
    CreateProxy :: (this: *b2DynamicTree, aabb: b2AABB, userData: *void) -> int32 #no_context {
        return CreateProxy(this, *aabb, userData);
    }

    /// Destroy a proxy. This asserts if the id is invalid.
    DestroyProxy :: (this: *b2DynamicTree, proxyId: int32) -> void #cpp_method #foreign box2d "?DestroyProxy@b2DynamicTree@@QEAAXH@Z";

    /// Move a proxy with a swepted AABB. If the proxy has moved outside of its fattened AABB,
    /// then the proxy is removed from the tree and re-inserted. Otherwise
    /// the function returns immediately.
    /// @return true if the proxy was re-inserted.
    MoveProxy :: (this: *b2DynamicTree, proxyId: int32, aabb1: *b2AABB, displacement: *b2Vec2) -> bool #cpp_method #foreign box2d "?MoveProxy@b2DynamicTree@@QEAA_NHAEBUb2AABB@@AEBUb2Vec2@@@Z";
    MoveProxy :: (this: *b2DynamicTree, proxyId: int32, aabb1: b2AABB, displacement: b2Vec2) -> bool #no_context {
        return MoveProxy(this, proxyId, *aabb1, *displacement);
    }

    /// Get proxy user data.
    /// @return the proxy user data or 0 if the id is invalid.
    GetUserData :: (this: *b2DynamicTree, proxyId: int32) -> *void #cpp_method #foreign box2d "?GetUserData@b2DynamicTree@@QEBAPEAXH@Z";

    WasMoved :: (this: *b2DynamicTree, proxyId: int32) -> bool #cpp_method #foreign box2d "?WasMoved@b2DynamicTree@@QEBA_NH@Z";

    ClearMoved :: (this: *b2DynamicTree, proxyId: int32) -> void #cpp_method #foreign box2d "?ClearMoved@b2DynamicTree@@QEAAXH@Z";

    /// Get the fat AABB for a proxy.
    GetFatAABB :: (this: *b2DynamicTree, proxyId: int32) -> *b2AABB #cpp_method #foreign box2d "?GetFatAABB@b2DynamicTree@@QEBAAEBUb2AABB@@H@Z";

    /// Validate this tree. For testing.
    Validate :: (this: *b2DynamicTree) -> void #cpp_method #foreign box2d "?Validate@b2DynamicTree@@QEBAXXZ";

    /// Compute the height of the binary tree in O(N) time. Should not be
    /// called often.
    GetHeight :: (this: *b2DynamicTree) -> int32 #cpp_method #foreign box2d "?GetHeight@b2DynamicTree@@QEBAHXZ";

    /// Get the maximum balance of an node in the tree. The balance is the difference
    /// in height of the two children of a node.
    GetMaxBalance :: (this: *b2DynamicTree) -> int32 #cpp_method #foreign box2d "?GetMaxBalance@b2DynamicTree@@QEBAHXZ";

    /// Get the ratio of the sum of the node areas to the root area.
    GetAreaRatio :: (this: *b2DynamicTree) -> float #cpp_method #foreign box2d "?GetAreaRatio@b2DynamicTree@@QEBAMXZ";

    /// Build an optimal tree. Very expensive. For testing.
    RebuildBottomUp :: (this: *b2DynamicTree) -> void #cpp_method #foreign box2d "?RebuildBottomUp@b2DynamicTree@@QEAAXXZ";

    /// Shift the world origin. Useful for large worlds.
    /// The shift formula is: position -= newOrigin
    /// @param newOrigin the new origin with respect to the old origin
    ShiftOrigin :: (this: *b2DynamicTree, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2DynamicTree@@QEAAXAEBUb2Vec2@@@Z";
    ShiftOrigin :: (this: *b2DynamicTree, newOrigin: b2Vec2) #no_context {
        ShiftOrigin(this, *newOrigin);
    }

    AllocateNode :: (this: *b2DynamicTree) -> int32 #cpp_method #foreign box2d "?AllocateNode@b2DynamicTree@@AEAAHXZ";
    FreeNode :: (this: *b2DynamicTree, node: int32) -> void #cpp_method #foreign box2d "?FreeNode@b2DynamicTree@@AEAAXH@Z";

    InsertLeaf :: (this: *b2DynamicTree, node: int32) -> void #cpp_method #foreign box2d "?InsertLeaf@b2DynamicTree@@AEAAXH@Z";
    RemoveLeaf :: (this: *b2DynamicTree, node: int32) -> void #cpp_method #foreign box2d "?RemoveLeaf@b2DynamicTree@@AEAAXH@Z";

    Balance :: (this: *b2DynamicTree, index: int32) -> int32 #cpp_method #foreign box2d "?Balance@b2DynamicTree@@AEAAHH@Z";

    ComputeHeight :: (this: *b2DynamicTree) -> int32 #cpp_method #foreign box2d "?ComputeHeight@b2DynamicTree@@AEBAHXZ";
    ComputeHeight :: (this: *b2DynamicTree, nodeId: int32) -> int32 #cpp_method #foreign box2d "?ComputeHeight@b2DynamicTree@@AEBAHH@Z";

    ValidateStructure :: (this: *b2DynamicTree, index: int32) -> void #cpp_method #foreign box2d "?ValidateStructure@b2DynamicTree@@AEBAXH@Z";
    ValidateMetrics :: (this: *b2DynamicTree, index: int32) -> void #cpp_method #foreign box2d "?ValidateMetrics@b2DynamicTree@@AEBAXH@Z";

    m_root:           int32;

    m_nodes:          *b2TreeNode;
    m_nodeCount:      int32;
    m_nodeCapacity:   int32;

    m_freeList:       int32;

    m_insertionCount: int32;
}

b2Pair :: struct {
    proxyIdA: int32;
    proxyIdB: int32;
}

/// The broad-phase is used for computing pairs and performing volume queries and ray casts.
/// This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
/// It is up to the client to consume the new pairs and to track subsequent overlap.
b2BroadPhase :: struct {
    anon_enum_1 :: enum s32 {
        e_nullProxy :: -1;
    }

    Constructor :: (this: *b2BroadPhase) -> void #cpp_method #foreign box2d "??0b2BroadPhase@@QEAA@XZ";
    Destructor :: (this: *b2BroadPhase) -> void #cpp_method #foreign box2d "??1b2BroadPhase@@QEAA@XZ";

    /// Create a proxy with an initial AABB. Pairs are not reported until
    /// UpdatePairs is called.
    CreateProxy :: (this: *b2BroadPhase, aabb: *b2AABB, userData: *void) -> int32 #cpp_method #foreign box2d "?CreateProxy@b2BroadPhase@@QEAAHAEBUb2AABB@@PEAX@Z";
    CreateProxy :: (this: *b2BroadPhase, aabb: b2AABB, userData: *void) -> int32 #no_context {
        return CreateProxy(this, *aabb, userData);
    }

    /// Destroy a proxy. It is up to the client to remove any pairs.
    DestroyProxy :: (this: *b2BroadPhase, proxyId: int32) -> void #cpp_method #foreign box2d "?DestroyProxy@b2BroadPhase@@QEAAXH@Z";

    /// Call MoveProxy as many times as you like, then when you are done
    /// call UpdatePairs to finalized the proxy pairs (for your time step).
    MoveProxy :: (this: *b2BroadPhase, proxyId: int32, aabb: *b2AABB, displacement: *b2Vec2) -> void #cpp_method #foreign box2d "?MoveProxy@b2BroadPhase@@QEAAXHAEBUb2AABB@@AEBUb2Vec2@@@Z";
    MoveProxy :: (this: *b2BroadPhase, proxyId: int32, aabb: b2AABB, displacement: b2Vec2) #no_context {
        MoveProxy(this, proxyId, *aabb, *displacement);
    }

    /// Call to trigger a re-processing of it's pairs on the next call to UpdatePairs.
    TouchProxy :: (this: *b2BroadPhase, proxyId: int32) -> void #cpp_method #foreign box2d "?TouchProxy@b2BroadPhase@@QEAAXH@Z";

    /// Get the fat AABB for a proxy.
    GetFatAABB :: (this: *b2BroadPhase, proxyId: int32) -> *b2AABB #cpp_method #foreign box2d "?GetFatAABB@b2BroadPhase@@QEBAAEBUb2AABB@@H@Z";

    /// Get user data from a proxy. Returns nullptr if the id is invalid.
    GetUserData :: (this: *b2BroadPhase, proxyId: int32) -> *void #cpp_method #foreign box2d "?GetUserData@b2BroadPhase@@QEBAPEAXH@Z";

    /// Test overlap of fat AABBs.
    TestOverlap :: (this: *b2BroadPhase, proxyIdA: int32, proxyIdB: int32) -> bool #cpp_method #foreign box2d "?TestOverlap@b2BroadPhase@@QEBA_NHH@Z";

    /// Get the number of proxies.
    GetProxyCount :: (this: *b2BroadPhase) -> int32 #cpp_method #foreign box2d "?GetProxyCount@b2BroadPhase@@QEBAHXZ";

    /// Get the height of the embedded tree.
    GetTreeHeight :: (this: *b2BroadPhase) -> int32 #cpp_method #foreign box2d "?GetTreeHeight@b2BroadPhase@@QEBAHXZ";

    /// Get the balance of the embedded tree.
    GetTreeBalance :: (this: *b2BroadPhase) -> int32 #cpp_method #foreign box2d "?GetTreeBalance@b2BroadPhase@@QEBAHXZ";

    /// Get the quality metric of the embedded tree.
    GetTreeQuality :: (this: *b2BroadPhase) -> float #cpp_method #foreign box2d "?GetTreeQuality@b2BroadPhase@@QEBAMXZ";

    /// Shift the world origin. Useful for large worlds.
    /// The shift formula is: position -= newOrigin
    /// @param newOrigin the new origin with respect to the old origin
    ShiftOrigin :: (this: *b2BroadPhase, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2BroadPhase@@QEAAXAEBUb2Vec2@@@Z";
    ShiftOrigin :: (this: *b2BroadPhase, newOrigin: b2Vec2) #no_context {
        ShiftOrigin(this, *newOrigin);
    }

    BufferMove :: (this: *b2BroadPhase, proxyId: int32) -> void #cpp_method #foreign box2d "?BufferMove@b2BroadPhase@@AEAAXH@Z";
    UnBufferMove :: (this: *b2BroadPhase, proxyId: int32) -> void #cpp_method #foreign box2d "?UnBufferMove@b2BroadPhase@@AEAAXH@Z";

    QueryCallback :: (this: *b2BroadPhase, proxyId: int32) -> bool #cpp_method #foreign box2d "?QueryCallback@b2BroadPhase@@AEAA_NH@Z";

    m_tree:         b2DynamicTree;

    m_proxyCount:   int32;

    m_moveBuffer:   *int32;
    m_moveCapacity: int32;
    m_moveCount:    int32;

    m_pairBuffer:   *b2Pair;
    m_pairCapacity: int32;
    m_pairCount:    int32;

    m_queryProxyId: int32;
}

/// A chain shape is a free form sequence of line segments.
/// The chain has one-sided collision, with the surface normal pointing to the right of the edge.
/// This provides a counter-clockwise winding like the polygon shape.
/// Connectivity information is used to create smooth collisions.
/// @warning the chain will not collide properly if there are self-intersections.
b2ChainShape :: struct {
    #as using b2shape: b2Shape;

    Constructor :: (this: *b2ChainShape) -> void #cpp_method #foreign box2d "??0b2ChainShape@@QEAA@XZ";

    /// Clear all data.
    Clear :: (this: *b2ChainShape) -> void #cpp_method #foreign box2d "?Clear@b2ChainShape@@QEAAXXZ";

    /// Create a loop. This automatically adjusts connectivity.
    /// @param vertices an array of vertices, these are copied
    /// @param count the vertex count
    CreateLoop :: (this: *b2ChainShape, vertices: *b2Vec2, count: int32) -> void #cpp_method #foreign box2d "?CreateLoop@b2ChainShape@@QEAAXPEBUb2Vec2@@H@Z";

    /// Create a chain with ghost vertices to connect multiple chains together.
    /// @param vertices an array of vertices, these are copied
    /// @param count the vertex count
    /// @param prevVertex previous vertex from chain that connects to the start
    /// @param nextVertex next vertex from chain that connects to the end
    CreateChain :: (this: *b2ChainShape, vertices: *b2Vec2, count: int32, prevVertex: *b2Vec2, nextVertex: *b2Vec2) -> void #cpp_method #foreign box2d "?CreateChain@b2ChainShape@@QEAAXPEBUb2Vec2@@HAEBU2@1@Z";
    CreateChain :: (this: *b2ChainShape, vertices: *b2Vec2, count: int32, prevVertex: b2Vec2, nextVertex: b2Vec2) #no_context {
        CreateChain(this, vertices, count, *prevVertex, *nextVertex);
    }

    /// Get a child edge.
    GetChildEdge :: (this: *b2ChainShape, edge: *b2EdgeShape, index: int32) -> void #cpp_method #foreign box2d "?GetChildEdge@b2ChainShape@@QEBAXPEAVb2EdgeShape@@H@Z";

    /// The vertices. Owned by this class.
    m_vertices:   *b2Vec2;

    /// The vertex count.
    m_count:      int32;

    m_prevVertex: b2Vec2;
    m_nextVertex: b2Vec2;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// The destructor frees the vertices using b2Free.
    virtual_Destructor :: (this: *b2ChainShape, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2ChainShape@@UEAA@XZ";

    /// Implement b2Shape. Vertices are cloned using b2Alloc.
    virtual_Clone :: (this: *b2ChainShape, allocator: *b2BlockAllocator) -> *b2Shape #cpp_method #foreign box2d "?Clone@b2ChainShape@@UEBAPEAVb2Shape@@PEAVb2BlockAllocator@@@Z";

    /// @see b2Shape::GetChildCount
    virtual_GetChildCount :: (this: *b2ChainShape) -> int32 #cpp_method #foreign box2d "?GetChildCount@b2ChainShape@@UEBAHXZ";

    /// This always return false.
    /// @see b2Shape::TestPoint
    virtual_TestPoint :: (this: *b2ChainShape, transform: *b2Transform, p: *b2Vec2) -> bool #cpp_method #foreign box2d "?TestPoint@b2ChainShape@@UEBA_NAEBUb2Transform@@AEBUb2Vec2@@@Z";

    /// Implement b2Shape.
    virtual_RayCast :: (this: *b2ChainShape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool #cpp_method #foreign box2d "?RayCast@b2ChainShape@@UEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeAABB
    virtual_ComputeAABB :: (this: *b2ChainShape, aabb: *b2AABB, transform: *b2Transform, childIndex: int32) -> void #cpp_method #foreign box2d "?ComputeAABB@b2ChainShape@@UEBAXPEAUb2AABB@@AEBUb2Transform@@H@Z";

    /// Chains have zero mass.
    /// @see b2Shape::ComputeMass
    virtual_ComputeMass :: (this: *b2ChainShape, massData: *b2MassData, density: float) -> void #cpp_method #foreign box2d "?ComputeMass@b2ChainShape@@UEBAXPEAUb2MassData@@M@Z";
}

/// A solid circle shape
b2CircleShape :: struct {
    #as using b2shape: b2Shape;

    Constructor :: (this: *b2CircleShape) -> void #cpp_method #foreign box2d "??0b2CircleShape@@QEAA@XZ";

    /// Position
    m_p: b2Vec2;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// Implement b2Shape.
    virtual_Clone :: (this: *b2CircleShape, allocator: *b2BlockAllocator) -> *b2Shape #cpp_method #foreign box2d "?Clone@b2CircleShape@@UEBAPEAVb2Shape@@PEAVb2BlockAllocator@@@Z";

    /// @see b2Shape::GetChildCount
    virtual_GetChildCount :: (this: *b2CircleShape) -> int32 #cpp_method #foreign box2d "?GetChildCount@b2CircleShape@@UEBAHXZ";

    /// Implement b2Shape.
    virtual_TestPoint :: (this: *b2CircleShape, transform: *b2Transform, p: *b2Vec2) -> bool #cpp_method #foreign box2d "?TestPoint@b2CircleShape@@UEBA_NAEBUb2Transform@@AEBUb2Vec2@@@Z";

    /// Implement b2Shape.
    /// @note because the circle is solid, rays that start inside do not hit because the normal is
    /// not defined.
    virtual_RayCast :: (this: *b2CircleShape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool #cpp_method #foreign box2d "?RayCast@b2CircleShape@@UEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeAABB
    virtual_ComputeAABB :: (this: *b2CircleShape, aabb: *b2AABB, transform: *b2Transform, childIndex: int32) -> void #cpp_method #foreign box2d "?ComputeAABB@b2CircleShape@@UEBAXPEAUb2AABB@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeMass
    virtual_ComputeMass :: (this: *b2CircleShape, massData: *b2MassData, density: float) -> void #cpp_method #foreign box2d "?ComputeMass@b2CircleShape@@UEBAXPEAUb2MassData@@M@Z";
}

/// This holds contact filtering data.
b2Filter :: struct {
    Constructor :: (this: *b2Filter) -> void #cpp_method #foreign box2d "??0b2Filter@@QEAA@XZ";

    /// The collision category bits. Normally you would just set one bit.
    categoryBits: uint16;

    /// The collision mask bits. This states the categories that this
    /// shape would accept for collision.
    maskBits:     uint16;

    /// Collision groups allow a certain group of objects to never collide (negative)
    /// or always collide (positive). Zero means no collision group. Non-zero group
    /// filtering always wins against the mask bits.
    groupIndex:   int16;
}

/// A fixture definition is used to create a fixture. This class defines an
/// abstract fixture definition. You can reuse fixture definitions safely.
b2FixtureDef :: struct {
    /// The constructor sets the default fixture definition values.
    Constructor :: (this: *b2FixtureDef) -> void #cpp_method #foreign box2d "??0b2FixtureDef@@QEAA@XZ";

    /// The shape, this must be set. The shape will be cloned, so you
    /// can create the shape on the stack.
    shape:                *b2Shape;

    /// Use this to store application specific fixture data.
    userData:             b2FixtureUserData;

    /// The friction coefficient, usually in the range [0,1].
    friction:             float;

    /// The restitution (elasticity) usually in the range [0,1].
    restitution:          float;

    /// Restitution velocity threshold, usually in m/s. Collisions above this
    /// speed have restitution applied (will bounce).
    restitutionThreshold: float;

    /// The density, usually in kg/m^2.
    density:              float;

    /// A sensor shape collects contact information but never generates a collision
    /// response.
    isSensor:             bool;

    /// Contact filtering data.
    filter:               b2Filter;
}

/// This proxy is used internally to connect fixtures to the broad-phase.
b2FixtureProxy :: struct {
    aabb:       b2AABB;
    fixture:    *b2Fixture;
    childIndex: int32;
    proxyId:    int32;
}

/// A fixture is used to attach a shape to a body for collision detection. A fixture
/// inherits its transform from its parent. Fixtures hold additional non-geometric data
/// such as friction, collision filters, etc.
/// Fixtures are created via b2Body::CreateFixture.
/// @warning you cannot reuse fixtures.
b2Fixture :: struct {
    /// Get the type of the child shape. You can use this to down cast to the concrete shape.
    /// @return the shape type.
    GetType :: (this: *b2Fixture) -> b2Shape.Type #cpp_method #foreign box2d "?GetType@b2Fixture@@QEBA?AW4Type@b2Shape@@XZ";

    /// Get the child shape. You can modify the child shape, however you should not change the
    /// number of vertices because this will crash some collision caching mechanisms.
    /// Manipulating the shape may lead to non-physical behavior.
    GetShape :: (this: *b2Fixture) -> *b2Shape #cpp_method #foreign box2d "?GetShape@b2Fixture@@QEAAPEAVb2Shape@@XZ";

    GetShape_1 :: (this: /*const*/ *b2Fixture) -> *b2Shape #cpp_method #foreign box2d "?GetShape@b2Fixture@@QEBAPEBVb2Shape@@XZ";

    /// Set if this fixture is a sensor.
    SetSensor :: (this: *b2Fixture, sensor: bool) -> void #cpp_method #foreign box2d "?SetSensor@b2Fixture@@QEAAX_N@Z";

    /// Is this fixture a sensor (non-solid)?
    /// @return the true if the shape is a sensor.
    IsSensor :: (this: *b2Fixture) -> bool #cpp_method #foreign box2d "?IsSensor@b2Fixture@@QEBA_NXZ";

    /// Set the contact filtering data. This will not update contacts until the next time
    /// step when either parent body is active and awake.
    /// This automatically calls Refilter.
    SetFilterData :: (this: *b2Fixture, filter: *b2Filter) -> void #cpp_method #foreign box2d "?SetFilterData@b2Fixture@@QEAAXAEBUb2Filter@@@Z";
    SetFilterData :: (this: *b2Fixture, filter: b2Filter) #no_context {
        SetFilterData(this, *filter);
    }

    /// Get the contact filtering data.
    GetFilterData :: (this: *b2Fixture) -> *b2Filter #cpp_method #foreign box2d "?GetFilterData@b2Fixture@@QEBAAEBUb2Filter@@XZ";

    /// Call this if you want to establish collision that was previously disabled by b2ContactFilter::ShouldCollide.
    Refilter :: (this: *b2Fixture) -> void #cpp_method #foreign box2d "?Refilter@b2Fixture@@QEAAXXZ";

    /// Get the parent body of this fixture. This is nullptr if the fixture is not attached.
    /// @return the parent body.
    GetBody :: (this: *b2Fixture) -> *b2Body #cpp_method #foreign box2d "?GetBody@b2Fixture@@QEAAPEAVb2Body@@XZ";

    GetBody_1 :: (this: /*const*/ *b2Fixture) -> *b2Body #cpp_method #foreign box2d "?GetBody@b2Fixture@@QEBAPEBVb2Body@@XZ";

    /// Get the next fixture in the parent body's fixture list.
    /// @return the next shape.
    GetNext :: (this: *b2Fixture) -> *b2Fixture #cpp_method #foreign box2d "?GetNext@b2Fixture@@QEAAPEAV1@XZ";

    GetNext_1 :: (this: /*const*/ *b2Fixture) -> *b2Fixture #cpp_method #foreign box2d "?GetNext@b2Fixture@@QEBAPEBV1@XZ";

    /// Get the user data that was assigned in the fixture definition. Use this to
    /// store your application specific data.
    GetUserData :: (this: *b2Fixture) -> *b2FixtureUserData #cpp_method #foreign box2d "?GetUserData@b2Fixture@@QEAAAEAUb2FixtureUserData@@XZ";

    /// Test a point for containment in this fixture.
    /// @param p a point in world coordinates.
    TestPoint :: (this: *b2Fixture, p: *b2Vec2) -> bool #cpp_method #foreign box2d "?TestPoint@b2Fixture@@QEBA_NAEBUb2Vec2@@@Z";
    TestPoint :: (this: *b2Fixture, p: b2Vec2) -> bool #no_context {
        return TestPoint(this, *p);
    }

    /// Cast a ray against this shape.
    /// @param output the ray-cast results.
    /// @param input the ray-cast input parameters.
    /// @param childIndex the child shape index (e.g. edge index)
    RayCast :: (this: *b2Fixture, output: *b2RayCastOutput, input: *b2RayCastInput, childIndex: int32) -> bool #cpp_method #foreign box2d "?RayCast@b2Fixture@@QEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@H@Z";
    RayCast :: (this: *b2Fixture, output: *b2RayCastOutput, input: b2RayCastInput, childIndex: int32) -> bool #no_context {
        return RayCast(this, output, *input, childIndex);
    }

    /// Get the mass data for this fixture. The mass data is based on the density and
    /// the shape. The rotational inertia is about the shape's origin. This operation
    /// may be expensive.
    GetMassData :: (this: *b2Fixture, massData: *b2MassData) -> void #cpp_method #foreign box2d "?GetMassData@b2Fixture@@QEBAXPEAUb2MassData@@@Z";

    /// Set the density of this fixture. This will _not_ automatically adjust the mass
    /// of the body. You must call b2Body::ResetMassData to update the body's mass.
    SetDensity :: (this: *b2Fixture, density: float) -> void #cpp_method #foreign box2d "?SetDensity@b2Fixture@@QEAAXM@Z";

    /// Get the density of this fixture.
    GetDensity :: (this: *b2Fixture) -> float #cpp_method #foreign box2d "?GetDensity@b2Fixture@@QEBAMXZ";

    /// Get the coefficient of friction.
    GetFriction :: (this: *b2Fixture) -> float #cpp_method #foreign box2d "?GetFriction@b2Fixture@@QEBAMXZ";

    /// Set the coefficient of friction. This will _not_ change the friction of
    /// existing contacts.
    SetFriction :: (this: *b2Fixture, friction: float) -> void #cpp_method #foreign box2d "?SetFriction@b2Fixture@@QEAAXM@Z";

    /// Get the coefficient of restitution.
    GetRestitution :: (this: *b2Fixture) -> float #cpp_method #foreign box2d "?GetRestitution@b2Fixture@@QEBAMXZ";

    /// Set the coefficient of restitution. This will _not_ change the restitution of
    /// existing contacts.
    SetRestitution :: (this: *b2Fixture, restitution: float) -> void #cpp_method #foreign box2d "?SetRestitution@b2Fixture@@QEAAXM@Z";

    /// Get the restitution velocity threshold.
    GetRestitutionThreshold :: (this: *b2Fixture) -> float #cpp_method #foreign box2d "?GetRestitutionThreshold@b2Fixture@@QEBAMXZ";

    /// Set the restitution threshold. This will _not_ change the restitution threshold of
    /// existing contacts.
    SetRestitutionThreshold :: (this: *b2Fixture, threshold: float) -> void #cpp_method #foreign box2d "?SetRestitutionThreshold@b2Fixture@@QEAAXM@Z";

    /// Get the fixture's AABB. This AABB may be enlarge and/or stale.
    /// If you need a more accurate AABB, compute it using the shape and
    /// the body transform.
    GetAABB :: (this: *b2Fixture, childIndex: int32) -> *b2AABB #cpp_method #foreign box2d "?GetAABB@b2Fixture@@QEBAAEBUb2AABB@@H@Z";

    /// Dump this fixture to the log file.
    Dump :: (this: *b2Fixture, bodyIndex: int32) -> void #cpp_method #foreign box2d "?Dump@b2Fixture@@QEAAXH@Z";

    Constructor :: (this: *b2Fixture) -> void #cpp_method #foreign box2d "??0b2Fixture@@IEAA@XZ";

    // We need separation create/destroy functions from the constructor/destructor because
    // the destructor cannot access the allocator (no destructor arguments allowed by C++).
    Create :: (this: *b2Fixture, allocator: *b2BlockAllocator, body: *b2Body, def: *b2FixtureDef) -> void #cpp_method #foreign box2d "?Create@b2Fixture@@IEAAXPEAVb2BlockAllocator@@PEAVb2Body@@PEBUb2FixtureDef@@@Z";
    Destroy :: (this: *b2Fixture, allocator: *b2BlockAllocator) -> void #cpp_method #foreign box2d "?Destroy@b2Fixture@@IEAAXPEAVb2BlockAllocator@@@Z";

    // These support body activation/deactivation.
    CreateProxies :: (this: *b2Fixture, broadPhase: *b2BroadPhase, xf: *b2Transform) -> void #cpp_method #foreign box2d "?CreateProxies@b2Fixture@@IEAAXPEAVb2BroadPhase@@AEBUb2Transform@@@Z";
    CreateProxies :: (this: *b2Fixture, broadPhase: *b2BroadPhase, xf: b2Transform) #no_context {
        CreateProxies(this, broadPhase, *xf);
    }
    DestroyProxies :: (this: *b2Fixture, broadPhase: *b2BroadPhase) -> void #cpp_method #foreign box2d "?DestroyProxies@b2Fixture@@IEAAXPEAVb2BroadPhase@@@Z";

    Synchronize :: (this: *b2Fixture, broadPhase: *b2BroadPhase, xf1: *b2Transform, xf2: *b2Transform) -> void #cpp_method #foreign box2d "?Synchronize@b2Fixture@@IEAAXPEAVb2BroadPhase@@AEBUb2Transform@@1@Z";
    Synchronize :: (this: *b2Fixture, broadPhase: *b2BroadPhase, xf1: b2Transform, xf2: b2Transform) #no_context {
        Synchronize(this, broadPhase, *xf1, *xf2);
    }

    m_density:              float;

    m_next:                 *b2Fixture;
    m_body:                 *b2Body;

    m_shape:                *b2Shape;

    m_friction:             float;
    m_restitution:          float;
    m_restitutionThreshold: float;

    m_proxies:              *b2FixtureProxy;
    m_proxyCount:           int32;

    m_filter:               b2Filter;

    m_isSensor:             bool;

    m_userData:             b2FixtureUserData;
}

b2ContactCreateFcn :: #type (a0: *b2Fixture, a1: int32, a2: *b2Fixture, a3: int32, a4: *b2BlockAllocator) -> *b2Contact #c_call;

b2ContactDestroyFcn :: #type (a0: *b2Contact, a1: *b2BlockAllocator) -> void #c_call;

b2ContactRegister :: struct {
    createFcn:  b2ContactCreateFcn;
    destroyFcn: b2ContactDestroyFcn;
    primary:    bool;
}

/// A contact edge is used to connect bodies and contacts together
/// in a contact graph where each body is a node and each contact
/// is an edge. A contact edge belongs to a doubly linked list
/// maintained in each attached body. Each contact has two contact
/// nodes, one for each attached body.
b2ContactEdge :: struct {
    other:   *b2Body; ///< provides quick access to the other body attached.
    contact: *b2Contact; ///< the contact
    prev:    *b2ContactEdge; ///< the previous contact edge in the body's contact list
    next:    *b2ContactEdge; ///< the next contact edge in the body's contact list
}

/// The class manages contact between two shapes. A contact exists for each overlapping
/// AABB in the broad-phase (except if filtered). Therefore a contact object may exist
/// that has no contact points.
b2Contact :: struct {
    vtable: *b2Contact_VTable;
    /// Get the contact manifold. Do not modify the manifold unless you understand the
    /// internals of Box2D.
    GetManifold :: (this: *b2Contact) -> *b2Manifold #cpp_method #foreign box2d "?GetManifold@b2Contact@@QEAAPEAUb2Manifold@@XZ";

    GetManifold_1 :: (this: /*const*/ *b2Contact) -> *b2Manifold #cpp_method #foreign box2d "?GetManifold@b2Contact@@QEBAPEBUb2Manifold@@XZ";

    /// Get the world manifold.
    GetWorldManifold :: (this: *b2Contact, worldManifold: *b2WorldManifold) -> void #cpp_method #foreign box2d "?GetWorldManifold@b2Contact@@QEBAXPEAUb2WorldManifold@@@Z";

    /// Is this contact touching?
    IsTouching :: (this: *b2Contact) -> bool #cpp_method #foreign box2d "?IsTouching@b2Contact@@QEBA_NXZ";

    /// Enable/disable this contact. This can be used inside the pre-solve
    /// contact listener. The contact is only disabled for the current
    /// time step (or sub-step in continuous collisions).
    SetEnabled :: (this: *b2Contact, flag: bool) -> void #cpp_method #foreign box2d "?SetEnabled@b2Contact@@QEAAX_N@Z";

    /// Has this contact been disabled?
    IsEnabled :: (this: *b2Contact) -> bool #cpp_method #foreign box2d "?IsEnabled@b2Contact@@QEBA_NXZ";

    /// Get the next contact in the world's contact list.
    GetNext :: (this: *b2Contact) -> *b2Contact #cpp_method #foreign box2d "?GetNext@b2Contact@@QEAAPEAV1@XZ";

    GetNext_1 :: (this: /*const*/ *b2Contact) -> *b2Contact #cpp_method #foreign box2d "?GetNext@b2Contact@@QEBAPEBV1@XZ";

    /// Get fixture A in this contact.
    GetFixtureA :: (this: *b2Contact) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureA@b2Contact@@QEAAPEAVb2Fixture@@XZ";

    GetFixtureA_1 :: (this: /*const*/ *b2Contact) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureA@b2Contact@@QEBAPEBVb2Fixture@@XZ";

    /// Get the child primitive index for fixture A.
    GetChildIndexA :: (this: *b2Contact) -> int32 #cpp_method #foreign box2d "?GetChildIndexA@b2Contact@@QEBAHXZ";

    /// Get fixture B in this contact.
    GetFixtureB :: (this: *b2Contact) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureB@b2Contact@@QEAAPEAVb2Fixture@@XZ";

    GetFixtureB_1 :: (this: /*const*/ *b2Contact) -> *b2Fixture #cpp_method #foreign box2d "?GetFixtureB@b2Contact@@QEBAPEBVb2Fixture@@XZ";

    /// Get the child primitive index for fixture B.
    GetChildIndexB :: (this: *b2Contact) -> int32 #cpp_method #foreign box2d "?GetChildIndexB@b2Contact@@QEBAHXZ";

    /// Override the default friction mixture. You can call this in b2ContactListener::PreSolve.
    /// This value persists until set or reset.
    SetFriction :: (this: *b2Contact, friction: float) -> void #cpp_method #foreign box2d "?SetFriction@b2Contact@@QEAAXM@Z";

    /// Get the friction.
    GetFriction :: (this: *b2Contact) -> float #cpp_method #foreign box2d "?GetFriction@b2Contact@@QEBAMXZ";

    /// Reset the friction mixture to the default value.
    ResetFriction :: (this: *b2Contact) -> void #cpp_method #foreign box2d "?ResetFriction@b2Contact@@QEAAXXZ";

    /// Override the default restitution mixture. You can call this in b2ContactListener::PreSolve.
    /// The value persists until you set or reset.
    SetRestitution :: (this: *b2Contact, restitution: float) -> void #cpp_method #foreign box2d "?SetRestitution@b2Contact@@QEAAXM@Z";

    /// Get the restitution.
    GetRestitution :: (this: *b2Contact) -> float #cpp_method #foreign box2d "?GetRestitution@b2Contact@@QEBAMXZ";

    /// Reset the restitution to the default value.
    ResetRestitution :: (this: *b2Contact) -> void #cpp_method #foreign box2d "?ResetRestitution@b2Contact@@QEAAXXZ";

    /// Override the default restitution velocity threshold mixture. You can call this in b2ContactListener::PreSolve.
    /// The value persists until you set or reset.
    SetRestitutionThreshold :: (this: *b2Contact, threshold: float) -> void #cpp_method #foreign box2d "?SetRestitutionThreshold@b2Contact@@QEAAXM@Z";

    /// Get the restitution threshold.
    GetRestitutionThreshold :: (this: *b2Contact) -> float #cpp_method #foreign box2d "?GetRestitutionThreshold@b2Contact@@QEBAMXZ";

    /// Reset the restitution threshold to the default value.
    ResetRestitutionThreshold :: (this: *b2Contact) -> void #cpp_method #foreign box2d "?ResetRestitutionThreshold@b2Contact@@QEAAXXZ";

    /// Set the desired tangent speed for a conveyor belt behavior. In meters per second.
    SetTangentSpeed :: (this: *b2Contact, speed: float) -> void #cpp_method #foreign box2d "?SetTangentSpeed@b2Contact@@QEAAXM@Z";

    /// Get the desired tangent speed. In meters per second.
    GetTangentSpeed :: (this: *b2Contact) -> float #cpp_method #foreign box2d "?GetTangentSpeed@b2Contact@@QEBAMXZ";

    // Flags stored in m_flags
    e_1 :: enum s32 {
        islandFlag    :: 1;

        touchingFlag  :: 2;

        enabledFlag   :: 4;

        filterFlag    :: 8;

        bulletHitFlag :: 16;

        toiFlag       :: 32;

        e_islandFlag    :: islandFlag;

        e_touchingFlag  :: touchingFlag;

        e_enabledFlag   :: enabledFlag;

        e_filterFlag    :: filterFlag;

        e_bulletHitFlag :: bulletHitFlag;

        e_toiFlag       :: toiFlag;
    }

    /// Flag this contact for filtering. Filtering will occur the next time step.
    FlagForFiltering :: (this: *b2Contact) -> void #cpp_method #foreign box2d "?FlagForFiltering@b2Contact@@IEAAXXZ";

    AddType :: (createFcn: b2ContactCreateFcn, destroyFcn: b2ContactDestroyFcn, typeA: b2Shape.Type, typeB: b2Shape.Type) -> void #foreign box2d "?AddType@b2Contact@@KAXP6APEAV1@PEAVb2Fixture@@H0HPEAVb2BlockAllocator@@@ZP6AXPEAV1@1@ZW4Type@b2Shape@@5@Z";

    InitializeRegisters :: () -> void #foreign box2d "?InitializeRegisters@b2Contact@@KAXXZ";
    Create :: (fixtureA: *b2Fixture, indexA: int32, fixtureB: *b2Fixture, indexB: int32, allocator: *b2BlockAllocator) -> *b2Contact #foreign box2d "?Create@b2Contact@@KAPEAV1@PEAVb2Fixture@@H0HPEAVb2BlockAllocator@@@Z";

    Destroy :: (contact: *b2Contact, allocator: *b2BlockAllocator) -> void #foreign box2d "?Destroy@b2Contact@@KAXPEAV1@PEAVb2BlockAllocator@@@Z";

    Constructor :: (this: *b2Contact) -> void #cpp_method #foreign box2d "??0b2Contact@@IEAA@XZ";
    Constructor :: (this: *b2Contact, fixtureA: *b2Fixture, indexA: int32, fixtureB: *b2Fixture, indexB: int32) -> void #cpp_method #foreign box2d "??0b2Contact@@IEAA@PEAVb2Fixture@@H0H@Z";

    Update :: (this: *b2Contact, listener: *b2ContactListener) -> void #cpp_method #foreign box2d "?Update@b2Contact@@IEAAXPEAVb2ContactListener@@@Z";

    m_flags:                uint32;

    // World pool and list pointers.
    m_prev:                 *b2Contact;
    m_next:                 *b2Contact;

    // Nodes for connecting bodies.
    m_nodeA:                b2ContactEdge;
    m_nodeB:                b2ContactEdge;

    m_fixtureA:             *b2Fixture;
    m_fixtureB:             *b2Fixture;

    m_indexA:               int32;
    m_indexB:               int32;

    m_manifold:             b2Manifold;

    m_toiCount:             int32;
    m_toi:                  float;

    m_friction:             float;
    m_restitution:          float;
    m_restitutionThreshold: float;

    m_tangentSpeed:         float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_Destructor :: (this: *b2Contact, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2Contact@@MEAA@XZ";
}
b2Contact_VTable :: struct #type_info_none {
    Evaluate: (this: *b2Contact, manifold: *b2Manifold, xfA: *b2Transform, xfB: *b2Transform) -> void #cpp_method;

    Destructor: (this: *b2Contact, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;
}

b2Contact_Evaluate :: inline (this: *b2Contact, manifold: *b2Manifold, xfA: *b2Transform, xfB: *b2Transform) { this.vtable.Evaluate(this, manifold, xfA, xfB); }

b2Contact_Destructor :: inline (this: *b2Contact, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

vtable :: (obj: *b2Contact) -> *b2Contact_VTable { return obj.vtable; }


// Delegate of b2World.
b2ContactManager :: struct {
    Constructor :: (this: *b2ContactManager) -> void #cpp_method #foreign box2d "??0b2ContactManager@@QEAA@XZ";

    // Broad-phase callback.
    AddPair :: (this: *b2ContactManager, proxyUserDataA: *void, proxyUserDataB: *void) -> void #cpp_method #foreign box2d "?AddPair@b2ContactManager@@QEAAXPEAX0@Z";

    FindNewContacts :: (this: *b2ContactManager) -> void #cpp_method #foreign box2d "?FindNewContacts@b2ContactManager@@QEAAXXZ";

    Destroy :: (this: *b2ContactManager, c: *b2Contact) -> void #cpp_method #foreign box2d "?Destroy@b2ContactManager@@QEAAXPEAVb2Contact@@@Z";

    Collide :: (this: *b2ContactManager) -> void #cpp_method #foreign box2d "?Collide@b2ContactManager@@QEAAXXZ";

    m_broadPhase:      b2BroadPhase;
    m_contactList:     *b2Contact;
    m_contactCount:    int32;
    m_contactFilter:   *b2ContactFilter;
    m_contactListener: *b2ContactListener;
    m_allocator:       *b2BlockAllocator;
}

/// A distance proxy is used by the GJK algorithm.
/// It encapsulates any shape.
b2DistanceProxy :: struct {
    Constructor :: (this: *b2DistanceProxy) -> void #cpp_method #foreign box2d "??0b2DistanceProxy@@QEAA@XZ";

    /// Initialize the proxy using the given shape. The shape
    /// must remain in scope while the proxy is in use.
    Set :: (this: *b2DistanceProxy, shape: *b2Shape, index: int32) -> void #cpp_method #foreign box2d "?Set@b2DistanceProxy@@QEAAXPEBVb2Shape@@H@Z";

    /// Initialize the proxy using a vertex cloud and radius. The vertices
    /// must remain in scope while the proxy is in use.
    Set :: (this: *b2DistanceProxy, vertices: *b2Vec2, count: int32, radius: float) -> void #cpp_method #foreign box2d "?Set@b2DistanceProxy@@QEAAXPEBUb2Vec2@@HM@Z";

    /// Get the supporting vertex index in the given direction.
    GetSupport :: (this: *b2DistanceProxy, d: *b2Vec2) -> int32 #cpp_method #foreign box2d "?GetSupport@b2DistanceProxy@@QEBAHAEBUb2Vec2@@@Z";
    GetSupport :: (this: *b2DistanceProxy, d: b2Vec2) -> int32 #no_context {
        return GetSupport(this, *d);
    }

    /// Get the supporting vertex in the given direction.
    GetSupportVertex :: (this: *b2DistanceProxy, d: *b2Vec2) -> *b2Vec2 #cpp_method #foreign box2d "?GetSupportVertex@b2DistanceProxy@@QEBAAEBUb2Vec2@@AEBU2@@Z";
    GetSupportVertex :: (this: *b2DistanceProxy, d: b2Vec2) -> *b2Vec2 #no_context {
        return GetSupportVertex(this, *d);
    }

    /// Get the vertex count.
    GetVertexCount :: (this: *b2DistanceProxy) -> int32 #cpp_method #foreign box2d "?GetVertexCount@b2DistanceProxy@@QEBAHXZ";

    /// Get a vertex by index. Used by b2Distance.
    GetVertex :: (this: *b2DistanceProxy, index: int32) -> *b2Vec2 #cpp_method #foreign box2d "?GetVertex@b2DistanceProxy@@QEBAAEBUb2Vec2@@H@Z";

    m_buffer:   [2] b2Vec2;
    m_vertices: *b2Vec2;
    m_count:    int32;
    m_radius:   float;
}

/// Used to warm start b2Distance.
/// Set count to zero on first call.
b2SimplexCache :: struct {
    metric: float; ///< length or area
    count:  uint16;
    indexA: [3] uint8; ///< vertices on shape A
    indexB: [3] uint8; ///< vertices on shape B
}

/// Input for b2Distance.
/// You have to option to use the shape radii
/// in the computation. Even
b2DistanceInput :: struct {
    proxyA:     b2DistanceProxy;
    proxyB:     b2DistanceProxy;
    transformA: b2Transform;
    transformB: b2Transform;
    useRadii:   bool;
}

/// Output for b2Distance.
b2DistanceOutput :: struct {
    pointA:     b2Vec2; ///< closest point on shapeA
    pointB:     b2Vec2; ///< closest point on shapeB
    distance:   float;
    iterations: int32; ///< number of GJK iterations used
}

/// Compute the closest points between two shapes. Supports any combination of:
/// b2CircleShape, b2PolygonShape, b2EdgeShape. The simplex cache is input/output.
/// On the first call set b2SimplexCache.count to zero.
b2Distance :: (output: *b2DistanceOutput, cache: *b2SimplexCache, input: *b2DistanceInput) -> void #foreign box2d "?b2Distance@@YAXPEAUb2DistanceOutput@@PEAUb2SimplexCache@@PEBUb2DistanceInput@@@Z";

/// Input parameters for b2ShapeCast
b2ShapeCastInput :: struct {
    proxyA:       b2DistanceProxy;
    proxyB:       b2DistanceProxy;
    transformA:   b2Transform;
    transformB:   b2Transform;
    translationB: b2Vec2;
}

/// Output results for b2ShapeCast
b2ShapeCastOutput :: struct {
    point:      b2Vec2;
    normal:     b2Vec2;
    lambda:     float;
    iterations: int32;
}

/// Perform a linear shape cast of shape B moving and shape A fixed. Determines the hit point, normal, and translation fraction.
/// @returns true if hit, false if there is no hit or an initial overlap
b2ShapeCast :: (output: *b2ShapeCastOutput, input: *b2ShapeCastInput) -> bool #foreign box2d "?b2ShapeCast@@YA_NPEAUb2ShapeCastOutput@@PEBUb2ShapeCastInput@@@Z";

b2JointType :: enum s32 {
    unknownJoint   :: 0;
    revoluteJoint  :: 1;
    prismaticJoint :: 2;
    distanceJoint  :: 3;
    pulleyJoint    :: 4;
    mouseJoint     :: 5;
    gearJoint      :: 6;
    wheelJoint     :: 7;
    weldJoint      :: 8;
    frictionJoint  :: 9;
    ropeJoint      :: 10;
    motorJoint     :: 11;

    e_unknownJoint   :: unknownJoint;
    e_revoluteJoint  :: revoluteJoint;
    e_prismaticJoint :: prismaticJoint;
    e_distanceJoint  :: distanceJoint;
    e_pulleyJoint    :: pulleyJoint;
    e_mouseJoint     :: mouseJoint;
    e_gearJoint      :: gearJoint;
    e_wheelJoint     :: wheelJoint;
    e_weldJoint      :: weldJoint;
    e_frictionJoint  :: frictionJoint;
    e_ropeJoint      :: ropeJoint;
    e_motorJoint     :: motorJoint;
}

b2Jacobian :: struct {
    linear:   b2Vec2;
    angularA: float;
    angularB: float;
}

/// A joint edge is used to connect bodies and joints together
/// in a joint graph where each body is a node and each joint
/// is an edge. A joint edge belongs to a doubly linked list
/// maintained in each attached body. Each joint has two joint
/// nodes, one for each attached body.
b2JointEdge :: struct {
    other: *b2Body; ///< provides quick access to the other body attached.
    joint: *b2Joint; ///< the joint
    prev:  *b2JointEdge; ///< the previous joint edge in the body's joint list
    next:  *b2JointEdge; ///< the next joint edge in the body's joint list
}

/// Joint definitions are used to construct joints.
b2JointDef :: struct {
    Constructor :: (this: *b2JointDef) -> void #cpp_method #foreign box2d "??0b2JointDef@@QEAA@XZ";

    /// The joint type is set automatically for concrete joint types.
    type:             b2JointType;

    /// Use this to attach application specific data to your joints.
    userData:         b2JointUserData;

    /// The first attached body.
    bodyA:            *b2Body;

    /// The second attached body.
    bodyB:            *b2Body;

    /// Set this flag to true if the attached bodies should collide.
    collideConnected: bool;
}

/// Utility to compute linear stiffness values from frequency and damping ratio
b2LinearStiffness :: (stiffness: *float, damping: *float, frequencyHertz: float, dampingRatio: float, bodyA: *b2Body, bodyB: *b2Body) -> void #foreign box2d "?b2LinearStiffness@@YAXAEAM0MMPEBVb2Body@@1@Z";

/// Utility to compute rotational stiffness values frequency and damping ratio
b2AngularStiffness :: (stiffness: *float, damping: *float, frequencyHertz: float, dampingRatio: float, bodyA: *b2Body, bodyB: *b2Body) -> void #foreign box2d "?b2AngularStiffness@@YAXAEAM0MMPEBVb2Body@@1@Z";

/// The base joint class. Joints are used to constraint two bodies together in
/// various fashions. Some joints also feature limits and motors.
b2Joint :: struct {
    vtable: *b2Joint_VTable;
    /// Get the type of the concrete joint.
    GetType :: (this: *b2Joint) -> b2JointType #cpp_method #foreign box2d "?GetType@b2Joint@@QEBA?AW4b2JointType@@XZ";

    /// Get the first body attached to this joint.
    GetBodyA :: (this: *b2Joint) -> *b2Body #cpp_method #foreign box2d "?GetBodyA@b2Joint@@QEAAPEAVb2Body@@XZ";

    /// Get the second body attached to this joint.
    GetBodyB :: (this: *b2Joint) -> *b2Body #cpp_method #foreign box2d "?GetBodyB@b2Joint@@QEAAPEAVb2Body@@XZ";

    /// Get the next joint the world joint list.
    GetNext :: (this: *b2Joint) -> *b2Joint #cpp_method #foreign box2d "?GetNext@b2Joint@@QEAAPEAV1@XZ";

    GetNext_1 :: (this: /*const*/ *b2Joint) -> *b2Joint #cpp_method #foreign box2d "?GetNext@b2Joint@@QEBAPEBV1@XZ";

    /// Get the user data pointer.
    GetUserData :: (this: *b2Joint) -> *b2JointUserData #cpp_method #foreign box2d "?GetUserData@b2Joint@@QEAAAEAUb2JointUserData@@XZ";

    /// Short-cut function to determine if either body is enabled.
    IsEnabled :: (this: *b2Joint) -> bool #cpp_method #foreign box2d "?IsEnabled@b2Joint@@QEBA_NXZ";

    /// Get collide connected.
    /// Note: modifying the collide connect flag won't work correctly because
    /// the flag is only checked when fixture AABBs begin to overlap.
    GetCollideConnected :: (this: *b2Joint) -> bool #cpp_method #foreign box2d "?GetCollideConnected@b2Joint@@QEBA_NXZ";

    Create :: (def: *b2JointDef, allocator: *b2BlockAllocator) -> *b2Joint #foreign box2d "?Create@b2Joint@@KAPEAV1@PEBUb2JointDef@@PEAVb2BlockAllocator@@@Z";
    Destroy :: (joint: *b2Joint, allocator: *b2BlockAllocator) -> void #foreign box2d "?Destroy@b2Joint@@KAXPEAV1@PEAVb2BlockAllocator@@@Z";

    Constructor :: (this: *b2Joint, def: *b2JointDef) -> void #cpp_method #foreign box2d "??0b2Joint@@IEAA@PEBUb2JointDef@@@Z";

    m_type:             b2JointType;
    m_prev:             *b2Joint;
    m_next:             *b2Joint;
    m_edgeA:            b2JointEdge;
    m_edgeB:            b2JointEdge;
    m_bodyA:            *b2Body;
    m_bodyB:            *b2Body;

    m_index:            int32;

    m_islandFlag:       bool;
    m_collideConnected: bool;

    m_userData:         b2JointUserData;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// Dump this joint to the log file.
    virtual_Dump :: (this: *b2Joint) -> void #cpp_method #foreign box2d "?Dump@b2Joint@@UEAAXXZ";

    /// Shift the origin for any points stored in world coordinates.
    virtual_ShiftOrigin :: (this: *b2Joint, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2Joint@@UEAAXAEBUb2Vec2@@@Z";

    /// Debug draw this joint
    virtual_Draw :: (this: *b2Joint, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2Joint@@UEBAXPEAVb2Draw@@@Z";

    virtual_Destructor :: (this: *b2Joint, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2Joint@@MEAA@XZ";
}
b2Joint_VTable :: struct #type_info_none {
    GetAnchorA: (this: *b2Joint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod;

    GetAnchorB: (this: *b2Joint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod;

    GetReactionForce: (this: *b2Joint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod;

    GetReactionTorque: (this: *b2Joint, inv_dt: float) -> float #cpp_method;

    Dump: (this: *b2Joint) -> void #cpp_method;

    ShiftOrigin: (this: *b2Joint, newOrigin: *b2Vec2) -> void #cpp_method;

    Draw: (this: *b2Joint, draw: *b2Draw) -> void #cpp_method;

    Destructor: (this: *b2Joint, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    InitVelocityConstraints: (this: *b2Joint, data: *b2SolverData) -> void #cpp_method;
    SolveVelocityConstraints: (this: *b2Joint, data: *b2SolverData) -> void #cpp_method;

    SolvePositionConstraints: (this: *b2Joint, data: *b2SolverData) -> bool #cpp_method;
}

b2Joint_GetAnchorA :: inline (this: *b2Joint) -> b2Vec2 { return this.vtable.GetAnchorA(this); }

b2Joint_GetAnchorB :: inline (this: *b2Joint) -> b2Vec2 { return this.vtable.GetAnchorB(this); }

b2Joint_GetReactionForce :: inline (this: *b2Joint, inv_dt: float) -> b2Vec2 { return this.vtable.GetReactionForce(this, inv_dt); }

b2Joint_GetReactionTorque :: inline (this: *b2Joint, inv_dt: float) -> float { return this.vtable.GetReactionTorque(this, inv_dt); }

b2Joint_Dump :: inline (this: *b2Joint) { this.vtable.Dump(this); }

b2Joint_ShiftOrigin :: inline (this: *b2Joint, newOrigin: *b2Vec2) { this.vtable.ShiftOrigin(this, newOrigin); }

b2Joint_Draw :: inline (this: *b2Joint, draw: *b2Draw) { this.vtable.Draw(this, draw); }

b2Joint_Destructor :: inline (this: *b2Joint, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2Joint_InitVelocityConstraints :: inline (this: *b2Joint, data: *b2SolverData) { this.vtable.InitVelocityConstraints(this, data); }
b2Joint_SolveVelocityConstraints :: inline (this: *b2Joint, data: *b2SolverData) { this.vtable.SolveVelocityConstraints(this, data); }

b2Joint_SolvePositionConstraints :: inline (this: *b2Joint, data: *b2SolverData) -> bool { return this.vtable.SolvePositionConstraints(this, data); }

vtable :: (obj: *b2Joint) -> *b2Joint_VTable { return obj.vtable; }


/// Distance joint definition. This requires defining an anchor point on both
/// bodies and the non-zero distance of the distance joint. The definition uses
/// local anchor points so that the initial configuration can violate the
/// constraint slightly. This helps when saving and loading a game.
b2DistanceJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2DistanceJointDef) -> void #cpp_method #foreign box2d "??0b2DistanceJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, and rest length using world space anchors.
    /// The minimum and maximum lengths are set to the rest length.
    Initialize :: (this: *b2DistanceJointDef, bodyA: *b2Body, bodyB: *b2Body, anchorA: *b2Vec2, anchorB: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2DistanceJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@1@Z";
    Initialize :: (this: *b2DistanceJointDef, bodyA: *b2Body, bodyB: *b2Body, anchorA: b2Vec2, anchorB: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchorA, *anchorB);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA: b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB: b2Vec2;

    /// The rest length of this joint. Clamped to a stable minimum value.
    length:       float;

    /// Minimum length. Clamped to a stable minimum value.
    minLength:    float;

    /// Maximum length. Must be greater than or equal to the minimum length.
    maxLength:    float;

    /// The linear stiffness in N/m.
    stiffness:    float;

    /// The linear damping in N*s/m.
    damping:      float;
}

/// A distance joint constrains two points on two bodies to remain at a fixed
/// distance from each other. You can view this as a massless, rigid rod.
b2DistanceJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2DistanceJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2DistanceJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2DistanceJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2DistanceJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Get the rest length
    GetLength :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetLength@b2DistanceJoint@@QEBAMXZ";

    /// Set the rest length
    /// @returns clamped rest length
    SetLength :: (this: *b2DistanceJoint, length: float) -> float #cpp_method #foreign box2d "?SetLength@b2DistanceJoint@@QEAAMM@Z";

    /// Get the minimum length
    GetMinLength :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetMinLength@b2DistanceJoint@@QEBAMXZ";

    /// Set the minimum length
    /// @returns the clamped minimum length
    SetMinLength :: (this: *b2DistanceJoint, minLength: float) -> float #cpp_method #foreign box2d "?SetMinLength@b2DistanceJoint@@QEAAMM@Z";

    /// Get the maximum length
    GetMaxLength :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetMaxLength@b2DistanceJoint@@QEBAMXZ";

    /// Set the maximum length
    /// @returns the clamped maximum length
    SetMaxLength :: (this: *b2DistanceJoint, maxLength: float) -> float #cpp_method #foreign box2d "?SetMaxLength@b2DistanceJoint@@QEAAMM@Z";

    /// Get the current length
    GetCurrentLength :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetCurrentLength@b2DistanceJoint@@QEBAMXZ";

    /// Set/get the linear stiffness in N/m
    SetStiffness :: (this: *b2DistanceJoint, stiffness: float) -> void #cpp_method #foreign box2d "?SetStiffness@b2DistanceJoint@@QEAAXM@Z";
    GetStiffness :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetStiffness@b2DistanceJoint@@QEBAMXZ";

    /// Set/get linear damping in N*s/m
    SetDamping :: (this: *b2DistanceJoint, damping: float) -> void #cpp_method #foreign box2d "?SetDamping@b2DistanceJoint@@QEAAXM@Z";
    GetDamping :: (this: *b2DistanceJoint) -> float #cpp_method #foreign box2d "?GetDamping@b2DistanceJoint@@QEBAMXZ";

    Constructor :: (this: *b2DistanceJoint, data: *b2DistanceJointDef) -> void #cpp_method #foreign box2d "??0b2DistanceJoint@@IEAA@PEBUb2DistanceJointDef@@@Z";

    m_stiffness:     float;
    m_damping:       float;
    m_bias:          float;
    m_length:        float;
    m_minLength:     float;
    m_maxLength:     float;

    // Solver shared
    m_localAnchorA:  b2Vec2;
    m_localAnchorB:  b2Vec2;
    m_gamma:         float;
    m_impulse:       float;
    m_lowerImpulse:  float;
    m_upperImpulse:  float;

    // Solver temp
    m_indexA:        int32;
    m_indexB:        int32;
    m_u:             b2Vec2;
    m_rA:            b2Vec2;
    m_rB:            b2Vec2;
    m_localCenterA:  b2Vec2;
    m_localCenterB:  b2Vec2;
    m_currentLength: float;
    m_invMassA:      float;
    m_invMassB:      float;
    m_invIA:         float;
    m_invIB:         float;
    m_softMass:      float;
    m_mass:          float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2DistanceJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2DistanceJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2DistanceJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2DistanceJoint@@UEBA?AUb2Vec2@@XZ";

    /// Get the reaction force given the inverse time step.
    /// Unit is N.
    virtual_GetReactionForce :: (this: *b2DistanceJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2DistanceJoint@@UEBA?AUb2Vec2@@M@Z";

    /// Get the reaction torque given the inverse time step.
    /// Unit is N*m. This is always zero for a distance joint.
    virtual_GetReactionTorque :: (this: *b2DistanceJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2DistanceJoint@@UEBAMM@Z";

    /// Dump joint to dmLog
    virtual_Dump :: (this: *b2DistanceJoint) -> void #cpp_method #foreign box2d "?Dump@b2DistanceJoint@@UEAAXXZ";

    ///
    virtual_Draw :: (this: *b2DistanceJoint, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2DistanceJoint@@UEBAXPEAVb2Draw@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2DistanceJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2DistanceJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2DistanceJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2DistanceJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2DistanceJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2DistanceJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Color for debug drawing. Each value has the range [0,1].
b2Color :: struct {
    Constructor :: (this: *b2Color) -> void #cpp_method #foreign box2d "??0b2Color@@QEAA@XZ";
    Constructor :: (this: *b2Color, rIn: float, gIn: float, bIn: float, aIn: float = 1.0) -> void #cpp_method #foreign box2d "??0b2Color@@QEAA@MMMM@Z";

    Set :: (this: *b2Color, rIn: float, gIn: float, bIn: float, aIn: float = 1.0) -> void #cpp_method #foreign box2d "?Set@b2Color@@QEAAXMMMM@Z";

    r: float;
    g: float;
    b: float;
    a: float;
}

/// Implement and register this class with a b2World to provide debug drawing of physics
/// entities in your game.
b2Draw :: struct {
    vtable: *b2Draw_VTable;
    Constructor :: (this: *b2Draw) -> void #cpp_method #foreign box2d "??0b2Draw@@QEAA@XZ";

    e_2 :: enum s32 {
        shapeBit        :: 1;
        jointBit        :: 2;
        aabbBit         :: 4;
        pairBit         :: 8;
        centerOfMassBit :: 16;

        e_shapeBit        :: shapeBit;
        e_jointBit        :: jointBit;
        e_aabbBit         :: aabbBit;
        e_pairBit         :: pairBit;
        e_centerOfMassBit :: centerOfMassBit;
    }

    /// Set the drawing flags.
    SetFlags :: (this: *b2Draw, flags: uint32) -> void #cpp_method #foreign box2d "?SetFlags@b2Draw@@QEAAXI@Z";

    /// Get the drawing flags.
    GetFlags :: (this: *b2Draw) -> uint32 #cpp_method #foreign box2d "?GetFlags@b2Draw@@QEBAIXZ";

    /// Append flags to the current flags.
    AppendFlags :: (this: *b2Draw, flags: uint32) -> void #cpp_method #foreign box2d "?AppendFlags@b2Draw@@QEAAXI@Z";

    /// Clear flags from the current flags.
    ClearFlags :: (this: *b2Draw, flags: uint32) -> void #cpp_method #foreign box2d "?ClearFlags@b2Draw@@QEAAXI@Z";

    m_drawFlags: uint32;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_Destructor :: (this: *b2Draw, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2Draw@@UEAA@XZ";
}
b2Draw_VTable :: struct #type_info_none {
    Destructor: (this: *b2Draw, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    DrawPolygon: (this: *b2Draw, vertices: *b2Vec2, vertexCount: int32, color: *b2Color) -> void #cpp_method;

    DrawSolidPolygon: (this: *b2Draw, vertices: *b2Vec2, vertexCount: int32, color: *b2Color) -> void #cpp_method;

    DrawCircle: (this: *b2Draw, center: *b2Vec2, radius: float, color: *b2Color) -> void #cpp_method;

    DrawSolidCircle: (this: *b2Draw, center: *b2Vec2, radius: float, axis: *b2Vec2, color: *b2Color) -> void #cpp_method;

    DrawSegment: (this: *b2Draw, p1: *b2Vec2, p2: *b2Vec2, color: *b2Color) -> void #cpp_method;

    DrawTransform: (this: *b2Draw, xf: *b2Transform) -> void #cpp_method;

    DrawPoint: (this: *b2Draw, p: *b2Vec2, size: float, color: *b2Color) -> void #cpp_method;
}

b2Draw_Destructor :: inline (this: *b2Draw, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2Draw_DrawPolygon :: inline (this: *b2Draw, vertices: *b2Vec2, vertexCount: int32, color: *b2Color) { this.vtable.DrawPolygon(this, vertices, vertexCount, color); }

b2Draw_DrawSolidPolygon :: inline (this: *b2Draw, vertices: *b2Vec2, vertexCount: int32, color: *b2Color) { this.vtable.DrawSolidPolygon(this, vertices, vertexCount, color); }

b2Draw_DrawCircle :: inline (this: *b2Draw, center: *b2Vec2, radius: float, color: *b2Color) { this.vtable.DrawCircle(this, center, radius, color); }

b2Draw_DrawSolidCircle :: inline (this: *b2Draw, center: *b2Vec2, radius: float, axis: *b2Vec2, color: *b2Color) { this.vtable.DrawSolidCircle(this, center, radius, axis, color); }

b2Draw_DrawSegment :: inline (this: *b2Draw, p1: *b2Vec2, p2: *b2Vec2, color: *b2Color) { this.vtable.DrawSegment(this, p1, p2, color); }

b2Draw_DrawTransform :: inline (this: *b2Draw, xf: *b2Transform) { this.vtable.DrawTransform(this, xf); }

b2Draw_DrawPoint :: inline (this: *b2Draw, p: *b2Vec2, size: float, color: *b2Color) { this.vtable.DrawPoint(this, p, size, color); }

vtable :: (obj: *b2Draw) -> *b2Draw_VTable { return obj.vtable; }


/// A line segment (edge) shape. These can be connected in chains or loops
/// to other edge shapes. Edges created independently are two-sided and do
/// no provide smooth movement across junctions.
b2EdgeShape :: struct {
    #as using b2shape: b2Shape;

    Constructor :: (this: *b2EdgeShape) -> void #cpp_method #foreign box2d "??0b2EdgeShape@@QEAA@XZ";

    /// Set this as a part of a sequence. Vertex v0 precedes the edge and vertex v3
    /// follows. These extra vertices are used to provide smooth movement
    /// across junctions. This also makes the collision one-sided. The edge
    /// normal points to the right looking from v1 to v2.
    SetOneSided :: (this: *b2EdgeShape, v0: *b2Vec2, v1: *b2Vec2, v2: *b2Vec2, v3: *b2Vec2) -> void #cpp_method #foreign box2d "?SetOneSided@b2EdgeShape@@QEAAXAEBUb2Vec2@@000@Z";
    SetOneSided :: (this: *b2EdgeShape, v0: b2Vec2, v1: b2Vec2, v2: b2Vec2, v3: b2Vec2) #no_context {
        SetOneSided(this, *v0, *v1, *v2, *v3);
    }

    /// Set this as an isolated edge. Collision is two-sided.
    SetTwoSided :: (this: *b2EdgeShape, v1: *b2Vec2, v2: *b2Vec2) -> void #cpp_method #foreign box2d "?SetTwoSided@b2EdgeShape@@QEAAXAEBUb2Vec2@@0@Z";
    SetTwoSided :: (this: *b2EdgeShape, v1: b2Vec2, v2: b2Vec2) #no_context {
        SetTwoSided(this, *v1, *v2);
    }

    /// These are the edge vertices
    m_vertex1:  b2Vec2;
    /// These are the edge vertices
    m_vertex2:  b2Vec2;

    /// Optional adjacent vertices. These are used for smooth collision.
    m_vertex0:  b2Vec2;
    /// Optional adjacent vertices. These are used for smooth collision.
    m_vertex3:  b2Vec2;

    /// Uses m_vertex0 and m_vertex3 to create smooth collision.
    m_oneSided: bool;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// Implement b2Shape.
    virtual_Clone :: (this: *b2EdgeShape, allocator: *b2BlockAllocator) -> *b2Shape #cpp_method #foreign box2d "?Clone@b2EdgeShape@@UEBAPEAVb2Shape@@PEAVb2BlockAllocator@@@Z";

    /// @see b2Shape::GetChildCount
    virtual_GetChildCount :: (this: *b2EdgeShape) -> int32 #cpp_method #foreign box2d "?GetChildCount@b2EdgeShape@@UEBAHXZ";

    /// @see b2Shape::TestPoint
    virtual_TestPoint :: (this: *b2EdgeShape, transform: *b2Transform, p: *b2Vec2) -> bool #cpp_method #foreign box2d "?TestPoint@b2EdgeShape@@UEBA_NAEBUb2Transform@@AEBUb2Vec2@@@Z";

    /// Implement b2Shape.
    virtual_RayCast :: (this: *b2EdgeShape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool #cpp_method #foreign box2d "?RayCast@b2EdgeShape@@UEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeAABB
    virtual_ComputeAABB :: (this: *b2EdgeShape, aabb: *b2AABB, transform: *b2Transform, childIndex: int32) -> void #cpp_method #foreign box2d "?ComputeAABB@b2EdgeShape@@UEBAXPEAUb2AABB@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeMass
    virtual_ComputeMass :: (this: *b2EdgeShape, massData: *b2MassData, density: float) -> void #cpp_method #foreign box2d "?ComputeMass@b2EdgeShape@@UEBAXPEAUb2MassData@@M@Z";
}

/// Friction joint definition.
b2FrictionJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2FrictionJointDef) -> void #cpp_method #foreign box2d "??0b2FrictionJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, axis, and reference angle using the world
    /// anchor and world axis.
    Initialize :: (this: *b2FrictionJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2FrictionJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@@Z";
    Initialize :: (this: *b2FrictionJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchor);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA: b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB: b2Vec2;

    /// The maximum friction force in N.
    maxForce:     float;

    /// The maximum friction torque in N-m.
    maxTorque:    float;
}

/// Friction joint. This is used for top-down friction.
/// It provides 2D translational friction and angular friction.
b2FrictionJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2FrictionJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2FrictionJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2FrictionJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2FrictionJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Set the maximum friction force in N.
    SetMaxForce :: (this: *b2FrictionJoint, force: float) -> void #cpp_method #foreign box2d "?SetMaxForce@b2FrictionJoint@@QEAAXM@Z";

    /// Get the maximum friction force in N.
    GetMaxForce :: (this: *b2FrictionJoint) -> float #cpp_method #foreign box2d "?GetMaxForce@b2FrictionJoint@@QEBAMXZ";

    /// Set the maximum friction torque in N*m.
    SetMaxTorque :: (this: *b2FrictionJoint, torque: float) -> void #cpp_method #foreign box2d "?SetMaxTorque@b2FrictionJoint@@QEAAXM@Z";

    /// Get the maximum friction torque in N*m.
    GetMaxTorque :: (this: *b2FrictionJoint) -> float #cpp_method #foreign box2d "?GetMaxTorque@b2FrictionJoint@@QEBAMXZ";

    Constructor :: (this: *b2FrictionJoint, def: *b2FrictionJointDef) -> void #cpp_method #foreign box2d "??0b2FrictionJoint@@IEAA@PEBUb2FrictionJointDef@@@Z";

    m_localAnchorA:   b2Vec2;
    m_localAnchorB:   b2Vec2;

    // Solver shared
    m_linearImpulse:  b2Vec2;
    m_angularImpulse: float;
    m_maxForce:       float;
    m_maxTorque:      float;

    // Solver temp
    m_indexA:         int32;
    m_indexB:         int32;
    m_rA:             b2Vec2;
    m_rB:             b2Vec2;
    m_localCenterA:   b2Vec2;
    m_localCenterB:   b2Vec2;
    m_invMassA:       float;
    m_invMassB:       float;
    m_invIA:          float;
    m_invIB:          float;
    m_linearMass:     b2Mat22;
    m_angularMass:    float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2FrictionJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2FrictionJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2FrictionJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2FrictionJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2FrictionJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2FrictionJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2FrictionJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2FrictionJoint@@UEBAMM@Z";

    /// Dump joint to dmLog
    virtual_Dump :: (this: *b2FrictionJoint) -> void #cpp_method #foreign box2d "?Dump@b2FrictionJoint@@UEAAXXZ";

    virtual_InitVelocityConstraints :: (this: *b2FrictionJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2FrictionJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2FrictionJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2FrictionJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2FrictionJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2FrictionJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Gear joint definition. This definition requires two existing
/// revolute or prismatic joints (any combination will work).
/// @warning bodyB on the input joints must both be dynamic
b2GearJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2GearJointDef) -> void #cpp_method #foreign box2d "??0b2GearJointDef@@QEAA@XZ";

    /// The first revolute/prismatic joint attached to the gear joint.
    joint1: *b2Joint;

    /// The second revolute/prismatic joint attached to the gear joint.
    joint2: *b2Joint;

    /// The gear ratio.
    /// @see b2GearJoint for explanation.
    ratio:  float;
}

/// A gear joint is used to connect two joints together. Either joint
/// can be a revolute or prismatic joint. You specify a gear ratio
/// to bind the motions together:
/// coordinate1 + ratio * coordinate2 = constant
/// The ratio can be negative or positive. If one joint is a revolute joint
/// and the other joint is a prismatic joint, then the ratio will have units
/// of length or units of 1/length.
/// @warning You have to manually destroy the gear joint if joint1 or joint2
/// is destroyed.
b2GearJoint :: struct {
    #as using b2joint: b2Joint;

    /// Get the first joint.
    GetJoint1 :: (this: *b2GearJoint) -> *b2Joint #cpp_method #foreign box2d "?GetJoint1@b2GearJoint@@QEAAPEAVb2Joint@@XZ";

    /// Get the second joint.
    GetJoint2 :: (this: *b2GearJoint) -> *b2Joint #cpp_method #foreign box2d "?GetJoint2@b2GearJoint@@QEAAPEAVb2Joint@@XZ";

    /// Set/Get the gear ratio.
    SetRatio :: (this: *b2GearJoint, ratio: float) -> void #cpp_method #foreign box2d "?SetRatio@b2GearJoint@@QEAAXM@Z";
    GetRatio :: (this: *b2GearJoint) -> float #cpp_method #foreign box2d "?GetRatio@b2GearJoint@@QEBAMXZ";

    Constructor :: (this: *b2GearJoint, data: *b2GearJointDef) -> void #cpp_method #foreign box2d "??0b2GearJoint@@IEAA@PEBUb2GearJointDef@@@Z";

    m_joint1:          *b2Joint;
    m_joint2:          *b2Joint;

    m_typeA:           b2JointType;
    m_typeB:           b2JointType;

    // Body A is connected to body C
    // Body B is connected to body D
    m_bodyC:           *b2Body;
    m_bodyD:           *b2Body;

    // Solver shared
    m_localAnchorA:    b2Vec2;
    m_localAnchorB:    b2Vec2;
    m_localAnchorC:    b2Vec2;
    m_localAnchorD:    b2Vec2;

    m_localAxisC:      b2Vec2;
    m_localAxisD:      b2Vec2;

    m_referenceAngleA: float;
    m_referenceAngleB: float;

    m_constant:        float;
    m_ratio:           float;

    m_impulse:         float;

    // Solver temp
    m_indexA:          int32;
    // Solver temp
    m_indexB:          int32;
    // Solver temp
    m_indexC:          int32;
    // Solver temp
    m_indexD:          int32;
    m_lcA:             b2Vec2;
    m_lcB:             b2Vec2;
    m_lcC:             b2Vec2;
    m_lcD:             b2Vec2;
    m_mA:              float;
    m_mB:              float;
    m_mC:              float;
    m_mD:              float;
    m_iA:              float;
    m_iB:              float;
    m_iC:              float;
    m_iD:              float;
    m_JvAC:            b2Vec2;
    m_JvBD:            b2Vec2;
    m_JwA:             float;
    m_JwB:             float;
    m_JwC:             float;
    m_JwD:             float;
    m_mass:            float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2GearJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2GearJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2GearJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2GearJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2GearJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2GearJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2GearJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2GearJoint@@UEBAMM@Z";

    /// Dump joint to dmLog
    virtual_Dump :: (this: *b2GearJoint) -> void #cpp_method #foreign box2d "?Dump@b2GearJoint@@UEAAXXZ";

    virtual_InitVelocityConstraints :: (this: *b2GearJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2GearJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2GearJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2GearJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2GearJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2GearJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Motor joint definition.
b2MotorJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2MotorJointDef) -> void #cpp_method #foreign box2d "??0b2MotorJointDef@@QEAA@XZ";

    /// Initialize the bodies and offsets using the current transforms.
    Initialize :: (this: *b2MotorJointDef, bodyA: *b2Body, bodyB: *b2Body) -> void #cpp_method #foreign box2d "?Initialize@b2MotorJointDef@@QEAAXPEAVb2Body@@0@Z";

    /// Position of bodyB minus the position of bodyA, in bodyA's frame, in meters.
    linearOffset:     b2Vec2;

    /// The bodyB angle minus bodyA angle in radians.
    angularOffset:    float;

    /// The maximum motor force in N.
    maxForce:         float;

    /// The maximum motor torque in N-m.
    maxTorque:        float;

    /// Position correction factor in the range [0,1].
    correctionFactor: float;
}

/// A motor joint is used to control the relative motion
/// between two bodies. A typical usage is to control the movement
/// of a dynamic body with respect to the ground.
b2MotorJoint :: struct {
    #as using b2joint: b2Joint;

    /// Set/get the target linear offset, in frame A, in meters.
    SetLinearOffset :: (this: *b2MotorJoint, linearOffset: *b2Vec2) -> void #cpp_method #foreign box2d "?SetLinearOffset@b2MotorJoint@@QEAAXAEBUb2Vec2@@@Z";
    SetLinearOffset :: (this: *b2MotorJoint, linearOffset: b2Vec2) #no_context {
        SetLinearOffset(this, *linearOffset);
    }
    GetLinearOffset :: (this: *b2MotorJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLinearOffset@b2MotorJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Set/get the target angular offset, in radians.
    SetAngularOffset :: (this: *b2MotorJoint, angularOffset: float) -> void #cpp_method #foreign box2d "?SetAngularOffset@b2MotorJoint@@QEAAXM@Z";
    GetAngularOffset :: (this: *b2MotorJoint) -> float #cpp_method #foreign box2d "?GetAngularOffset@b2MotorJoint@@QEBAMXZ";

    /// Set the maximum friction force in N.
    SetMaxForce :: (this: *b2MotorJoint, force: float) -> void #cpp_method #foreign box2d "?SetMaxForce@b2MotorJoint@@QEAAXM@Z";

    /// Get the maximum friction force in N.
    GetMaxForce :: (this: *b2MotorJoint) -> float #cpp_method #foreign box2d "?GetMaxForce@b2MotorJoint@@QEBAMXZ";

    /// Set the maximum friction torque in N*m.
    SetMaxTorque :: (this: *b2MotorJoint, torque: float) -> void #cpp_method #foreign box2d "?SetMaxTorque@b2MotorJoint@@QEAAXM@Z";

    /// Get the maximum friction torque in N*m.
    GetMaxTorque :: (this: *b2MotorJoint) -> float #cpp_method #foreign box2d "?GetMaxTorque@b2MotorJoint@@QEBAMXZ";

    /// Set the position correction factor in the range [0,1].
    SetCorrectionFactor :: (this: *b2MotorJoint, factor: float) -> void #cpp_method #foreign box2d "?SetCorrectionFactor@b2MotorJoint@@QEAAXM@Z";

    /// Get the position correction factor in the range [0,1].
    GetCorrectionFactor :: (this: *b2MotorJoint) -> float #cpp_method #foreign box2d "?GetCorrectionFactor@b2MotorJoint@@QEBAMXZ";

    Constructor :: (this: *b2MotorJoint, def: *b2MotorJointDef) -> void #cpp_method #foreign box2d "??0b2MotorJoint@@IEAA@PEBUb2MotorJointDef@@@Z";

    // Solver shared
    m_linearOffset:     b2Vec2;
    m_angularOffset:    float;
    m_linearImpulse:    b2Vec2;
    m_angularImpulse:   float;
    m_maxForce:         float;
    m_maxTorque:        float;
    m_correctionFactor: float;

    // Solver temp
    m_indexA:           int32;
    m_indexB:           int32;
    m_rA:               b2Vec2;
    m_rB:               b2Vec2;
    m_localCenterA:     b2Vec2;
    m_localCenterB:     b2Vec2;
    m_linearError:      b2Vec2;
    m_angularError:     float;
    m_invMassA:         float;
    m_invMassB:         float;
    m_invIA:            float;
    m_invIB:            float;
    m_linearMass:       b2Mat22;
    m_angularMass:      float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2MotorJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2MotorJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2MotorJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2MotorJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2MotorJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2MotorJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2MotorJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2MotorJoint@@UEBAMM@Z";

    /// Dump to b2Log
    virtual_Dump :: (this: *b2MotorJoint) -> void #cpp_method #foreign box2d "?Dump@b2MotorJoint@@UEAAXXZ";

    virtual_InitVelocityConstraints :: (this: *b2MotorJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2MotorJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2MotorJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2MotorJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2MotorJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2MotorJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Mouse joint definition. This requires a world target point,
/// tuning parameters, and the time step.
b2MouseJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2MouseJointDef) -> void #cpp_method #foreign box2d "??0b2MouseJointDef@@QEAA@XZ";

    /// The initial world target point. This is assumed
    /// to coincide with the body anchor initially.
    target:    b2Vec2;

    /// The maximum constraint force that can be exerted
    /// to move the candidate body. Usually you will express
    /// as some multiple of the weight (multiplier * mass * gravity).
    maxForce:  float;

    /// The linear stiffness in N/m
    stiffness: float;

    /// The linear damping in N*s/m
    damping:   float;
}

/// A mouse joint is used to make a point on a body track a
/// specified world point. This a soft constraint with a maximum
/// force. This allows the constraint to stretch and without
/// applying huge forces.
/// NOTE: this joint is not documented in the manual because it was
/// developed to be used in the testbed. If you want to learn how to
/// use the mouse joint, look at the testbed.
b2MouseJoint :: struct {
    #as using b2joint: b2Joint;

    /// Use this to update the target point.
    SetTarget :: (this: *b2MouseJoint, target: *b2Vec2) -> void #cpp_method #foreign box2d "?SetTarget@b2MouseJoint@@QEAAXAEBUb2Vec2@@@Z";
    SetTarget :: (this: *b2MouseJoint, target: b2Vec2) #no_context {
        SetTarget(this, *target);
    }
    GetTarget :: (this: *b2MouseJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetTarget@b2MouseJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Set/get the maximum force in Newtons.
    SetMaxForce :: (this: *b2MouseJoint, force: float) -> void #cpp_method #foreign box2d "?SetMaxForce@b2MouseJoint@@QEAAXM@Z";
    GetMaxForce :: (this: *b2MouseJoint) -> float #cpp_method #foreign box2d "?GetMaxForce@b2MouseJoint@@QEBAMXZ";

    /// Set/get the linear stiffness in N/m
    SetStiffness :: (this: *b2MouseJoint, stiffness: float) -> void #cpp_method #foreign box2d "?SetStiffness@b2MouseJoint@@QEAAXM@Z";
    GetStiffness :: (this: *b2MouseJoint) -> float #cpp_method #foreign box2d "?GetStiffness@b2MouseJoint@@QEBAMXZ";

    /// Set/get linear damping in N*s/m
    SetDamping :: (this: *b2MouseJoint, damping: float) -> void #cpp_method #foreign box2d "?SetDamping@b2MouseJoint@@QEAAXM@Z";
    GetDamping :: (this: *b2MouseJoint) -> float #cpp_method #foreign box2d "?GetDamping@b2MouseJoint@@QEBAMXZ";

    Constructor :: (this: *b2MouseJoint, def: *b2MouseJointDef) -> void #cpp_method #foreign box2d "??0b2MouseJoint@@IEAA@PEBUb2MouseJointDef@@@Z";

    m_localAnchorB: b2Vec2;
    m_targetA:      b2Vec2;
    m_stiffness:    float;
    m_damping:      float;
    m_beta:         float;

    // Solver shared
    m_impulse:      b2Vec2;
    m_maxForce:     float;
    m_gamma:        float;

    // Solver temp
    m_indexA:       int32;
    m_indexB:       int32;
    m_rB:           b2Vec2;
    m_localCenterB: b2Vec2;
    m_invMassB:     float;
    m_invIB:        float;
    m_mass:         b2Mat22;
    m_C:            b2Vec2;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// Implements b2Joint.
    virtual_GetAnchorA :: (this: *b2MouseJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2MouseJoint@@UEBA?AUb2Vec2@@XZ";

    /// Implements b2Joint.
    virtual_GetAnchorB :: (this: *b2MouseJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2MouseJoint@@UEBA?AUb2Vec2@@XZ";

    /// Implements b2Joint.
    virtual_GetReactionForce :: (this: *b2MouseJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2MouseJoint@@UEBA?AUb2Vec2@@M@Z";

    /// Implements b2Joint.
    virtual_GetReactionTorque :: (this: *b2MouseJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2MouseJoint@@UEBAMM@Z";

    /// The mouse joint does not support dumping.
    virtual_Dump :: (this: *b2MouseJoint) -> void #cpp_method #foreign box2d "?Dump@b2MouseJoint@@UEAAXXZ";

    /// Implement b2Joint::ShiftOrigin
    virtual_ShiftOrigin :: (this: *b2MouseJoint, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2MouseJoint@@UEAAXAEBUb2Vec2@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2MouseJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2MouseJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2MouseJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2MouseJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2MouseJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2MouseJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// A solid convex polygon. It is assumed that the interior of the polygon is to
/// the left of each edge.
/// Polygons have a maximum number of vertices equal to b2_maxPolygonVertices.
/// In most cases you should not need many vertices for a convex polygon.
b2PolygonShape :: struct {
    #as using b2shape: b2Shape;

    Constructor :: (this: *b2PolygonShape) -> void #cpp_method #foreign box2d "??0b2PolygonShape@@QEAA@XZ";

    /// Create a convex hull from the given array of local points.
    /// The count must be in the range [3, b2_maxPolygonVertices].
    /// @warning the points may be re-ordered, even if they form a convex polygon
    /// @warning collinear points are handled but not removed. Collinear points
    /// may lead to poor stacking behavior.
    Set :: (this: *b2PolygonShape, points: *b2Vec2, count: int32) -> void #cpp_method #foreign box2d "?Set@b2PolygonShape@@QEAAXPEBUb2Vec2@@H@Z";

    /// Build vertices to represent an axis-aligned box centered on the local origin.
    /// @param hx the half-width.
    /// @param hy the half-height.
    SetAsBox :: (this: *b2PolygonShape, hx: float, hy: float) -> void #cpp_method #foreign box2d "?SetAsBox@b2PolygonShape@@QEAAXMM@Z";

    /// Build vertices to represent an oriented box.
    /// @param hx the half-width.
    /// @param hy the half-height.
    /// @param center the center of the box in local coordinates.
    /// @param angle the rotation of the box in local coordinates.
    SetAsBox :: (this: *b2PolygonShape, hx: float, hy: float, center: *b2Vec2, angle: float) -> void #cpp_method #foreign box2d "?SetAsBox@b2PolygonShape@@QEAAXMMAEBUb2Vec2@@M@Z";
    SetAsBox :: (this: *b2PolygonShape, hx: float, hy: float, center: b2Vec2, angle: float) #no_context {
        SetAsBox(this, hx, hy, *center, angle);
    }

    /// Validate convexity. This is a very time consuming operation.
    /// @returns true if valid
    Validate :: (this: *b2PolygonShape) -> bool #cpp_method #foreign box2d "?Validate@b2PolygonShape@@QEBA_NXZ";

    m_centroid: b2Vec2;
    m_vertices: [8] b2Vec2;
    m_normals:  [8] b2Vec2;
    m_count:    int32;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    /// Implement b2Shape.
    virtual_Clone :: (this: *b2PolygonShape, allocator: *b2BlockAllocator) -> *b2Shape #cpp_method #foreign box2d "?Clone@b2PolygonShape@@UEBAPEAVb2Shape@@PEAVb2BlockAllocator@@@Z";

    /// @see b2Shape::GetChildCount
    virtual_GetChildCount :: (this: *b2PolygonShape) -> int32 #cpp_method #foreign box2d "?GetChildCount@b2PolygonShape@@UEBAHXZ";

    /// @see b2Shape::TestPoint
    virtual_TestPoint :: (this: *b2PolygonShape, transform: *b2Transform, p: *b2Vec2) -> bool #cpp_method #foreign box2d "?TestPoint@b2PolygonShape@@UEBA_NAEBUb2Transform@@AEBUb2Vec2@@@Z";

    /// Implement b2Shape.
    /// @note because the polygon is solid, rays that start inside do not hit because the normal is
    /// not defined.
    virtual_RayCast :: (this: *b2PolygonShape, output: *b2RayCastOutput, input: *b2RayCastInput, transform: *b2Transform, childIndex: int32) -> bool #cpp_method #foreign box2d "?RayCast@b2PolygonShape@@UEBA_NPEAUb2RayCastOutput@@AEBUb2RayCastInput@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeAABB
    virtual_ComputeAABB :: (this: *b2PolygonShape, aabb: *b2AABB, transform: *b2Transform, childIndex: int32) -> void #cpp_method #foreign box2d "?ComputeAABB@b2PolygonShape@@UEBAXPEAUb2AABB@@AEBUb2Transform@@H@Z";

    /// @see b2Shape::ComputeMass
    virtual_ComputeMass :: (this: *b2PolygonShape, massData: *b2MassData, density: float) -> void #cpp_method #foreign box2d "?ComputeMass@b2PolygonShape@@UEBAXPEAUb2MassData@@M@Z";
}

/// Prismatic joint definition. This requires defining a line of
/// motion using an axis and an anchor point. The definition uses local
/// anchor points and a local axis so that the initial configuration
/// can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space. Using local
/// anchors and a local axis helps when saving and loading a game.
b2PrismaticJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2PrismaticJointDef) -> void #cpp_method #foreign box2d "??0b2PrismaticJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, axis, and reference angle using the world
    /// anchor and unit world axis.
    Initialize :: (this: *b2PrismaticJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: *b2Vec2, axis: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2PrismaticJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@1@Z";
    Initialize :: (this: *b2PrismaticJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: b2Vec2, axis: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchor, *axis);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA:     b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB:     b2Vec2;

    /// The local translation unit axis in bodyA.
    localAxisA:       b2Vec2;

    /// The constrained angle between the bodies: bodyB_angle - bodyA_angle.
    referenceAngle:   float;

    /// Enable/disable the joint limit.
    enableLimit:      bool;

    /// The lower translation limit, usually in meters.
    lowerTranslation: float;

    /// The upper translation limit, usually in meters.
    upperTranslation: float;

    /// Enable/disable the joint motor.
    enableMotor:      bool;

    /// The maximum motor torque, usually in N-m.
    maxMotorForce:    float;

    /// The desired motor speed in radians per second.
    motorSpeed:       float;
}

/// A prismatic joint. This joint provides one degree of freedom: translation
/// along an axis fixed in bodyA. Relative rotation is prevented. You can
/// use a joint limit to restrict the range of motion and a joint motor to
/// drive the motion or to model joint friction.
b2PrismaticJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2PrismaticJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2PrismaticJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2PrismaticJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2PrismaticJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local joint axis relative to bodyA.
    GetLocalAxisA :: (this: *b2PrismaticJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAxisA@b2PrismaticJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Get the reference angle.
    GetReferenceAngle :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetReferenceAngle@b2PrismaticJoint@@QEBAMXZ";

    /// Get the current joint translation, usually in meters.
    GetJointTranslation :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetJointTranslation@b2PrismaticJoint@@QEBAMXZ";

    /// Get the current joint translation speed, usually in meters per second.
    GetJointSpeed :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetJointSpeed@b2PrismaticJoint@@QEBAMXZ";

    /// Is the joint limit enabled?
    IsLimitEnabled :: (this: *b2PrismaticJoint) -> bool #cpp_method #foreign box2d "?IsLimitEnabled@b2PrismaticJoint@@QEBA_NXZ";

    /// Enable/disable the joint limit.
    EnableLimit :: (this: *b2PrismaticJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableLimit@b2PrismaticJoint@@QEAAX_N@Z";

    /// Get the lower joint limit, usually in meters.
    GetLowerLimit :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetLowerLimit@b2PrismaticJoint@@QEBAMXZ";

    /// Get the upper joint limit, usually in meters.
    GetUpperLimit :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetUpperLimit@b2PrismaticJoint@@QEBAMXZ";

    /// Set the joint limits, usually in meters.
    SetLimits :: (this: *b2PrismaticJoint, lower: float, upper: float) -> void #cpp_method #foreign box2d "?SetLimits@b2PrismaticJoint@@QEAAXMM@Z";

    /// Is the joint motor enabled?
    IsMotorEnabled :: (this: *b2PrismaticJoint) -> bool #cpp_method #foreign box2d "?IsMotorEnabled@b2PrismaticJoint@@QEBA_NXZ";

    /// Enable/disable the joint motor.
    EnableMotor :: (this: *b2PrismaticJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableMotor@b2PrismaticJoint@@QEAAX_N@Z";

    /// Set the motor speed, usually in meters per second.
    SetMotorSpeed :: (this: *b2PrismaticJoint, speed: float) -> void #cpp_method #foreign box2d "?SetMotorSpeed@b2PrismaticJoint@@QEAAXM@Z";

    /// Get the motor speed, usually in meters per second.
    GetMotorSpeed :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetMotorSpeed@b2PrismaticJoint@@QEBAMXZ";

    /// Set the maximum motor force, usually in N.
    SetMaxMotorForce :: (this: *b2PrismaticJoint, force: float) -> void #cpp_method #foreign box2d "?SetMaxMotorForce@b2PrismaticJoint@@QEAAXM@Z";
    GetMaxMotorForce :: (this: *b2PrismaticJoint) -> float #cpp_method #foreign box2d "?GetMaxMotorForce@b2PrismaticJoint@@QEBAMXZ";

    /// Get the current motor force given the inverse time step, usually in N.
    GetMotorForce :: (this: *b2PrismaticJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetMotorForce@b2PrismaticJoint@@QEBAMM@Z";

    Constructor :: (this: *b2PrismaticJoint, def: *b2PrismaticJointDef) -> void #cpp_method #foreign box2d "??0b2PrismaticJoint@@IEAA@PEBUb2PrismaticJointDef@@@Z";

    m_localAnchorA:     b2Vec2;
    m_localAnchorB:     b2Vec2;
    m_localXAxisA:      b2Vec2;
    m_localYAxisA:      b2Vec2;
    m_referenceAngle:   float;
    m_impulse:          b2Vec2;
    m_motorImpulse:     float;
    m_lowerImpulse:     float;
    m_upperImpulse:     float;
    m_lowerTranslation: float;
    m_upperTranslation: float;
    m_maxMotorForce:    float;
    m_motorSpeed:       float;
    m_enableLimit:      bool;
    m_enableMotor:      bool;

    // Solver temp
    m_indexA:           int32;
    m_indexB:           int32;
    m_localCenterA:     b2Vec2;
    m_localCenterB:     b2Vec2;
    m_invMassA:         float;
    m_invMassB:         float;
    m_invIA:            float;
    m_invIB:            float;
    m_axis:             b2Vec2;
    m_perp:             b2Vec2;
    m_s1:               float;
    m_s2:               float;
    m_a1:               float;
    m_a2:               float;
    m_K:                b2Mat22;
    m_translation:      float;
    m_axialMass:        float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2PrismaticJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2PrismaticJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2PrismaticJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2PrismaticJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2PrismaticJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2PrismaticJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2PrismaticJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2PrismaticJoint@@UEBAMM@Z";

    /// Dump to b2Log
    virtual_Dump :: (this: *b2PrismaticJoint) -> void #cpp_method #foreign box2d "?Dump@b2PrismaticJoint@@UEAAXXZ";

    ///
    virtual_Draw :: (this: *b2PrismaticJoint, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2PrismaticJoint@@UEBAXPEAVb2Draw@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2PrismaticJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2PrismaticJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2PrismaticJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2PrismaticJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2PrismaticJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2PrismaticJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Pulley joint definition. This requires two ground anchors,
/// two dynamic body anchor points, and a pulley ratio.
b2PulleyJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2PulleyJointDef) -> void #cpp_method #foreign box2d "??0b2PulleyJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, lengths, max lengths, and ratio using the world anchors.
    Initialize :: (this: *b2PulleyJointDef, bodyA: *b2Body, bodyB: *b2Body, groundAnchorA: *b2Vec2, groundAnchorB: *b2Vec2, anchorA: *b2Vec2, anchorB: *b2Vec2, ratio: float) -> void #cpp_method #foreign box2d "?Initialize@b2PulleyJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@111M@Z";
    Initialize :: (this: *b2PulleyJointDef, bodyA: *b2Body, bodyB: *b2Body, groundAnchorA: b2Vec2, groundAnchorB: b2Vec2, anchorA: b2Vec2, anchorB: b2Vec2, ratio: float) #no_context {
        Initialize(this, bodyA, bodyB, *groundAnchorA, *groundAnchorB, *anchorA, *anchorB, ratio);
    }

    /// The first ground anchor in world coordinates. This point never moves.
    groundAnchorA: b2Vec2;

    /// The second ground anchor in world coordinates. This point never moves.
    groundAnchorB: b2Vec2;

    /// The local anchor point relative to bodyA's origin.
    localAnchorA:  b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB:  b2Vec2;

    /// The a reference length for the segment attached to bodyA.
    lengthA:       float;

    /// The a reference length for the segment attached to bodyB.
    lengthB:       float;

    /// The pulley ratio, used to simulate a block-and-tackle.
    ratio:         float;
}

/// The pulley joint is connected to two bodies and two fixed ground points.
/// The pulley supports a ratio such that:
/// length1 + ratio * length2 <= constant
/// Yes, the force transmitted is scaled by the ratio.
/// Warning: the pulley joint can get a bit squirrelly by itself. They often
/// work better when combined with prismatic joints. You should also cover the
/// the anchor points with static shapes to prevent one side from going to
/// zero length.
b2PulleyJoint :: struct {
    #as using b2joint: b2Joint;

    /// Get the first ground anchor.
    GetGroundAnchorA :: (this: *b2PulleyJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetGroundAnchorA@b2PulleyJoint@@QEBA?AUb2Vec2@@XZ";

    /// Get the second ground anchor.
    GetGroundAnchorB :: (this: *b2PulleyJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetGroundAnchorB@b2PulleyJoint@@QEBA?AUb2Vec2@@XZ";

    /// Get the current length of the segment attached to bodyA.
    GetLengthA :: (this: *b2PulleyJoint) -> float #cpp_method #foreign box2d "?GetLengthA@b2PulleyJoint@@QEBAMXZ";

    /// Get the current length of the segment attached to bodyB.
    GetLengthB :: (this: *b2PulleyJoint) -> float #cpp_method #foreign box2d "?GetLengthB@b2PulleyJoint@@QEBAMXZ";

    /// Get the pulley ratio.
    GetRatio :: (this: *b2PulleyJoint) -> float #cpp_method #foreign box2d "?GetRatio@b2PulleyJoint@@QEBAMXZ";

    /// Get the current length of the segment attached to bodyA.
    GetCurrentLengthA :: (this: *b2PulleyJoint) -> float #cpp_method #foreign box2d "?GetCurrentLengthA@b2PulleyJoint@@QEBAMXZ";

    /// Get the current length of the segment attached to bodyB.
    GetCurrentLengthB :: (this: *b2PulleyJoint) -> float #cpp_method #foreign box2d "?GetCurrentLengthB@b2PulleyJoint@@QEBAMXZ";

    Constructor :: (this: *b2PulleyJoint, data: *b2PulleyJointDef) -> void #cpp_method #foreign box2d "??0b2PulleyJoint@@IEAA@PEBUb2PulleyJointDef@@@Z";

    m_groundAnchorA: b2Vec2;
    m_groundAnchorB: b2Vec2;
    m_lengthA:       float;
    m_lengthB:       float;

    // Solver shared
    m_localAnchorA:  b2Vec2;
    m_localAnchorB:  b2Vec2;
    m_constant:      float;
    m_ratio:         float;
    m_impulse:       float;

    // Solver temp
    m_indexA:        int32;
    m_indexB:        int32;
    m_uA:            b2Vec2;
    m_uB:            b2Vec2;
    m_rA:            b2Vec2;
    m_rB:            b2Vec2;
    m_localCenterA:  b2Vec2;
    m_localCenterB:  b2Vec2;
    m_invMassA:      float;
    m_invMassB:      float;
    m_invIA:         float;
    m_invIB:         float;
    m_mass:          float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2PulleyJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2PulleyJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2PulleyJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2PulleyJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2PulleyJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2PulleyJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2PulleyJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2PulleyJoint@@UEBAMM@Z";

    /// Dump joint to dmLog
    virtual_Dump :: (this: *b2PulleyJoint) -> void #cpp_method #foreign box2d "?Dump@b2PulleyJoint@@UEAAXXZ";

    /// Implement b2Joint::ShiftOrigin
    virtual_ShiftOrigin :: (this: *b2PulleyJoint, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2PulleyJoint@@UEAAXAEBUb2Vec2@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2PulleyJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2PulleyJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2PulleyJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2PulleyJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2PulleyJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2PulleyJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Revolute joint definition. This requires defining an anchor point where the
/// bodies are joined. The definition uses local anchor points so that the
/// initial configuration can violate the constraint slightly. You also need to
/// specify the initial relative angle for joint limits. This helps when saving
/// and loading a game.
/// The local anchor points are measured from the body's origin
/// rather than the center of mass because:
/// 1. you might not know where the center of mass will be.
/// 2. if you add/remove shapes from a body and recompute the mass,
///    the joints will be broken.
b2RevoluteJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2RevoluteJointDef) -> void #cpp_method #foreign box2d "??0b2RevoluteJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, and reference angle using a world
    /// anchor point.
    Initialize :: (this: *b2RevoluteJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2RevoluteJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@@Z";
    Initialize :: (this: *b2RevoluteJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchor);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA:   b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB:   b2Vec2;

    /// The bodyB angle minus bodyA angle in the reference state (radians).
    referenceAngle: float;

    /// A flag to enable joint limits.
    enableLimit:    bool;

    /// The lower angle for the joint limit (radians).
    lowerAngle:     float;

    /// The upper angle for the joint limit (radians).
    upperAngle:     float;

    /// A flag to enable the joint motor.
    enableMotor:    bool;

    /// The desired motor speed. Usually in radians per second.
    motorSpeed:     float;

    /// The maximum motor torque used to achieve the desired motor speed.
    /// Usually in N-m.
    maxMotorTorque: float;
}

/// A revolute joint constrains two bodies to share a common point while they
/// are free to rotate about the point. The relative rotation about the shared
/// point is the joint angle. You can limit the relative rotation with
/// a joint limit that specifies a lower and upper angle. You can use a motor
/// to drive the relative rotation about the shared point. A maximum motor torque
/// is provided so that infinite forces are not generated.
b2RevoluteJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2RevoluteJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2RevoluteJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2RevoluteJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2RevoluteJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Get the reference angle.
    GetReferenceAngle :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetReferenceAngle@b2RevoluteJoint@@QEBAMXZ";

    /// Get the current joint angle in radians.
    GetJointAngle :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetJointAngle@b2RevoluteJoint@@QEBAMXZ";

    /// Get the current joint angle speed in radians per second.
    GetJointSpeed :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetJointSpeed@b2RevoluteJoint@@QEBAMXZ";

    /// Is the joint limit enabled?
    IsLimitEnabled :: (this: *b2RevoluteJoint) -> bool #cpp_method #foreign box2d "?IsLimitEnabled@b2RevoluteJoint@@QEBA_NXZ";

    /// Enable/disable the joint limit.
    EnableLimit :: (this: *b2RevoluteJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableLimit@b2RevoluteJoint@@QEAAX_N@Z";

    /// Get the lower joint limit in radians.
    GetLowerLimit :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetLowerLimit@b2RevoluteJoint@@QEBAMXZ";

    /// Get the upper joint limit in radians.
    GetUpperLimit :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetUpperLimit@b2RevoluteJoint@@QEBAMXZ";

    /// Set the joint limits in radians.
    SetLimits :: (this: *b2RevoluteJoint, lower: float, upper: float) -> void #cpp_method #foreign box2d "?SetLimits@b2RevoluteJoint@@QEAAXMM@Z";

    /// Is the joint motor enabled?
    IsMotorEnabled :: (this: *b2RevoluteJoint) -> bool #cpp_method #foreign box2d "?IsMotorEnabled@b2RevoluteJoint@@QEBA_NXZ";

    /// Enable/disable the joint motor.
    EnableMotor :: (this: *b2RevoluteJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableMotor@b2RevoluteJoint@@QEAAX_N@Z";

    /// Set the motor speed in radians per second.
    SetMotorSpeed :: (this: *b2RevoluteJoint, speed: float) -> void #cpp_method #foreign box2d "?SetMotorSpeed@b2RevoluteJoint@@QEAAXM@Z";

    /// Get the motor speed in radians per second.
    GetMotorSpeed :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetMotorSpeed@b2RevoluteJoint@@QEBAMXZ";

    /// Set the maximum motor torque, usually in N-m.
    SetMaxMotorTorque :: (this: *b2RevoluteJoint, torque: float) -> void #cpp_method #foreign box2d "?SetMaxMotorTorque@b2RevoluteJoint@@QEAAXM@Z";
    GetMaxMotorTorque :: (this: *b2RevoluteJoint) -> float #cpp_method #foreign box2d "?GetMaxMotorTorque@b2RevoluteJoint@@QEBAMXZ";

    /// Get the current motor torque given the inverse time step.
    /// Unit is N*m.
    GetMotorTorque :: (this: *b2RevoluteJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetMotorTorque@b2RevoluteJoint@@QEBAMM@Z";

    Constructor :: (this: *b2RevoluteJoint, def: *b2RevoluteJointDef) -> void #cpp_method #foreign box2d "??0b2RevoluteJoint@@IEAA@PEBUb2RevoluteJointDef@@@Z";

    // Solver shared
    m_localAnchorA:   b2Vec2;
    m_localAnchorB:   b2Vec2;
    m_impulse:        b2Vec2;
    m_motorImpulse:   float;
    m_lowerImpulse:   float;
    m_upperImpulse:   float;
    m_enableMotor:    bool;
    m_maxMotorTorque: float;
    m_motorSpeed:     float;
    m_enableLimit:    bool;
    m_referenceAngle: float;
    m_lowerAngle:     float;
    m_upperAngle:     float;

    // Solver temp
    m_indexA:         int32;
    m_indexB:         int32;
    m_rA:             b2Vec2;
    m_rB:             b2Vec2;
    m_localCenterA:   b2Vec2;
    m_localCenterB:   b2Vec2;
    m_invMassA:       float;
    m_invMassB:       float;
    m_invIA:          float;
    m_invIB:          float;
    m_K:              b2Mat22;
    m_angle:          float;
    m_axialMass:      float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2RevoluteJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2RevoluteJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2RevoluteJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2RevoluteJoint@@UEBA?AUb2Vec2@@XZ";

    /// Get the reaction force given the inverse time step.
    /// Unit is N.
    virtual_GetReactionForce :: (this: *b2RevoluteJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2RevoluteJoint@@UEBA?AUb2Vec2@@M@Z";

    /// Get the reaction torque due to the joint limit given the inverse time step.
    /// Unit is N*m.
    virtual_GetReactionTorque :: (this: *b2RevoluteJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2RevoluteJoint@@UEBAMM@Z";

    /// Dump to b2Log.
    virtual_Dump :: (this: *b2RevoluteJoint) -> void #cpp_method #foreign box2d "?Dump@b2RevoluteJoint@@UEAAXXZ";

    ///
    virtual_Draw :: (this: *b2RevoluteJoint, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2RevoluteJoint@@UEBAXPEAVb2Draw@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2RevoluteJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2RevoluteJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2RevoluteJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2RevoluteJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2RevoluteJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2RevoluteJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

b2RopeStretch :: struct {}
b2RopeBend :: struct {}

b2StretchingModel :: enum s32 {
    pbdStretchingModel  :: 0;
    xpbdStretchingModel :: 1;

    b2_pbdStretchingModel  :: pbdStretchingModel;
    b2_xpbdStretchingModel :: xpbdStretchingModel;
}

b2BendingModel :: enum s32 {
    springAngleBendingModel :: 0;
    pbdAngleBendingModel    :: 1;
    xpbdAngleBendingModel   :: 2;
    pbdDistanceBendingModel :: 3;
    pbdHeightBendingModel   :: 4;
    pbdTriangleBendingModel :: 5;

    b2_springAngleBendingModel :: springAngleBendingModel;
    b2_pbdAngleBendingModel    :: pbdAngleBendingModel;
    b2_xpbdAngleBendingModel   :: xpbdAngleBendingModel;
    b2_pbdDistanceBendingModel :: pbdDistanceBendingModel;
    b2_pbdHeightBendingModel   :: pbdHeightBendingModel;
    b2_pbdTriangleBendingModel :: pbdTriangleBendingModel;
}

///
b2RopeTuning :: struct {
    Constructor :: (this: *b2RopeTuning) -> void #cpp_method #foreign box2d "??0b2RopeTuning@@QEAA@XZ";

    stretchingModel:    b2StretchingModel;
    bendingModel:       b2BendingModel;
    damping:            float;
    stretchStiffness:   float;
    stretchHertz:       float;
    stretchDamping:     float;
    bendStiffness:      float;
    bendHertz:          float;
    bendDamping:        float;
    isometric:          bool;
    fixedEffectiveMass: bool;
    warmStart:          bool;
}

///
b2RopeDef :: struct {
    Constructor :: (this: *b2RopeDef) -> void #cpp_method #foreign box2d "??0b2RopeDef@@QEAA@XZ";

    position: b2Vec2;
    vertices: *b2Vec2;
    count:    int32;
    masses:   *float;
    gravity:  b2Vec2;
    tuning:   b2RopeTuning;
}

///
b2Rope :: struct {
    Constructor :: (this: *b2Rope) -> void #cpp_method #foreign box2d "??0b2Rope@@QEAA@XZ";
    Destructor :: (this: *b2Rope) -> void #cpp_method #foreign box2d "??1b2Rope@@QEAA@XZ";

    ///
    Create :: (this: *b2Rope, def: *b2RopeDef) -> void #cpp_method #foreign box2d "?Create@b2Rope@@QEAAXAEBUb2RopeDef@@@Z";
    Create :: (this: *b2Rope, def: b2RopeDef) #no_context {
        Create(this, *def);
    }

    ///
    SetTuning :: (this: *b2Rope, tuning: *b2RopeTuning) -> void #cpp_method #foreign box2d "?SetTuning@b2Rope@@QEAAXAEBUb2RopeTuning@@@Z";
    SetTuning :: (this: *b2Rope, tuning: b2RopeTuning) #no_context {
        SetTuning(this, *tuning);
    }

    ///
    Step :: (this: *b2Rope, timeStep: float, iterations: int32, position: *b2Vec2) -> void #cpp_method #foreign box2d "?Step@b2Rope@@QEAAXMHAEBUb2Vec2@@@Z";
    Step :: (this: *b2Rope, timeStep: float, iterations: int32, position: b2Vec2) #no_context {
        Step(this, timeStep, iterations, *position);
    }

    ///
    Reset :: (this: *b2Rope, position: *b2Vec2) -> void #cpp_method #foreign box2d "?Reset@b2Rope@@QEAAXAEBUb2Vec2@@@Z";
    Reset :: (this: *b2Rope, position: b2Vec2) #no_context {
        Reset(this, *position);
    }

    ///
    Draw :: (this: *b2Rope, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2Rope@@QEBAXPEAVb2Draw@@@Z";

    SolveStretch_PBD :: (this: *b2Rope) -> void #cpp_method #foreign box2d "?SolveStretch_PBD@b2Rope@@AEAAXXZ";
    SolveStretch_XPBD :: (this: *b2Rope, dt: float) -> void #cpp_method #foreign box2d "?SolveStretch_XPBD@b2Rope@@AEAAXM@Z";
    SolveBend_PBD_Angle :: (this: *b2Rope) -> void #cpp_method #foreign box2d "?SolveBend_PBD_Angle@b2Rope@@AEAAXXZ";
    SolveBend_XPBD_Angle :: (this: *b2Rope, dt: float) -> void #cpp_method #foreign box2d "?SolveBend_XPBD_Angle@b2Rope@@AEAAXM@Z";
    SolveBend_PBD_Distance :: (this: *b2Rope) -> void #cpp_method #foreign box2d "?SolveBend_PBD_Distance@b2Rope@@AEAAXXZ";
    SolveBend_PBD_Height :: (this: *b2Rope) -> void #cpp_method #foreign box2d "?SolveBend_PBD_Height@b2Rope@@AEAAXXZ";
    SolveBend_PBD_Triangle :: (this: *b2Rope) -> void #cpp_method #foreign box2d "?SolveBend_PBD_Triangle@b2Rope@@AEAAXXZ";
    ApplyBendForces :: (this: *b2Rope, dt: float) -> void #cpp_method #foreign box2d "?ApplyBendForces@b2Rope@@AEAAXM@Z";

    m_position:           b2Vec2;

    m_count:              int32;
    m_stretchCount:       int32;
    m_bendCount:          int32;

    m_stretchConstraints: *b2RopeStretch;
    m_bendConstraints:    *b2RopeBend;

    m_bindPositions:      *b2Vec2;
    m_ps:                 *b2Vec2;
    m_p0s:                *b2Vec2;
    m_vs:                 *b2Vec2;

    m_invMasses:          *float;
    m_gravity:            b2Vec2;

    m_tuning:             b2RopeTuning;
}

b2StackEntry :: struct {
    data:       *u8;
    size:       int32;
    usedMalloc: bool;
}

// This is a stack allocator used for fast per step allocations.
// You must nest allocate/free pairs. The code will assert
// if you try to interleave multiple allocate/free pairs.
b2StackAllocator :: struct {
    Constructor :: (this: *b2StackAllocator) -> void #cpp_method #foreign box2d "??0b2StackAllocator@@QEAA@XZ";
    Destructor :: (this: *b2StackAllocator) -> void #cpp_method #foreign box2d "??1b2StackAllocator@@QEAA@XZ";

    Allocate :: (this: *b2StackAllocator, size: int32) -> *void #cpp_method #foreign box2d "?Allocate@b2StackAllocator@@QEAAPEAXH@Z";
    Free :: (this: *b2StackAllocator, p: *void) -> void #cpp_method #foreign box2d "?Free@b2StackAllocator@@QEAAXPEAX@Z";

    GetMaxAllocation :: (this: *b2StackAllocator) -> int32 #cpp_method #foreign box2d "?GetMaxAllocation@b2StackAllocator@@QEBAHXZ";

    m_data:          [102400] u8;
    m_index:         int32;

    m_allocation:    int32;
    m_maxAllocation: int32;

    m_entries:       [32] b2StackEntry;
    m_entryCount:    int32;
}

/// Timer for profiling. This has platform specific code and may
/// not work on every platform.
b2Timer :: struct {
    /// Constructor
    Constructor :: (this: *b2Timer) -> void #cpp_method #foreign box2d "??0b2Timer@@QEAA@XZ";

    /// Reset the timer.
    Reset :: (this: *b2Timer) -> void #cpp_method #foreign box2d "?Reset@b2Timer@@QEAAXXZ";

    /// Get the time since construction or the last reset.
    GetMilliseconds :: (this: *b2Timer) -> float #cpp_method #foreign box2d "?GetMilliseconds@b2Timer@@QEBAMXZ";

    m_start: float64;
}

/// Input parameters for b2TimeOfImpact
b2TOIInput :: struct {
    proxyA: b2DistanceProxy;
    proxyB: b2DistanceProxy;
    sweepA: b2Sweep;
    sweepB: b2Sweep;
    tMax:   float; // defines sweep interval [0, tMax]
}

/// Output parameters for b2TimeOfImpact.
b2TOIOutput :: struct {
    State :: enum s32 {
        unknown    :: 0;
        failed     :: 1;
        overlapped :: 2;
        touching   :: 3;
        separated  :: 4;

        e_unknown    :: unknown;
        e_failed     :: failed;
        e_overlapped :: overlapped;
        e_touching   :: touching;
        e_separated  :: separated;
    }

    state: State;
    t:     float;
}

/// Compute the upper bound on time before two shapes penetrate. Time is represented as
/// a fraction between [0,tMax]. This uses a swept separating axis and may miss some intermediate,
/// non-tunneling collisions. If you change the time interval, you should call this function
/// again.
/// Note: use b2Distance to compute the contact point and normal at the time of impact.
b2TimeOfImpact :: (output: *b2TOIOutput, input: *b2TOIInput) -> void #foreign box2d "?b2TimeOfImpact@@YAXPEAUb2TOIOutput@@PEBUb2TOIInput@@@Z";

/// Profiling data. Times are in milliseconds.
b2Profile :: struct {
    step:          float;
    collide:       float;
    solve:         float;
    solveInit:     float;
    solveVelocity: float;
    solvePosition: float;
    broadphase:    float;
    solveTOI:      float;
}

/// This is an internal structure.
b2TimeStep :: struct {
    dt:                 float; // time step
    inv_dt:             float; // inverse time step (0 if dt == 0).
    dtRatio:            float; // dt * inv_dt0
    velocityIterations: int32;
    positionIterations: int32;
    warmStarting:       bool;
}

/// This is an internal structure.
b2Position :: struct {
    c: b2Vec2;
    a: float;
}

/// This is an internal structure.
b2Velocity :: struct {
    v: b2Vec2;
    w: float;
}

/// Solver Data
b2SolverData :: struct {
    step:       b2TimeStep;
    positions:  *b2Position;
    velocities: *b2Velocity;
}

/// Weld joint definition. You need to specify local anchor points
/// where they are attached and the relative body angle. The position
/// of the anchor points is important for computing the reaction torque.
b2WeldJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2WeldJointDef) -> void #cpp_method #foreign box2d "??0b2WeldJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, reference angle, stiffness, and damping.
    /// @param bodyA the first body connected by this joint
    /// @param bodyB the second body connected by this joint
    /// @param anchor the point of connection in world coordinates
    Initialize :: (this: *b2WeldJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2WeldJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@@Z";
    Initialize :: (this: *b2WeldJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchor);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA:   b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB:   b2Vec2;

    /// The bodyB angle minus bodyA angle in the reference state (radians).
    referenceAngle: float;

    /// The rotational stiffness in N*m
    /// Disable softness with a value of 0
    stiffness:      float;

    /// The rotational damping in N*m*s
    damping:        float;
}

/// A weld joint essentially glues two bodies together. A weld joint may
/// distort somewhat because the island constraint solver is approximate.
b2WeldJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2WeldJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2WeldJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2WeldJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2WeldJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Get the reference angle.
    GetReferenceAngle :: (this: *b2WeldJoint) -> float #cpp_method #foreign box2d "?GetReferenceAngle@b2WeldJoint@@QEBAMXZ";

    /// Set/get stiffness in N*m
    SetStiffness :: (this: *b2WeldJoint, hz: float) -> void #cpp_method #foreign box2d "?SetStiffness@b2WeldJoint@@QEAAXM@Z";
    GetStiffness :: (this: *b2WeldJoint) -> float #cpp_method #foreign box2d "?GetStiffness@b2WeldJoint@@QEBAMXZ";

    /// Set/get damping in N*m*s
    SetDamping :: (this: *b2WeldJoint, damping: float) -> void #cpp_method #foreign box2d "?SetDamping@b2WeldJoint@@QEAAXM@Z";
    GetDamping :: (this: *b2WeldJoint) -> float #cpp_method #foreign box2d "?GetDamping@b2WeldJoint@@QEBAMXZ";

    Constructor :: (this: *b2WeldJoint, def: *b2WeldJointDef) -> void #cpp_method #foreign box2d "??0b2WeldJoint@@IEAA@PEBUb2WeldJointDef@@@Z";

    m_stiffness:      float;
    m_damping:        float;
    m_bias:           float;

    // Solver shared
    m_localAnchorA:   b2Vec2;
    m_localAnchorB:   b2Vec2;
    m_referenceAngle: float;
    m_gamma:          float;
    m_impulse:        b2Vec3;

    // Solver temp
    m_indexA:         int32;
    m_indexB:         int32;
    m_rA:             b2Vec2;
    m_rB:             b2Vec2;
    m_localCenterA:   b2Vec2;
    m_localCenterB:   b2Vec2;
    m_invMassA:       float;
    m_invMassB:       float;
    m_invIA:          float;
    m_invIB:          float;
    m_mass:           b2Mat33;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2WeldJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2WeldJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2WeldJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2WeldJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2WeldJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2WeldJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2WeldJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2WeldJoint@@UEBAMM@Z";

    /// Dump to b2Log
    virtual_Dump :: (this: *b2WeldJoint) -> void #cpp_method #foreign box2d "?Dump@b2WeldJoint@@UEAAXXZ";

    virtual_InitVelocityConstraints :: (this: *b2WeldJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2WeldJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2WeldJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2WeldJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2WeldJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2WeldJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

/// Wheel joint definition. This requires defining a line of
/// motion using an axis and an anchor point. The definition uses local
/// anchor points and a local axis so that the initial configuration
/// can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space. Using local
/// anchors and a local axis helps when saving and loading a game.
b2WheelJointDef :: struct {
    #as using b2jointdef: b2JointDef;

    Constructor :: (this: *b2WheelJointDef) -> void #cpp_method #foreign box2d "??0b2WheelJointDef@@QEAA@XZ";

    /// Initialize the bodies, anchors, axis, and reference angle using the world
    /// anchor and world axis.
    Initialize :: (this: *b2WheelJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: *b2Vec2, axis: *b2Vec2) -> void #cpp_method #foreign box2d "?Initialize@b2WheelJointDef@@QEAAXPEAVb2Body@@0AEBUb2Vec2@@1@Z";
    Initialize :: (this: *b2WheelJointDef, bodyA: *b2Body, bodyB: *b2Body, anchor: b2Vec2, axis: b2Vec2) #no_context {
        Initialize(this, bodyA, bodyB, *anchor, *axis);
    }

    /// The local anchor point relative to bodyA's origin.
    localAnchorA:     b2Vec2;

    /// The local anchor point relative to bodyB's origin.
    localAnchorB:     b2Vec2;

    /// The local translation axis in bodyA.
    localAxisA:       b2Vec2;

    /// Enable/disable the joint limit.
    enableLimit:      bool;

    /// The lower translation limit, usually in meters.
    lowerTranslation: float;

    /// The upper translation limit, usually in meters.
    upperTranslation: float;

    /// Enable/disable the joint motor.
    enableMotor:      bool;

    /// The maximum motor torque, usually in N-m.
    maxMotorTorque:   float;

    /// The desired motor speed in radians per second.
    motorSpeed:       float;

    /// Suspension stiffness. Typically in units N/m.
    stiffness:        float;

    /// Suspension damping. Typically in units of N*s/m.
    damping:          float;
}

/// A wheel joint. This joint provides two degrees of freedom: translation
/// along an axis fixed in bodyA and rotation in the plane. In other words, it is a point to
/// line constraint with a rotational motor and a linear spring/damper. The spring/damper is
/// initialized upon creation. This joint is designed for vehicle suspensions.
b2WheelJoint :: struct {
    #as using b2joint: b2Joint;

    /// The local anchor point relative to bodyA's origin.
    GetLocalAnchorA :: (this: *b2WheelJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorA@b2WheelJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local anchor point relative to bodyB's origin.
    GetLocalAnchorB :: (this: *b2WheelJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAnchorB@b2WheelJoint@@QEBAAEBUb2Vec2@@XZ";

    /// The local joint axis relative to bodyA.
    GetLocalAxisA :: (this: *b2WheelJoint) -> *b2Vec2 #cpp_method #foreign box2d "?GetLocalAxisA@b2WheelJoint@@QEBAAEBUb2Vec2@@XZ";

    /// Get the current joint translation, usually in meters.
    GetJointTranslation :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetJointTranslation@b2WheelJoint@@QEBAMXZ";

    /// Get the current joint linear speed, usually in meters per second.
    GetJointLinearSpeed :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetJointLinearSpeed@b2WheelJoint@@QEBAMXZ";

    /// Get the current joint angle in radians.
    GetJointAngle :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetJointAngle@b2WheelJoint@@QEBAMXZ";

    /// Get the current joint angular speed in radians per second.
    GetJointAngularSpeed :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetJointAngularSpeed@b2WheelJoint@@QEBAMXZ";

    /// Is the joint limit enabled?
    IsLimitEnabled :: (this: *b2WheelJoint) -> bool #cpp_method #foreign box2d "?IsLimitEnabled@b2WheelJoint@@QEBA_NXZ";

    /// Enable/disable the joint translation limit.
    EnableLimit :: (this: *b2WheelJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableLimit@b2WheelJoint@@QEAAX_N@Z";

    /// Get the lower joint translation limit, usually in meters.
    GetLowerLimit :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetLowerLimit@b2WheelJoint@@QEBAMXZ";

    /// Get the upper joint translation limit, usually in meters.
    GetUpperLimit :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetUpperLimit@b2WheelJoint@@QEBAMXZ";

    /// Set the joint translation limits, usually in meters.
    SetLimits :: (this: *b2WheelJoint, lower: float, upper: float) -> void #cpp_method #foreign box2d "?SetLimits@b2WheelJoint@@QEAAXMM@Z";

    /// Is the joint motor enabled?
    IsMotorEnabled :: (this: *b2WheelJoint) -> bool #cpp_method #foreign box2d "?IsMotorEnabled@b2WheelJoint@@QEBA_NXZ";

    /// Enable/disable the joint motor.
    EnableMotor :: (this: *b2WheelJoint, flag: bool) -> void #cpp_method #foreign box2d "?EnableMotor@b2WheelJoint@@QEAAX_N@Z";

    /// Set the motor speed, usually in radians per second.
    SetMotorSpeed :: (this: *b2WheelJoint, speed: float) -> void #cpp_method #foreign box2d "?SetMotorSpeed@b2WheelJoint@@QEAAXM@Z";

    /// Get the motor speed, usually in radians per second.
    GetMotorSpeed :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetMotorSpeed@b2WheelJoint@@QEBAMXZ";

    /// Set/Get the maximum motor force, usually in N-m.
    SetMaxMotorTorque :: (this: *b2WheelJoint, torque: float) -> void #cpp_method #foreign box2d "?SetMaxMotorTorque@b2WheelJoint@@QEAAXM@Z";

    GetMaxMotorTorque :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetMaxMotorTorque@b2WheelJoint@@QEBAMXZ";

    /// Get the current motor torque given the inverse time step, usually in N-m.
    GetMotorTorque :: (this: *b2WheelJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetMotorTorque@b2WheelJoint@@QEBAMM@Z";

    /// Access spring stiffness
    SetStiffness :: (this: *b2WheelJoint, stiffness: float) -> void #cpp_method #foreign box2d "?SetStiffness@b2WheelJoint@@QEAAXM@Z";
    GetStiffness :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetStiffness@b2WheelJoint@@QEBAMXZ";

    /// Access damping
    SetDamping :: (this: *b2WheelJoint, damping: float) -> void #cpp_method #foreign box2d "?SetDamping@b2WheelJoint@@QEAAXM@Z";
    GetDamping :: (this: *b2WheelJoint) -> float #cpp_method #foreign box2d "?GetDamping@b2WheelJoint@@QEBAMXZ";

    Constructor :: (this: *b2WheelJoint, def: *b2WheelJointDef) -> void #cpp_method #foreign box2d "??0b2WheelJoint@@IEAA@PEBUb2WheelJointDef@@@Z";

    m_localAnchorA:     b2Vec2;
    m_localAnchorB:     b2Vec2;
    m_localXAxisA:      b2Vec2;
    m_localYAxisA:      b2Vec2;

    m_impulse:          float;
    m_motorImpulse:     float;
    m_springImpulse:    float;

    m_lowerImpulse:     float;
    m_upperImpulse:     float;
    m_translation:      float;
    m_lowerTranslation: float;
    m_upperTranslation: float;

    m_maxMotorTorque:   float;
    m_motorSpeed:       float;

    m_enableLimit:      bool;
    m_enableMotor:      bool;

    m_stiffness:        float;
    m_damping:          float;

    // Solver temp
    m_indexA:           int32;
    m_indexB:           int32;
    m_localCenterA:     b2Vec2;
    m_localCenterB:     b2Vec2;
    m_invMassA:         float;
    m_invMassB:         float;
    m_invIA:            float;
    m_invIB:            float;

    m_ax:               b2Vec2;
    m_ay:               b2Vec2;
    m_sAx:              float;
    m_sBx:              float;
    m_sAy:              float;
    m_sBy:              float;

    m_mass:             float;
    m_motorMass:        float;
    m_axialMass:        float;
    m_springMass:       float;

    m_bias:             float;
    m_gamma:            float;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.

    virtual_GetAnchorA :: (this: *b2WheelJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorA@b2WheelJoint@@UEBA?AUb2Vec2@@XZ";
    virtual_GetAnchorB :: (this: *b2WheelJoint) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetAnchorB@b2WheelJoint@@UEBA?AUb2Vec2@@XZ";

    virtual_GetReactionForce :: (this: *b2WheelJoint, inv_dt: float) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetReactionForce@b2WheelJoint@@UEBA?AUb2Vec2@@M@Z";
    virtual_GetReactionTorque :: (this: *b2WheelJoint, inv_dt: float) -> float #cpp_method #foreign box2d "?GetReactionTorque@b2WheelJoint@@UEBAMM@Z";

    /// Dump to b2Log
    virtual_Dump :: (this: *b2WheelJoint) -> void #cpp_method #foreign box2d "?Dump@b2WheelJoint@@UEAAXXZ";

    ///
    virtual_Draw :: (this: *b2WheelJoint, draw: *b2Draw) -> void #cpp_method #foreign box2d "?Draw@b2WheelJoint@@UEBAXPEAVb2Draw@@@Z";

    virtual_InitVelocityConstraints :: (this: *b2WheelJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?InitVelocityConstraints@b2WheelJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolveVelocityConstraints :: (this: *b2WheelJoint, data: *b2SolverData) -> void #cpp_method #foreign box2d "?SolveVelocityConstraints@b2WheelJoint@@MEAAXAEBUb2SolverData@@@Z";
    virtual_SolvePositionConstraints :: (this: *b2WheelJoint, data: *b2SolverData) -> bool #cpp_method #foreign box2d "?SolvePositionConstraints@b2WheelJoint@@MEAA_NAEBUb2SolverData@@@Z";
}

b2ContactResult :: struct {}

/// Joints and fixtures are destroyed when their associated
/// body is destroyed. Implement this listener so that you
/// may nullify references to these joints and shapes.
b2DestructionListener :: struct {
    vtable: *b2DestructionListener_VTable;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_Destructor :: (this: *b2DestructionListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2DestructionListener@@UEAA@XZ";
}
b2DestructionListener_VTable :: struct #type_info_none {
    Destructor: (this: *b2DestructionListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    SayGoodbye: (this: *b2DestructionListener, fixture: *b2Fixture) -> void #cpp_method;

    SayGoodbye_1: (this: *b2DestructionListener, joint: *b2Joint) -> void #cpp_method;
}

b2DestructionListener_Destructor :: inline (this: *b2DestructionListener, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2DestructionListener_SayGoodbye :: inline (this: *b2DestructionListener, fixture: *b2Fixture) { this.vtable.SayGoodbye(this, fixture); }

b2DestructionListener_SayGoodbye_1 :: inline (this: *b2DestructionListener, joint: *b2Joint) { this.vtable.SayGoodbye_1(this, joint); }

vtable :: (obj: *b2DestructionListener) -> *b2DestructionListener_VTable { return obj.vtable; }


/// Implement this class to provide collision filtering. In other words, you can implement
/// this class if you want finer control over contact creation.
b2ContactFilter :: struct {
    vtable: *b2ContactFilter_VTable;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_Destructor :: (this: *b2ContactFilter, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2ContactFilter@@UEAA@XZ";

    /// Return true if contact calculations should be performed between these two shapes.
    /// @warning for performance reasons this is only called when the AABBs begin to overlap.
    virtual_ShouldCollide :: (this: *b2ContactFilter, fixtureA: *b2Fixture, fixtureB: *b2Fixture) -> bool #cpp_method #foreign box2d "?ShouldCollide@b2ContactFilter@@UEAA_NPEAVb2Fixture@@0@Z";
}
b2ContactFilter_VTable :: struct #type_info_none {
    Destructor: (this: *b2ContactFilter, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    ShouldCollide: (this: *b2ContactFilter, fixtureA: *b2Fixture, fixtureB: *b2Fixture) -> bool #cpp_method;
}

b2ContactFilter_Destructor :: inline (this: *b2ContactFilter, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2ContactFilter_ShouldCollide :: inline (this: *b2ContactFilter, fixtureA: *b2Fixture, fixtureB: *b2Fixture) -> bool { return this.vtable.ShouldCollide(this, fixtureA, fixtureB); }

vtable :: (obj: *b2ContactFilter) -> *b2ContactFilter_VTable { return obj.vtable; }


/// Contact impulses for reporting. Impulses are used instead of forces because
/// sub-step forces may approach infinity for rigid body collisions. These
/// match up one-to-one with the contact points in b2Manifold.
b2ContactImpulse :: struct {
    normalImpulses:  [2] float;
    tangentImpulses: [2] float;
    count:           int32;
}

/// Implement this class to get contact information. You can use these results for
/// things like sounds and game logic. You can also get contact results by
/// traversing the contact lists after the time step. However, you might miss
/// some contacts because continuous physics leads to sub-stepping.
/// Additionally you may receive multiple callbacks for the same contact in a
/// single time step.
/// You should strive to make your callbacks efficient because there may be
/// many callbacks per time step.
/// @warning You cannot create/destroy Box2D entities inside these callbacks.
b2ContactListener :: struct {
    vtable: *b2ContactListener_VTable;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_Destructor :: (this: *b2ContactListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2ContactListener@@UEAA@XZ";

    /// Called when two fixtures begin to touch.
    virtual_BeginContact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method #foreign box2d "?BeginContact@b2ContactListener@@UEAAXPEAVb2Contact@@@Z";

    /// Called when two fixtures cease to touch.
    virtual_EndContact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method #foreign box2d "?EndContact@b2ContactListener@@UEAAXPEAVb2Contact@@@Z";

    /// This is called after a contact is updated. This allows you to inspect a
    /// contact before it goes to the solver. If you are careful, you can modify the
    /// contact manifold (e.g. disable contact).
    /// A copy of the old manifold is provided so that you can detect changes.
    /// Note: this is called only for awake bodies.
    /// Note: this is called even when the number of contact points is zero.
    /// Note: this is not called for sensors.
    /// Note: if you set the number of contact points to zero, you will not
    /// get an EndContact callback. However, you may get a BeginContact callback
    /// the next step.
    virtual_PreSolve :: (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) -> void #cpp_method #foreign box2d "?PreSolve@b2ContactListener@@UEAAXPEAVb2Contact@@PEBUb2Manifold@@@Z";

    /// This lets you inspect a contact after the solver is finished. This is useful
    /// for inspecting impulses.
    /// Note: the contact manifold does not include time of impact impulses, which can be
    /// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
    /// in a separate data structure.
    /// Note: this is only called for contacts that are touching, solid, and awake.
    virtual_PostSolve :: (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) -> void #cpp_method #foreign box2d "?PostSolve@b2ContactListener@@UEAAXPEAVb2Contact@@PEBUb2ContactImpulse@@@Z";
}
b2ContactListener_VTable :: struct #type_info_none {
    Destructor: (this: *b2ContactListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    BeginContact: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method;

    EndContact: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method;

    PreSolve: (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) -> void #cpp_method;

    PostSolve: (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) -> void #cpp_method;
}

b2ContactListener_Destructor :: inline (this: *b2ContactListener, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2ContactListener_BeginContact :: inline (this: *b2ContactListener, contact: *b2Contact) { this.vtable.BeginContact(this, contact); }

b2ContactListener_EndContact :: inline (this: *b2ContactListener, contact: *b2Contact) { this.vtable.EndContact(this, contact); }

b2ContactListener_PreSolve :: inline (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) { this.vtable.PreSolve(this, contact, oldManifold); }

b2ContactListener_PostSolve :: inline (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) { this.vtable.PostSolve(this, contact, impulse); }

vtable :: (obj: *b2ContactListener) -> *b2ContactListener_VTable { return obj.vtable; }


/// Callback class for AABB queries.
/// See b2World::Query
b2QueryCallback :: struct {
    vtable: *b2QueryCallback_VTable;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_Destructor :: (this: *b2QueryCallback, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2QueryCallback@@UEAA@XZ";
}
b2QueryCallback_VTable :: struct #type_info_none {
    Destructor: (this: *b2QueryCallback, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    ReportFixture: (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method;
}

b2QueryCallback_Destructor :: inline (this: *b2QueryCallback, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2QueryCallback_ReportFixture :: inline (this: *b2QueryCallback, fixture: *b2Fixture) -> bool { return this.vtable.ReportFixture(this, fixture); }

vtable :: (obj: *b2QueryCallback) -> *b2QueryCallback_VTable { return obj.vtable; }


/// Callback class for ray casts.
/// See b2World::RayCast
b2RayCastCallback :: struct {
    vtable: *b2RayCastCallback_VTable;

    // Virtual functions:
    // Normally you should call them via the vtable.
    // But these bindings can be useful if you need to call the parent implementation in a sub-struct’s overwritten method
    // or need to create a vtable yourself.
    virtual_Destructor :: (this: *b2RayCastCallback, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method #foreign box2d "??1b2RayCastCallback@@UEAA@XZ";
}
b2RayCastCallback_VTable :: struct #type_info_none {
    Destructor: (this: *b2RayCastCallback, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method;

    ReportFixture: (this: *b2RayCastCallback, fixture: *b2Fixture, point: *b2Vec2, normal: *b2Vec2, fraction: float) -> float #cpp_method;
}

b2RayCastCallback_Destructor :: inline (this: *b2RayCastCallback, flags: Msvc_Destructor_Flags = .NONE) { this.vtable.Destructor(this, flags); }

b2RayCastCallback_ReportFixture :: inline (this: *b2RayCastCallback, fixture: *b2Fixture, point: *b2Vec2, normal: *b2Vec2, fraction: float) -> float { return this.vtable.ReportFixture(this, fixture, point, normal, fraction); }

vtable :: (obj: *b2RayCastCallback) -> *b2RayCastCallback_VTable { return obj.vtable; }


/// The world class manages all physics entities, dynamic simulation,
/// and asynchronous queries. The world also contains efficient memory
/// management facilities.
b2World :: struct {
    /// Construct a world object.
    /// @param gravity the world gravity vector.
    Constructor :: (this: *b2World, gravity: *b2Vec2) -> void #cpp_method #foreign box2d "??0b2World@@QEAA@AEBUb2Vec2@@@Z";
    Constructor :: (this: *b2World, gravity: b2Vec2) #no_context {
        Constructor(this, *gravity);
    }

    /// Destruct the world. All physics entities are destroyed and all heap memory is released.
    Destructor :: (this: *b2World) -> void #cpp_method #foreign box2d "??1b2World@@QEAA@XZ";

    /// Register a destruction listener. The listener is owned by you and must
    /// remain in scope.
    SetDestructionListener :: (this: *b2World, listener: *b2DestructionListener) -> void #cpp_method #foreign box2d "?SetDestructionListener@b2World@@QEAAXPEAVb2DestructionListener@@@Z";

    /// Register a contact filter to provide specific control over collision.
    /// Otherwise the default filter is used (b2_defaultFilter). The listener is
    /// owned by you and must remain in scope.
    SetContactFilter :: (this: *b2World, filter: *b2ContactFilter) -> void #cpp_method #foreign box2d "?SetContactFilter@b2World@@QEAAXPEAVb2ContactFilter@@@Z";

    /// Register a contact event listener. The listener is owned by you and must
    /// remain in scope.
    SetContactListener :: (this: *b2World, listener: *b2ContactListener) -> void #cpp_method #foreign box2d "?SetContactListener@b2World@@QEAAXPEAVb2ContactListener@@@Z";

    /// Register a routine for debug drawing. The debug draw functions are called
    /// inside with b2World::DebugDraw method. The debug draw object is owned
    /// by you and must remain in scope.
    SetDebugDraw :: (this: *b2World, debugDraw: *b2Draw) -> void #cpp_method #foreign box2d "?SetDebugDraw@b2World@@QEAAXPEAVb2Draw@@@Z";

    /// Create a rigid body given a definition. No reference to the definition
    /// is retained.
    /// @warning This function is locked during callbacks.
    CreateBody :: (this: *b2World, def: *b2BodyDef) -> *b2Body #cpp_method #foreign box2d "?CreateBody@b2World@@QEAAPEAVb2Body@@PEBUb2BodyDef@@@Z";

    /// Destroy a rigid body given a definition. No reference to the definition
    /// is retained. This function is locked during callbacks.
    /// @warning This automatically deletes all associated shapes and joints.
    /// @warning This function is locked during callbacks.
    DestroyBody :: (this: *b2World, body: *b2Body) -> void #cpp_method #foreign box2d "?DestroyBody@b2World@@QEAAXPEAVb2Body@@@Z";

    /// Create a joint to constrain bodies together. No reference to the definition
    /// is retained. This may cause the connected bodies to cease colliding.
    /// @warning This function is locked during callbacks.
    CreateJoint :: (this: *b2World, def: *b2JointDef) -> *b2Joint #cpp_method #foreign box2d "?CreateJoint@b2World@@QEAAPEAVb2Joint@@PEBUb2JointDef@@@Z";

    /// Destroy a joint. This may cause the connected bodies to begin colliding.
    /// @warning This function is locked during callbacks.
    DestroyJoint :: (this: *b2World, joint: *b2Joint) -> void #cpp_method #foreign box2d "?DestroyJoint@b2World@@QEAAXPEAVb2Joint@@@Z";

    /// Take a time step. This performs collision detection, integration,
    /// and constraint solution.
    /// @param timeStep the amount of time to simulate, this should not vary.
    /// @param velocityIterations for the velocity constraint solver.
    /// @param positionIterations for the position constraint solver.
    Step :: (this: *b2World, timeStep: float, velocityIterations: int32, positionIterations: int32) -> void #cpp_method #foreign box2d "?Step@b2World@@QEAAXMHH@Z";

    /// Manually clear the force buffer on all bodies. By default, forces are cleared automatically
    /// after each call to Step. The default behavior is modified by calling SetAutoClearForces.
    /// The purpose of this function is to support sub-stepping. Sub-stepping is often used to maintain
    /// a fixed sized time step under a variable frame-rate.
    /// When you perform sub-stepping you will disable auto clearing of forces and instead call
    /// ClearForces after all sub-steps are complete in one pass of your game loop.
    /// @see SetAutoClearForces
    ClearForces :: (this: *b2World) -> void #cpp_method #foreign box2d "?ClearForces@b2World@@QEAAXXZ";

    /// Call this to draw shapes and other debug draw data. This is intentionally non-const.
    DebugDraw :: (this: *b2World) -> void #cpp_method #foreign box2d "?DebugDraw@b2World@@QEAAXXZ";

    /// Query the world for all fixtures that potentially overlap the
    /// provided AABB.
    /// @param callback a user implemented callback class.
    /// @param aabb the query box.
    QueryAABB :: (this: *b2World, callback: *b2QueryCallback, aabb: *b2AABB) -> void #cpp_method #foreign box2d "?QueryAABB@b2World@@QEBAXPEAVb2QueryCallback@@AEBUb2AABB@@@Z";
    QueryAABB :: (this: *b2World, callback: *b2QueryCallback, aabb: b2AABB) #no_context {
        QueryAABB(this, callback, *aabb);
    }

    /// Ray-cast the world for all fixtures in the path of the ray. Your callback
    /// controls whether you get the closest point, any point, or n-points.
    /// The ray-cast ignores shapes that contain the starting point.
    /// @param callback a user implemented callback class.
    /// @param point1 the ray starting point
    /// @param point2 the ray ending point
    RayCast :: (this: *b2World, callback: *b2RayCastCallback, point1: *b2Vec2, point2: *b2Vec2) -> void #cpp_method #foreign box2d "?RayCast@b2World@@QEBAXPEAVb2RayCastCallback@@AEBUb2Vec2@@1@Z";
    RayCast :: (this: *b2World, callback: *b2RayCastCallback, point1: b2Vec2, point2: b2Vec2) #no_context {
        RayCast(this, callback, *point1, *point2);
    }

    /// Get the world body list. With the returned body, use b2Body::GetNext to get
    /// the next body in the world list. A nullptr body indicates the end of the list.
    /// @return the head of the world body list.
    GetBodyList :: (this: *b2World) -> *b2Body #cpp_method #foreign box2d "?GetBodyList@b2World@@QEAAPEAVb2Body@@XZ";

    GetBodyList_1 :: (this: /*const*/ *b2World) -> *b2Body #cpp_method #foreign box2d "?GetBodyList@b2World@@QEBAPEBVb2Body@@XZ";

    /// Get the world joint list. With the returned joint, use b2Joint::GetNext to get
    /// the next joint in the world list. A nullptr joint indicates the end of the list.
    /// @return the head of the world joint list.
    GetJointList :: (this: *b2World) -> *b2Joint #cpp_method #foreign box2d "?GetJointList@b2World@@QEAAPEAVb2Joint@@XZ";

    GetJointList_1 :: (this: /*const*/ *b2World) -> *b2Joint #cpp_method #foreign box2d "?GetJointList@b2World@@QEBAPEBVb2Joint@@XZ";

    /// Get the world contact list. With the returned contact, use b2Contact::GetNext to get
    /// the next contact in the world list. A nullptr contact indicates the end of the list.
    /// @return the head of the world contact list.
    /// @warning contacts are created and destroyed in the middle of a time step.
    /// Use b2ContactListener to avoid missing contacts.
    GetContactList :: (this: *b2World) -> *b2Contact #cpp_method #foreign box2d "?GetContactList@b2World@@QEAAPEAVb2Contact@@XZ";

    GetContactList_1 :: (this: /*const*/ *b2World) -> *b2Contact #cpp_method #foreign box2d "?GetContactList@b2World@@QEBAPEBVb2Contact@@XZ";

    /// Enable/disable sleep.
    SetAllowSleeping :: (this: *b2World, flag: bool) -> void #cpp_method #foreign box2d "?SetAllowSleeping@b2World@@QEAAX_N@Z";
    GetAllowSleeping :: (this: *b2World) -> bool #cpp_method #foreign box2d "?GetAllowSleeping@b2World@@QEBA_NXZ";

    /// Enable/disable warm starting. For testing.
    SetWarmStarting :: (this: *b2World, flag: bool) -> void #cpp_method #foreign box2d "?SetWarmStarting@b2World@@QEAAX_N@Z";
    GetWarmStarting :: (this: *b2World) -> bool #cpp_method #foreign box2d "?GetWarmStarting@b2World@@QEBA_NXZ";

    /// Enable/disable continuous physics. For testing.
    SetContinuousPhysics :: (this: *b2World, flag: bool) -> void #cpp_method #foreign box2d "?SetContinuousPhysics@b2World@@QEAAX_N@Z";
    GetContinuousPhysics :: (this: *b2World) -> bool #cpp_method #foreign box2d "?GetContinuousPhysics@b2World@@QEBA_NXZ";

    /// Enable/disable single stepped continuous physics. For testing.
    SetSubStepping :: (this: *b2World, flag: bool) -> void #cpp_method #foreign box2d "?SetSubStepping@b2World@@QEAAX_N@Z";
    GetSubStepping :: (this: *b2World) -> bool #cpp_method #foreign box2d "?GetSubStepping@b2World@@QEBA_NXZ";

    /// Get the number of broad-phase proxies.
    GetProxyCount :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetProxyCount@b2World@@QEBAHXZ";

    /// Get the number of bodies.
    GetBodyCount :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetBodyCount@b2World@@QEBAHXZ";

    /// Get the number of joints.
    GetJointCount :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetJointCount@b2World@@QEBAHXZ";

    /// Get the number of contacts (each may have 0 or more contact points).
    GetContactCount :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetContactCount@b2World@@QEBAHXZ";

    /// Get the height of the dynamic tree.
    GetTreeHeight :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetTreeHeight@b2World@@QEBAHXZ";

    /// Get the balance of the dynamic tree.
    GetTreeBalance :: (this: *b2World) -> int32 #cpp_method #foreign box2d "?GetTreeBalance@b2World@@QEBAHXZ";

    /// Get the quality metric of the dynamic tree. The smaller the better.
    /// The minimum is 1.
    GetTreeQuality :: (this: *b2World) -> float #cpp_method #foreign box2d "?GetTreeQuality@b2World@@QEBAMXZ";

    /// Change the global gravity vector.
    SetGravity :: (this: *b2World, gravity: *b2Vec2) -> void #cpp_method #foreign box2d "?SetGravity@b2World@@QEAAXAEBUb2Vec2@@@Z";
    SetGravity :: (this: *b2World, gravity: b2Vec2) #no_context {
        SetGravity(this, *gravity);
    }

    /// Get the global gravity vector.
    GetGravity :: (this: *b2World) -> b2Vec2 #cpp_method #cpp_return_type_is_non_pod #foreign box2d "?GetGravity@b2World@@QEBA?AUb2Vec2@@XZ";

    /// Is the world locked (in the middle of a time step).
    IsLocked :: (this: *b2World) -> bool #cpp_method #foreign box2d "?IsLocked@b2World@@QEBA_NXZ";

    /// Set flag to control automatic clearing of forces after each time step.
    SetAutoClearForces :: (this: *b2World, flag: bool) -> void #cpp_method #foreign box2d "?SetAutoClearForces@b2World@@QEAAX_N@Z";

    /// Get the flag that controls automatic clearing of forces after each time step.
    GetAutoClearForces :: (this: *b2World) -> bool #cpp_method #foreign box2d "?GetAutoClearForces@b2World@@QEBA_NXZ";

    /// Shift the world origin. Useful for large worlds.
    /// The body shift formula is: position -= newOrigin
    /// @param newOrigin the new origin with respect to the old origin
    ShiftOrigin :: (this: *b2World, newOrigin: *b2Vec2) -> void #cpp_method #foreign box2d "?ShiftOrigin@b2World@@QEAAXAEBUb2Vec2@@@Z";
    ShiftOrigin :: (this: *b2World, newOrigin: b2Vec2) #no_context {
        ShiftOrigin(this, *newOrigin);
    }

    /// Get the contact manager for testing.
    GetContactManager :: (this: *b2World) -> *b2ContactManager #cpp_method #foreign box2d "?GetContactManager@b2World@@QEBAAEBVb2ContactManager@@XZ";

    /// Get the current profile.
    GetProfile :: (this: *b2World) -> *b2Profile #cpp_method #foreign box2d "?GetProfile@b2World@@QEBAAEBUb2Profile@@XZ";

    /// Dump the world into the log file.
    /// @warning this should be called outside of a time step.
    Dump :: (this: *b2World) -> void #cpp_method #foreign box2d "?Dump@b2World@@QEAAXXZ";

    Solve :: (this: *b2World, step: *b2TimeStep) -> void #cpp_method #foreign box2d "?Solve@b2World@@AEAAXAEBUb2TimeStep@@@Z";
    Solve :: (this: *b2World, step: b2TimeStep) #no_context {
        Solve(this, *step);
    }
    SolveTOI :: (this: *b2World, step: *b2TimeStep) -> void #cpp_method #foreign box2d "?SolveTOI@b2World@@AEAAXAEBUb2TimeStep@@@Z";
    SolveTOI :: (this: *b2World, step: b2TimeStep) #no_context {
        SolveTOI(this, *step);
    }

    DrawShape :: (this: *b2World, shape: *b2Fixture, xf: *b2Transform, color: *b2Color) -> void #cpp_method #foreign box2d "?DrawShape@b2World@@AEAAXPEAVb2Fixture@@AEBUb2Transform@@AEBUb2Color@@@Z";
    DrawShape :: (this: *b2World, shape: *b2Fixture, xf: b2Transform, color: b2Color) #no_context {
        DrawShape(this, shape, *xf, *color);
    }

    m_blockAllocator:      b2BlockAllocator;
    m_stackAllocator:      b2StackAllocator;

    m_contactManager:      b2ContactManager;

    m_bodyList:            *b2Body;
    m_jointList:           *b2Joint;

    m_bodyCount:           int32;
    m_jointCount:          int32;

    m_gravity:             b2Vec2;
    m_allowSleep:          bool;

    m_destructionListener: *b2DestructionListener;
    m_debugDraw:           *b2Draw;

    // This is used to compute the time step ratio to
    // support a variable time step.
    m_inv_dt0:             float;

    m_newContacts:         bool;
    m_locked:              bool;
    m_clearForces:         bool;

    // These are for debugging the solver.
    m_warmStarting:        bool;
    m_continuousPhysics:   bool;
    m_subStepping:         bool;

    m_stepComplete:        bool;

    m_profile:             b2Profile;
}

#scope_file

#import "Math";
#import "Windows";
box2d :: #library "./box2d";
