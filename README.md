Here’s a cleaned-up, well-structured version of your notes. I’ve standardised headings, indentation, and bullet styles for clarity, while preserving all details.

---

# Git Setup Instructions

1. **Clone the repository**

   * Use a path with no spaces.

2. **Create a new Quartus project**

   * Use the *New Project Wizard*.
   * Set the repository as the project path.
   * Use **`MTRX3700Ass1`** as the project name.
   * Select the DE2 board (Cyclone IV, EP4CE115F29C7).

3. **Add Verilog files**

   * In Quartus: `Project → Add/Remove Files in Project`.
   * Add all `.v` files.

4. **Commit and push code**

   * Use `git add .`, `git commit`, and `git push` in the terminal.
   * Only push *working* code.
   * The `.gitignore` ensures Quartus build files aren’t committed.

5. **Done**

   * Everyone’s local Quartus build will regenerate its own files.

---

# Module Allocation

* **Falgun**: `fsm`, `fsm_timer`
* **Mok**: `mole_generator`
* **Sahaj**: `display`, `score_counter`
* **Lara**: `combo_counter`
* **Noah**: `hit_logic`, `top_level`

---

# Module Specifications

## Falgun

### FSM

**Parameters**

* `MOLE_UP_MS`
* `MOLE_DOWN_MS`

**Inputs**

* `clk`
* `timer_seconds`
* `timer_milliseconds`
* `start_button_pressed`
* `reset_button_pressed`

**Outputs**

* `game_in_progress` (0 = INIT, 1 = MOLE\_UP / MOLE\_DOWN, 0 = GAME\_OVER)
* `rst`
* `mole_clk`

**Notes**

* SystemVerilog, use a big `case` for state transitions as a function of `timer_seconds`, `timer_milliseconds`, `start_button_pressed`, and `reset_button_pressed`.
* Four states: **INIT**, **MOLE\_UP**, **MOLE\_DOWN**, **GAME\_OVER**.
* Mealy FSM: `rst` depends on `reset_button_pressed`.
* `mole_clk` → `mole_generator`.
* `rst` → all stateful modules (including timer).
* In GAME\_OVER: `mole_clk` low, `game_over` signal high (forces moles to disappear).
* Timer enable allows counting down; otherwise timer halts.

**MOLE\_UP/DOWN logic**

```verilog
period = MOLE_UP_MS + MOLE_DOWN_MS;

on clk event:
  if state == MOLE_UP or state == MOLE_DOWN:
    if (timer_milliseconds % period > MOLE_DOWN_MS)
      state = MOLE_UP;
    else
      state = MOLE_DOWN;
```

* `timer_milliseconds` starts at `1000 × GAME_LENGTH_SECONDS`.
* `timer_seconds = timer_milliseconds // 1000`. Used for display.

---

### Button Debouncers

**Start button (`KEY[1]`)**

* Parameter: `DELAY_COUNTS`
* Inputs: `clk`, `KEY[1]`
* Output: `start_button_pressed`

**Reset button (`KEY[0]`)**

* Parameter: `DELAY_COUNTS`
* Inputs: `clk`, `KEY[0]`
* Output: `reset_button_pressed`

---

### FSM Timer

**Parameters**

* `GAME_LENGTH_SECONDS`
* `CLK_PER_MS`

**Inputs**

* `clk`
* `rst`
* `game_in_progress` (as `timer_enable`)

**Outputs**

* `timer_seconds`
* `timer_milliseconds`

---

## Mok

### Mole Generator

**Parameters**

* `NUMBER_OF_MOLES`
* `NUMBER_OF_HOLES`

**Inputs**

* `clk`
* `mole_clk`

**Outputs**

* `mole_positions[17:0]`

**Notes**

* When state changes from MOLE\_DOWN → MOLE\_UP:

  * Generate 3 random numbers in `[0, NUMBER_OF_HOLES-1]`.
  * Convert each into one-hot masks of length `NUMBER_OF_HOLES`.
  * OR them together.
* On MOLE\_UP: set `mole_positions` = ORed mask.
* On MOLE\_DOWN: set `mole_positions` = 0.

---

## Sahaj

### Display Modules

**Timer display (`display_2dig`)**

* Inputs: `clk`, `timer_seconds`
* Outputs: `HEX6`, `HEX7`

**Combo display (`display_2dig`)**

* Inputs: `clk`, `combo_count`
* Outputs: `HEX4`, `HEX5`

**Score display (`display_4dig`)**

* Inputs: `clk`, `score`
* Outputs: `HEX3`, `HEX2`, `HEX1`, `HEX0`

**Notes**

* Use existing display code.
* Can unify into one parameterised module for `n` digits.

---

### Score Counter

**Inputs**

* `clk`
* `combo_count`
* `rst`

**Output**

* `score`

**Notes**

* If `combo_count` changed since last cycle → add `combo_count` to `score`.
* Always output `score`.
* If `rst` high → reset score to 0.

---

## Lara

### Combo Counter

**Inputs**

* `clk`
* `miss`
* `non_full_clear_hit`
* `full_clear_hit`
* `rst`

**Output**

* `combo_count`

**Notes**

* All synchronous. No edge detection except clock.
* If `rst` high → reset `combo_count` to 0.
* Always output `combo_count`.
* `score_counter` detects synchronous changes in `combo_count`.

---

## Noah

### Hit Logic

**Inputs**

* `clk`
* `mole_positions[17:0]`
* `SW[17:0]`
* `game_in_progress`

**Outputs**

* `LEDR[17:0]`
* `miss`
* `non_full_clear_hit`
* `full_clear_hit`

**Notes**

* LEDs light on mole changes.
* Active only when `game_in_progress = 1`.
* Tracks switch edges to clear LEDs.
* Each edge triggers one of three signals for one cycle:

  * **miss**: LED didn’t turn off.
  * **non\_full\_clear\_hit**: LED turned off but others still lit.
  * **full\_clear\_hit**: LED turned off and all LEDs cleared.
* Switches must be synchronised to `clk`.

---

### Top Level

**Inputs**

* `CLOCK_50`
* `SW[17:0]`
* `KEY[1:0]`

**Outputs**

* `HEX0–HEX7`
* `LEDR[17:0]`

**Notes**

* Integrates all modules described above.
* This doc fully specifies the required top-level wiring.

---
