//
// Occlusion is one-frame delayed, and the thesis is
// that this is probably fine for practical purposes.
// It's considered an acceptable tradeoff for the
// simplicity we gain by not having to delay knowing the
// response to a button press, etc. That said, there is
// definitely room for a more-deferred version of this API
// if that makes more sense later.
//

occlusion_per_frame_update :: () {
    Swap(*occlusions_current_frame, *occlusions_next_frame);
    occlusions_next_frame.count = 0;

    quick_sort(occlusions_current_frame, x => -x.serial);

    current_occluder = null;
}

occlusion_per_window_update :: (window: Window_Type) {
    x, y := mouse_x_float, mouse_y_float;
    for * occlusions_current_frame {
        if it.widget.window != window continue;
        if is_inside(x, y, it.rect) {
            current_occluder = it.widget;
            break;
        }
    }
}

occlusion_declare :: (rect: Rect, widget: *Active_Widget) {
    record := array_add(*occlusions_next_frame);

    record.serial = cast(s32)(occlusions_next_frame.count);
    record.rect   = rect;
    record.widget = widget;
}

events_occluded :: () -> bool {
    // Kind of cheesy, but, probably works?
    // If whoever is marked as current_occluder has not yet
    // declared its occlusion this frame, we are occluded!
    
    if !current_occluder                   return false;
    if current_occluder.is_on_state_stack  return false;

    return current_occluder.last_getrect_frame != current_getrect_frame;
}

#scope_file

#import "Sort";

Occlusion_Record :: struct {
    serial: s32;   // Used to compare occlusions against each other. Higher serial occludes lower serial.
    rect:   Rect;
    widget: *Active_Widget;
}

occlusions_current_frame: [..] Occlusion_Record;
occlusions_next_frame:    [..] Occlusion_Record;
