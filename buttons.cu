struct Button_State {
    bool is_down;
    bool changed;
};
enum {
    BUTTON_W,
    BUTTON_A,
    BUTTON_S,
    BUTTON_D,
    BUTTON_COUNT
};
struct Input {
    Button_State buttons[BUTTON_COUNT];
};