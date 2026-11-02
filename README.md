# Together ❤️ — Couples' Companion Mobile App

A cross-platform couples' companion app for **Android and iOS** built around communication, playful interactions, shared planning, and preserving memories.

Built with **Flutter** on the mobile frontend and a **Node.js + PostgreSQL (PGlite / standard Postgres) + WebSocket** real-time sync relay server.

---

## 🌟 Philosophy: The Interconnected Couples' Experience

Rather than eight isolated features, **Together** is built as one interconnected relationship hub where interactions naturally flow into one another:

```
          [Shared Wishlist]
                 │ (1-tap conversion)
                 ▼
          [Shared Planning] (Dates & Trips)
                 │ (1-tap preserve)
                 ▼
          [Scrapbook Memories] ◄─── (Linked Memories)
                 ▲
                 │ (1-tap convert Q&A)
          [Questions & Conversations]
                 │ (Revealed answers)
                 ▼
          [Private Shared Journal]
                 ▲
                 │ (Nudges & reactions)
          [Turn-Based Games] ────► [Cute Affection & Messages]
```

- **Wishlist to Plan:** Schedule any wishlist dream (places to visit, restaurants, movies, bucket-list items) directly into a date night or trip with a single tap.
- **Plan to Memory:** When a date night or vacation is completed, convert it directly into a permanent digital scrapbook memory with photos, location, and tags.
- **Questions to Journal:** When both partners answer and reveal a daily or custom question, 1-tap archives the entire conversation into your private shared journal for posterity.
- **Turn-Based Games to Cute Nudges:** Playing a move in games like *Would You Rather?*, *This or That*, or *Truth or Dare* triggers real-time love alerts and streaks on your partner's phone.

---

## ❤️ Core Features

### 1. Questions & Conversations
- **Daily Conversation Prompts:** Pre-seeded question banks across **Romantic**, **Deep**, **Funny**, and **Hypothetical** categories.
- **Mystery Lock & Dual Reveal:** Both partners answer independently. Answers remain concealed until both have answered, then celebrate with a mutual reveal animation!
- **Custom Questions:** Ask your partner anything at any time.
- **Journal Integration:** Save revealed conversations to your shared relationship journal.

### 2. Turn-Based Games
Asynchronous games playable throughout the day:
- **Would You Rather?:** Compare romantic/funny scenarios, guess your partner's choice, and see your compatibility match score!
- **This or That:** Quick-fire habit and lifestyle comparisons (Coffee vs Tea, Sunset beach vs Snowy mountain).
- **Truth or Dare:** Card flip challenges with cute photo/note completion confirmations.
- **Guess My Answer:** Secret hidden prompt answers with partner guessing and scoring.
- **Couple Streaks:** Daily gameplay streak counter.

### 3. Shared Planning
- **Trips & Date Nights:** Comprehensive trip itineraries and date night planners.
- **Day-by-Day Activities:** Checkable itinerary timeline with scheduled times.
- **Shared Budget & Expense Tracker:** Log expenses with split 50/50, paid by partner 1, or paid by partner 2.
- **Scrapbook Integration:** Completed plans convert directly to Scrapbook Memories.

### 4. Quick Reminders
- Instant affectionate nudges: *"Drink water ❤️"*, *"Don't forget your jacket 🧥"*, *"Take vitamins 💊"*.
- Cute notification styles: Gentle 🌸, Playful 🐱, Emergency Hug 🫂, Urgent ⚡.
- Quick completion reactions: ❤️, 🐾, 😘, ✔️.

### 5. Cute Messages & Spontaneous Affection
- **Instant Affection Studio:** Send a warm Virtual Hug 🫂, Sweet Kiss 💋, or *"I Miss You"* 🥺 in one tap.
- **Real-Time Heart Particles:** Interactive animated floating hearts triggered on both phones in real-time via WebSockets.
- **Surprise Messages:** Sealed gift box notes that unlock at a scheduled date/time.

### 6. Memories (Digital Scrapbook)
- Chronological timeline of special moments with captions, dates, and locations.
- **"On This Day" Flashbacks:** Automatically surfaces memories and anniversaries from past years on today's date!
- Linked directly to planned trips and wishlist completions.

### 7. Shared Private Journal
- Collaborative relationship diary visible to both partners.
- Mood badges: *Happy 😊*, *Loved ❤️*, *Cozy ☕*, *Grateful 🙏*, *Adventurous 🏕️*, *Playful ✨*.
- Import revealed Q&A conversations as journal entries.

### 8. Shared Wishlist
- Categorized bucket lists: Places to visit, Restaurants, Movies, Things to buy, Experiences.
- Priority tags: High, Medium, Low.
- 1-tap **"Schedule Date Plan 🗓️"** integration.

---

## 📱 App Navigation (5 Tabs)

| Tab | Contains |
|---|---|
| 🏠 **Home** | Dashboard, relationship counter, partner online indicator, quick affection bar, daily question highlight, active game nudge, upcoming plans & reminders |
| ❤️ **Us** | Questions & Conversations, Turn-Based Games hub, Cute Messages & Affection Studio |
| 🗓️ **Plans** | Trips & Date nights planner, checkable itineraries, budget/expenses tracker |
| 📸 **Memories** | Scrapbook photo timeline & Shared Private Journal with mood tags |
| ✨ **Wishlist** | Categorized shared bucket list with 1-tap plan conversion |

---

## 🏗️ Technical Architecture

### 1. Mobile Client (`together_app/`)
- **Framework:** Flutter 3.47+ (Dart)
- **State Management:** `Provider` (`TogetherState`)
- **Networking:** HTTP REST (`ApiService`) + Realtime WebSockets (`WebSocketService`)
- **Persistence:** `SharedPreferences` for local pairing credentials and offline caching
- **Platform Support:** Android & iOS native targets

### 2. Backend Server (`server/`)
- **Runtime:** Node.js v20+ / Express
- **Database:** **PostgreSQL**
  - **PGlite** disk persistence (`./data/together_postgres_db`) runs out of the box with zero external dependencies.
  - Can optionally connect to any external PostgreSQL instance (e.g. Neon, Supabase, local Postgres) by setting `DATABASE_URL` in `.env`.
  - Automatic migration script (`schema.sql`) and rich pre-seeded question banks (`seedData.js`).
- **Real-time Engine:** WebSocket Hub (`ws`) partitioned into private couple rooms (`LOVE-XXXX` space codes).

---

## 🚀 Getting Started

### 1. Start the Backend Server
```bash
cd server
npm install
node src/index.js
```
The server will start on `http://0.0.0.0:4000` with WebSocket on `ws://0.0.0.0:4000/ws`.

Run the automated backend test suite anytime:
```bash
node test_server.js
```

### 2. Run the Flutter Mobile App
```bash
cd together_app
flutter pub get
flutter run
```

### 3. Dual-Partner Testing on One Device (Simulation Mode)
Testing a couples app usually requires two physical phones. To make development and testing effortless, **Together** includes a built-in **"Switch Partner"** toggle right in the header bar of the app:
1. Tap **"Switch: Alex (partner1)"** to immediately toggle your view to **"Sam (partner2)"**.
2. Answer the question from partner 2's perspective to watch the mystery reveal and floating celebration animation happen in real-time!
3. Tap **"Enter Invite Code"** from partner 2's device and enter the 6-character code (e.g., `LOVE-KRF3`) to pair real devices.
