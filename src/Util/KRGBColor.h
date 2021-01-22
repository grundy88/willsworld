typedef struct {
    float r, g, b, a;
} KRGBColor;

static KRGBColor KRGBColorMake(float red, float green, float blue, float alpha) {
    KRGBColor c; c.r = red; c.g = green; c.b = blue; c.a = alpha; return c;
}

static KRGBColor KRGBColorWhite() {
    KRGBColor c; c.r = 1; c.g = 1; c.b = 1; c.a = 1; return c;
}

static KRGBColor KRGBColorBlack() {
    KRGBColor c; c.r = 0; c.g = 0; c.b = 0; c.a = 1; return c;
}

static KRGBColor KRGBColorClear() {
    KRGBColor c; c.r = 0; c.g = 0; c.b = 0; c.a = 0; return c;
}

static BOOL isClear(KRGBColor color) {
    return color.a == 0;
}
