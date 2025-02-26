# Home AI - Project Context

## App Purpose

"home ai" is an innovative interior design app that leverages artificial intelligence to transform user-uploaded room photos into beautifully redesigned spaces. Whether you're a homeowner, renter, or design enthusiast, our app helps you visualize and plan your next home makeover. Enjoy essential features for free and upgrade to PRO for premium benefits like watermark removal and extra design styles.

## App Flow

The user journey follows a simple three-step process:

### Step 1: Add a Photo

- **Location:** Main screen under the "Create" tab.
- **Functionality:** Upload a room photo via camera or gallery using Flutter's image_picker package. Example photos are displayed to guide users.
- **UI Elements:**
  - Dashed box for photo upload
  - "Start Redesigning" text
  - Prominent "Add a Photo" button
  - Grid of example photos
  - Bottom navigation tabs (Tools, Create, My Profile)

### Step 2: Choose Room

- **Location:** Following the photo upload.
- **Functionality:** Select the room type (e.g., Kitchen, Living Room, Bedroom) to provide the spatial context for the AI.
- **UI Elements:**
  - Vertical list of room options with icons and labels
  - "Continue" button at the bottom
  - Back navigation at the top
  - Progress indicator displaying "Step 2/3"

### Step 3: Select Style

- **Location:** After choosing the room type.
- **Functionality:** Pick a design style (e.g., Modern, Minimalistic, Bohemian) to be applied to the room.
- **UI Elements:**
  - Grid of style options with images and labels
  - "Continue" button
  - Back navigation
  - Progress indicator displaying "Step 3/3"

### Processing & Results

- **Workflow:** Upon completing the steps, the app sends the photo, room type, and selected style to a paid AI API.
- **UI Elements:**
  - "Processing..." screen with a red couch icon and a note urging users to keep the app open
  - Final screen displaying the redesigned room image along with options to regenerate, share, or save the design (with premium users receiving watermark removal)

## Navigation & Additional Features

- **Tools Tab:** Offers utility features like tutorials, settings, and advanced customization (e.g., brightness/contrast adjustments).
- **My Profile Tab:** Displays user account info, saved designs, subscription status, and logout options.
- **PRO Feature:** Unlocks premium styles, watermark removal, and faster AI processing. Accessible via a red "PRO" button or integrated Superwall paywall.

## UI Placement & Design

- **Header:** A sleek black bar featuring the "home ai" logo (a green circular icon) and an optional settings gear.
- **Main Content:** Centered layout with a clean, minimal design. White backgrounds, rounded buttons, and subtle shadows enhance the user experience.
- **Navigation:** Bottom tab bar with icons for Tools, Create, and My Profile.
- **Loading State:** A distinct "Processing..." screen ensures clarity and communicates the ongoing operation.

## Tech Stack

### Frontend

- **Framework:** Flutter for cross-platform (iOS/Android) development.
- **UI Libraries:**
  - Utilize Flutter's Material (or Cupertino) widgets for building native interfaces.
  - Flutter's built-in Navigator and animation tools for seamless transitions.
  - [`image_picker`](https://pub.dev/packages/image_picker) to handle photo uploads.
- **State Management:** Options like Provider, Riverpod, or Bloc to manage the multi-step flow, user data, and design states.
- **Styling:** Leverage Flutter's widget system and theming capabilities for consistent UI styling.

### Backend

- **Database & Auth:** Supabase with PostgreSQL manages user data, design assets, and preferences, using Supabase Auth for secure authentication.
- **Storage:** Supabase Storage hosts uploaded photos and generated designs, providing public URL access.
- **Real-Time:** Supabase real-time subscriptions can notify users about updates or sync across devices.

### In-App Purchases and Premium Features

- **Tool:** Superwall integrates with the app to manage subscriptions, one-time purchases, and premium feature gating.
- **Pricing:** Free tier offers basic designs with watermarks; PRO tier (e.g., $4.99/month or $49.99/year) unlocks premium styles, watermark removal, and enhanced processing speed.

### AI Integration (Paid API)

- **Choices:**
  - **OpenAI's DALL·E 3:** High-fidelity image generation starting at ~$0.02 per image.
- **Workflow:**
  - The app sends a POST request with the photo, room type, and design style.
  - Receives a generated image (as a URL or base64 string) and displays it to the user.
  - Caches results in Supabase for quicker future access.

### Additional Tools

- **Version Control:** Git (e.g., GitHub) for source code management.
- **Testing:** Use Flutter's testing framework along with packages such as Mockito for unit and widget tests; integration tests can leverage Flutter's own integration testing tools.
- **Deployment:** Use Flutter's build tools along with CI/CD pipelines (e.g., Codemagic or GitHub Actions) for building and deploying on the App Store and Google Play.

## Key Considerations

- **Performance:** Utilizing paid APIs (DALL·E 3) ensures faster processing. Use Flutter's built-in progress indicators to indicate progress.
- **Scalability:** Monitor API usage and optimize Supabase resources to handle increased demand.
- **Security:** Implement Supabase Row Level Security (RLS) and secure sensitive data using environment variables.
- **User Experience:** Ensure an intuitive 3-step flow with clear loading states and robust error handling, especially during API communications.

## Database Schema

Below is the full database schema for the app:

```sql
-- Users Table
CREATE TABLE IF NOT EXISTS users (
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   email TEXT UNIQUE NOT NULL,
   full_name TEXT,
   subscription_status TEXT DEFAULT 'free',
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
   updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Designs Table
CREATE TABLE IF NOT EXISTS designs (
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   original_image_url TEXT NOT NULL,
   generated_image_url TEXT,
   room_type VARCHAR(50) NOT NULL,
   style VARCHAR(50) NOT NULL,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Room Options Table
CREATE TABLE IF NOT EXISTS room_options (
   id SERIAL PRIMARY KEY,
   name VARCHAR(50) UNIQUE NOT NULL,
   icon TEXT,  -- asset reference or icon name
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Styles Table
CREATE TABLE IF NOT EXISTS styles (
   id SERIAL PRIMARY KEY,
   name VARCHAR(50) UNIQUE NOT NULL,
   image_url TEXT,  -- sample image for style
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS subscriptions (
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   plan VARCHAR(50) NOT NULL,  -- e.g., 'pro', 'free'
   start_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
   end_date TIMESTAMP WITH TIME ZONE,
   active BOOLEAN DEFAULT true
);
```

## Folder Structure

Below is the optimal folder structure for the Flutter app:

```bash
+/home-ai-app/
  /android/          # Native Android code
  /ios/              # Native iOS code
  /lib/
      /models/      # Data models (e.g., User, Design, RoomOption, Style)
      /screens/     # UI screens (e.g., PhotoUploadScreen, RoomSelectionScreen, StyleSelectionScreen, ResultsScreen)
      /widgets/     # Reusable UI components (e.g., CustomButton, ProgressIndicator)
      /services/    # API calls, Supabase integration, and AI service integration
      /state/       # State management files (Provider, Riverpod, Bloc, etc.)
      /utils/       # Utility functions and constants
  /assets/
      /images/      # App images and design examples
      /icons/       # Icons used in the app
      /fonts/       # Custom fonts
  /test/             # Unit and widget tests
  pubspec.yaml       # Flutter configuration file
  README.md          # Project documentation
  docs/CONTEXT.md    # Project context (this file)
```

## Complete Folder Structure & Files

Below is the complete folder structure and file list for the Home AI Flutter app:

```bash
+/home-ai-app/
  /android/                      # Native Android code
  /ios/                          # Native iOS code
  /lib/
      main.dart                 # Main entry point configuring MaterialApp and routing
      /models/                 # Data models (e.g., User, Design, RoomOption, Style)
      /screens/                # UI screens:
          photo_upload_screen.dart       # Photo upload screen implementation
          room_selection_screen.dart       # Room selection screen implementation
          style_selection_screen.dart      # Style selection screen implementation
          results_screen.dart              # Processing/results screen implementation
      /widgets/                # Reusable UI components (e.g., CustomButton, ProgressIndicator)
      /services/               # API services:
          supabase_service.dart          # Supabase service integration
          ai_service.dart                # AI API integration for design generation
      /state/                  # Global app state management using ChangeNotifier
          app_state.dart                 # State management file
      /utils/                  # Utility functions and constants
  /assets/
      /images/                 # App images and design examples
      /icons/                  # Icons used in the app
      /fonts/                  # Custom fonts
  /test/                         # Unit and widget tests
  pubspec.yaml                   # Flutter configuration file
  README.md                      # Project documentation
  docs/CONTEXT.md                # Project context (this file)
```
