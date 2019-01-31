classdef ComputerPortType < uint8
    enumeration
        kDataFile (0)
        kSignal (1)
        kEvent (2)
        kSegment (3)
        kFeature (4)
        kFeatureVector (5)
        kAny (6)
        kNull (7)
    end
end