classdef AnnotationState < uint8
    enumeration
        kZoomInState(1)
        kZoomOutState (2)
        kPanState (3)
        kSetTimeline (4)
        kAddEventState (5)
        kAddRangeState (6)
        kModifyAnnotationState (7)
        kDeleteAnnotationState (8)
    end
end