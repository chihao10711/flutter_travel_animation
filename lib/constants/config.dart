import 'dart:ui';

const double defaultEventHeight = 75;
const double maxEventHeight = 120;
const double minEventHeight = 45;

/// minute
const int defaultEventTime = 60;
const int defaultWalkTime = 10;

/// minute
int minEventTime =
    ((minEventHeight * defaultEventTime) / defaultEventHeight).ceil();

/// minute
int maxEventTime =
    ((maxEventHeight * defaultEventTime) / defaultEventHeight).ceil();
