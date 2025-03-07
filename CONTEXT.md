# Room AI Project Context

## Overview

Room AI is an Expo (React Native) application that transforms spaces using AI. Users can upload photos of rooms or buildings and get AI-generated redesigns based on selected styles, color palettes, and custom prompts.

## App Description

Room AI helps users visualize potential renovations and redesigns of their spaces without the need for professional designers. The app uses advanced AI to transform photos of rooms, exteriors, and objects into stunning new designs based on user preferences. Whether you're planning a home renovation, redecorating a room, or just curious about different design possibilities, Room AI provides instant visual inspiration tailored to your space.

## Tech Stack

- **Frontend**: Expo (React Native)
- **Backend**: Supabase
- **AI Services**: OpenAI (DALL-E 3, GPT-4)
- **Authentication**: Supabase Auth with Google/Apple Sign-In
- **Storage**: Supabase Storage
- **Database**: PostgreSQL (via Supabase)

## Key Features

### AI Design Generation

The app uses a two-step AI process:

1. GPT-4 generates detailed descriptions based on user selections
2. DALL-E 3 creates photorealistic images from these descriptions

### Product Recommendations

The app suggests furniture and decor items that match the generated design

### User Authentication

The app supports both anonymous and authenticated usage

### Exterior Design

Users can upload photos of building exteriors and transform them with different architectural styles and color schemes:

1. Upload exterior photo
2. Select building type (house, apartment, commercial, etc.)
3. Choose architectural style (Modern, Colonial, Mediterranean, etc.)
4. Select color palette
5. View AI-generated exterior redesign

### Object Editing

Users can select specific objects in a room to replace or modify:

1. Upload room photo
2. Select the object editing feature
3. Provide specific instructions (e.g., "Replace the sofa with a sectional")
4. View AI-generated result with only the specified object changed

### Paint & Color Changes

Users can visualize different paint colors and finishes for their walls:

1. Upload room photo
2. Select the paint & color feature
3. Choose color palette or specific paint colors
4. View AI-generated result showing the room with new wall colors

## App Flow

1. **Photo Upload**: Users take or select a photo of their space
2. **Room Selection**: Users specify the type of room or building
3. **Style Selection**: Users choose design styles (Modern, Industrial, etc.)
4. **Color Palette**: Users select color preferences
5. **Optional Prompt**: Users can add custom design instructions
6. **Results**: View AI-generated design with product recommendations
7. **Save/Share**: Save designs to profile or share with others

## Database Schema

### Tables

- **devices**: Anonymous device tracking
- **designs**: Saved design data and metadata
