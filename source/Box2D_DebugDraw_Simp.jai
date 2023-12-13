create_box2d_debug_draw :: () -> *b2Draw {
    // Cache the simp context data so we can set it on the new contexts we push in the Box2D debug draw callbacks
    simp = context.simp; // :SimpContextInCCall

    draw := New(b2Draw);

    b2Draw.Constructor(draw);
    draw.vtable = New(b2Draw_VTable);

    draw.vtable.DrawCircle =       draw_circle;
    draw.vtable.DrawPolygon =      draw_polygon;
    draw.vtable.DrawSolidCircle =  draw_solid_circle;
    draw.vtable.DrawSolidPolygon = draw_solid_polygon;
    draw.vtable.DrawSegment =      draw_segment;
    draw.vtable.DrawTransform =    draw_transform;
    draw.vtable.DrawPoint =        draw_point;

    return draw;
}

#scope_file

Simp :: #import "Simp";

// nocommit @Cleanup Should these be #c_call or #cpp_method? And update https://github.com/kujukuju/KodaBoxJai/blob/master/src/Debug.jai

// @Hack Is there a better way to do this? :SimpContextInCCall 
simp : *Simp.Immediate_State;

draw_polygon :: (this: *b2Draw, vertices: *Vector2, vertex_count: s32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_solid_polygon :: (this: *b2Draw, vertices: *Vector2, vertex_count: s32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(context.simp != null);

        Simp.set_shader_for_color(true);

        triangle_count := vertex_count - 2; 
        a := Vector3.{xy=world_to_screen(vertices[0]), z=0};
        for t : 0..triangle_count-1 {
            b := Vector3.{xy=world_to_screen(vertices[t + 1]), z=0};
            c := Vector3.{xy=world_to_screen(vertices[t + 2]), z=0};
            color_ := Vector4.{color.r, color.g, color.b, .5 * color.a};
            Simp.immediate_triangle(a, b, c, color_, color_, color_);
        }
    }
}

draw_circle :: (this: *b2Draw, center: *Vector2, radius: float32, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_solid_circle :: (this: *b2Draw, center: *Vector2, radius: float32, axis: *Vector2, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_segment :: (this: *b2Draw, p1: *Vector2, p2: *Vector2, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_transform :: (this: *b2Draw, xf: *b2Transform) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_point :: (this: *b2Draw, p: *Vector2, size: float, color: *b2Color) #cpp_method {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_segment :: (this: *b2Draw, p1: Vector2, p2: Vector2, color: b2Color) #c_call {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_transform :: (this: *b2Draw, xf: b2Transform) #c_call {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}

draw_point :: (this: *b2Draw, p: Vector2, size: float, color: b2Color) #c_call {
    new_context : Context;
    new_context.simp = simp; // :SimpContextInCCall
    push_context new_context {
        assert(false, "Not implemented.");
    }
}