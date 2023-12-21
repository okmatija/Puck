Box2D_Debug_Draw :: struct {
    using #as base : b2Draw;

    // Simp's projection matrix assumes vertices are in [0,0,-1]x[w,h,1],
    // where w and h are are the width and height of the render target.
    // This transform maps box2d world coordinates into that space
    // @cleanup This should be a matrix since that can be used to transform normals as well as positions
    transform: (Vector2)->Vector3;
}

create_box2d_debug_draw_using_simp :: (transform: (Vector2)->Vector3) -> *b2Draw {
    // Cache the simp context data so we can set it on the new contexts we push in the Box2D debug draw callbacks
    // @cleanup Is this the only/best way to ensure this state is passed into new pushed contexts?
    simp = context.simp;

    // @Incomplete Should we be heap allocating this Box2D struct?
    draw := New(Box2D_Debug_Draw);
    b2Draw.Constructor(draw);

    draw.vtable = New(b2Draw_VTable);
    draw.vtable.DrawCircle =       draw_circle;
    draw.vtable.DrawPolygon =      draw_polygon;
    draw.vtable.DrawSolidCircle =  draw_solid_circle;
    draw.vtable.DrawSolidPolygon = draw_solid_polygon;
    draw.vtable.DrawSegment =      draw_segment;
    draw.vtable.DrawTransform =    draw_transform;
    draw.vtable.DrawPoint =        draw_point;

    draw.transform = transform;

    return draw;
}

#scope_file

// The implementations here are ports of the C++ found in box2d/testbed/draw.cpp

Simp :: #import "Simp";
simp : *Simp.Immediate_State;

#import "Math";

HALF_PI :: #run .5 * PI;

// nocommit These should be configurable in Box2D_Debug_Draw
CIRCLE_SEGMENTS :: 16;
CIRCLE_INCREMENT :: #run TAU / CIRCLE_SEGMENTS;
POINT_CIRCLE_SEGMENTS :: 4;
POINT_CIRCLE_INCREMENT :: #run TAU / POINT_CIRCLE_SEGMENTS;
SEGMENT_THICKNESS :: 1.; // Simp units aka pixels


// @incomplete Segment drawing should support changing zoom levels and antialiasing etc. Adjusting the line
// thickness based on zoom probably requires a geometry shader to generate the triangles making up the line
// on the GPU. Also the restriction that start and end are in the plane z=0 should be lifted.
draw_segment :: (start: Vector3, end: Vector3, color: Vector4) {
    assert(start.z == 0. && end.z == 0.);
    normal := unit_vector(end - start);
    normal.x, normal.y = normal.y, -normal.x; // Rotate the unit direction by 90 degrees
    q0 := start + normal * .5 * SEGMENT_THICKNESS;
    q3 := start - normal * .5 * SEGMENT_THICKNESS;
    q2 := end - normal * .5 * SEGMENT_THICKNESS;
    q1 := end + normal * .5 * SEGMENT_THICKNESS;
    Simp.immediate_quad(q0, q1, q2, q3, color);
}

draw_polygon :: (this: *b2Draw, vertices: *Vector2, vertex_count: s32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        p1 := transform(vertices[vertex_count - 1]);
        for i : 0..vertex_count-1 {
            p2 := transform(vertices[i]);
            draw_segment(p1, p2, cast(*Vector4)color);
            p1 = p2;
        }
    }
}

draw_solid_polygon :: (this: *b2Draw, vertices: *Vector2, vertex_count: s32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        fill_color := Vector4.{0.5 * color.r, 0.5 * color.g, 0.5 * color.b, 0.5};

        v0 : Vector3 = transform(vertices[0]);
        for i : 1..vertex_count-2 {
            v1 : Vector3 = transform(vertices[i]);
            v2 : Vector3 = transform(vertices[i+1]);
            Simp.immediate_triangle(v0, v1, v2, fill_color, fill_color, fill_color);
        }

        p1 := transform(vertices[vertex_count - 1]);
        for i : 0..vertex_count-1 {
            p2 := transform(vertices[i]);
            draw_segment(p1, p2, cast(*Vector4)color);
            p1 = p2;
        }
    }
}

draw_circle :: (this: *b2Draw, center: *Vector2, radius: float32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        sinInc := sin(CIRCLE_INCREMENT);
        cosInc := cos(CIRCLE_INCREMENT);
        r1 := Vector2.{1.0, 0.0};
        v1 := transform(center + radius * r1);
        for 0..CIRCLE_SEGMENTS-1 {
            // Perform rotation to avoid additional trigonometry.
            r2 : b2Vec2 = ---;
            r2.x = cosInc * r1.x - sinInc * r1.y;
            r2.y = sinInc * r1.x + cosInc * r1.y;
            v2 := transform(center + radius * r2);
            draw_segment(v1, v2, cast(*Vector4)color);
            r1 = r2;
            v1 = v2;
        }
    }
}

draw_solid_circle :: (this: *b2Draw, center: *Vector2, radius: float32, axis: *Vector2, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        sinInc := sin(CIRCLE_INCREMENT);
        cosInc := cos(CIRCLE_INCREMENT);
        v0 : Vector3 = transform(center.*);
        r1 : b2Vec2 = .{cosInc, sinInc};
        v1 : Vector3 = transform(center + radius * r1);
        fill_color := Vector4.{0.5 * color.r, 0.5 * color.g, 0.5 * color.b, 0.5};
        for i : 0..CIRCLE_SEGMENTS-1 {
            // Perform rotation to avoid additional trigonometry.
            r2 : b2Vec2 = ---;
            r2.x = cosInc * r1.x - sinInc * r1.y;
            r2.y = sinInc * r1.x + cosInc * r1.y;
            v2 : Vector3 = transform(center + radius * r2);
            Simp.immediate_triangle(v0, v1, v2, fill_color, fill_color, fill_color);
            r1 = r2;
            v1 = v2;
        }

        r1 = .{1.0, 0.0};
        p1 := transform(center + radius * r1);
        for 0..CIRCLE_SEGMENTS-1 {
            // Perform rotation to avoid additional trigonometry.
            r2 : b2Vec2 = ---;
            r2.x = cosInc * r1.x - sinInc * r1.y;
            r2.y = sinInc * r1.x + cosInc * r1.y;
            p2 := transform(center + radius * r2);
            draw_segment(p1, p2, cast(*Vector4)color);
            r1 = r2;
            p1 = p2;
        }

        // Draw a line fixed in the circle to animate rotation.
        p := transform(center + radius * axis.*);
        draw_segment(v0, p, cast(*Vector4)color);
    }
}

draw_segment :: (this: *b2Draw, p1: *Vector2, p2: *Vector2, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        draw_segment(transform(p1), transform(p2), cast(*Vector4)color);
    }
}

draw_transform :: (this: *b2Draw, xf: *b2Transform) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        RED :: Vector4.{1,0,0,1};
        GREEN :: Vector4.{0,1,0,1};

        k_axisScale := 0.4;
        p1 := xf.p;

        p2 := p1 + k_axisScale * b2Rot.GetXAxis(*xf.q);
        draw_segment(transform(p1), transform(p2), RED);

        p2 = p1 + k_axisScale * b2Rot.GetYAxis(*xf.q);
        draw_segment(transform(p1), transform(p2), GREEN);
    }
}

draw_point :: (this: *b2Draw, p: *Vector2, point_diameter: float, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp;
    push_context new_context {
        Simp.set_shader_for_color(true);
        using draw := cast(*Box2D_Debug_Draw)this;

        radius := point_diameter / 2.;
        sinInc := sin(POINT_CIRCLE_INCREMENT);
        cosInc := cos(POINT_CIRCLE_INCREMENT);

        v0 : Vector3 = transform(p.*);
        r1 : b2Vec2 = .{cosInc, sinInc};
        v1 : Vector3 = transform(p.*) + radius * Vector3.{xy=r1, z=v0.z};
        fill_color := Vector4.{0.5 * color.r, 0.5 * color.g, 0.5 * color.b, 0.5};
        for i : 0..POINT_CIRCLE_SEGMENTS-1 {
            // Perform rotation to avoid additional trigonometry.
            r2 : b2Vec2 = ---;
            r2.x = cosInc * r1.x - sinInc * r1.y;
            r2.y = sinInc * r1.x + cosInc * r1.y;
            v2 : Vector3 = transform(p.*) + radius * Vector3.{xy=r2, z=v0.z};
            Simp.immediate_triangle(v0, v1, v2, fill_color, fill_color, fill_color);
            r1 = r2;
            v1 = v2;
        }
    }
}