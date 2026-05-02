# Decision Maker App — Product Brief

## Product Summary

Decision Maker is a playful mobile app that helps users make quick everyday decisions using animated pickers.

The core experience is simple:

1. Open the app.
2. Choose a picker.
3. Tap to spin.
4. Watch the choices animate.
5. Get a final decision.

The app should feel fast, fun, minimal, and satisfying.

---

## User-Facing Language

Use **Picker** in the UI instead of “Decision Group.”

Examples:

- Your Pickers
- Create Picker
- Food Picker
- Pick Again
- The picker has spoken

The internal model can still be called `DecisionGroup`, but the app copy should feel more human.

---

## Core User Flow

### 1. Home Screen

The user sees a list/grid of available pickers.

Default pickers:

- 🍔 Food Picker
- 🎬 Movie Genre Picker
- 🎲 Truth or Dare: Safe Edition
- 🎮 Game Night Picker
- 🌤️ Weekend Activity Picker

The user can tap any picker to open the animated picker screen.

The user can also create a custom picker.

---

### 2. Create Picker Screen

The user creates a custom picker by entering:

- Picker name
- List of choices

The user can:

- Add a choice
- Remove a choice
- Edit a choice
- Save the picker

Validation:

- Picker name is required.
- At least 2 valid choices are required.
- Empty choices should be ignored or removed.
- Duplicate choices are not allowed in MVP.
- Save button should be disabled until the form is valid.

---

### 3. Picker Screen

The user sees a vertical slot-style picker.

The picker should:

- Show the selected picker name.
- Show a central highlighted selection area.
- Animate vertically through choices.
- Start fast.
- Gradually slow down.
- Land on a randomly selected choice.
- Display the result prominently.

Actions:

- Pick Again
- Done / Back to Pickers

During the animation:

- Disable buttons.
- Prevent double taps.
- Optionally trigger light haptics when the result lands.

---

## Picker States

### Idle

Before spinning:

- Show the picker name.
- Show available choices in the slot area.
- Show CTA: “Pick for me.”

Suggested copy:

> Ready to pick?

---

### Spinning

While spinning:

- Choices scroll vertically.
- Center highlight remains fixed.
- Buttons are disabled.
- Animation should feel smooth and playful.

Suggested copy:

> Choosing...

---

### Result

After landing:

- The selected result is locked in the center.
- Result is visually emphasized.
- Show a small celebratory moment.

Suggested copy:

> The picker has spoken.

Actions:

- Pick Again
- Done

---

### Error / Invalid State

If a picker has fewer than 2 choices:

- Disable picking.
- Show a helpful message.

Suggested copy:

> Add at least 2 choices to start picking.

---

## Default Picker Data

### Food Picker

- Pizza
- Sushi
- Burgers
- Tacos
- Ramen
- Pasta

### Movie Genre Picker

- Action
- Comedy
- Horror
- Sci-Fi
- Drama
- Animation

### Truth or Dare: Safe Edition

- Truth: What’s your favorite memory?
- Dare: Do 10 pushups
- Truth: What’s your dream job?
- Dare: Sing a song
- Truth: What food could you eat forever?
- Dare: Do your best movie trailer voice

### Game Night Picker

- Mario Kart
- Smash Bros
- Board Game
- Card Game
- Trivia
- Co-op Game

### Weekend Activity Picker

- Coffee run
- Movie night
- Walk outside
- Try a new restaurant
- Game night
- Mini road trip

---

## Voice and Microcopy

The voice should be playful, short, and not too cheesy.

Good examples:

- Let fate decide.
- No overthinking.
- Too many options? Spin it.
- The picker has spoken.
- One more spin?
- Done deciding.
- Pick for me.
- Spin again?

Avoid:

- Casino-heavy language
- Overly childish copy
- Complicated explanations
- Long onboarding text

---

## Visual Direction

The app should feel:

- Clean
- Modern
- Playful
- Minimal
- Friendly
- Fast

Use:

- Rounded cards
- Bold typography for results
- Soft shadows
- Smooth transitions
- Large tap targets
- Friendly icons or emoji
- Light gradients or accent colors

Avoid:

- Casino slot machine visuals
- Heavy skeuomorphic slot design
- Cluttered UI
- Overly dark gamer-only aesthetic
- Too many animations at once

---

## MVP Scope

Must have:

- Home screen with default pickers
- Create custom picker
- Delete custom picker
- Local persistence
- Animated vertical picker
- Pick again
- Basic haptic feedback
- Form validation

Not MVP:

- User accounts
- Cloud sync
- Multiplayer
- Community templates
- Weighted choices
- Sound effects
- Themes
- Wheel picker mode
- Decision history

---

## Future Ideas

V2:

- Edit custom pickers
- Reorder choices
- Save last picked result
- Share result
- Decision history

V3:

- Community templates
- Daily random decisions
- Multiplayer voting
- Cloud sync
- Theme customization
- Weighted choices
- No-repeat mode
