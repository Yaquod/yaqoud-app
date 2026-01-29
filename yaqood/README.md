# Yaqood - Location-Based Mobile Application

A fully-featured Flutter mobile application for location-based services with seamless navigation, Google Maps integration, and real-time location tracking. Yaqood provides users with an intuitive interface for selecting pickup and destination locations with interactive maps and place search capabilities.



## 🎯 Project Overview

Yaqood is a comprehensive Flutter mobile application designed for location-based services. The application features a smooth user onboarding experience, secure authentication, and an interactive Google Maps interface with advanced location selection capabilities. The app is optimized for both Android and iOS platforms with Material Design principles.

## ✨ Key Features

### Splash Screen
- App branding display
- Smooth transition into the application flow

### Onboarding
- Multi-screen onboarding experience for new users
- Feature highlights and app introduction
- Leads users to authentication

### Authentication
- User login and registration screens
- Secure authentication flow
- Clean and intuitive UI
- Input validation and error handling

### Home Screen & Navigation
- **Interactive Google Map**
  - Real-time user location tracking
  - Draggable camera for map exploration
  - Dynamic location markers

- **Floating Action Buttons (FABs)**
  - Quick access to map actions
  - Location refresh functionality
  - Intuitive icon-based controls

- **Drawer Navigation**
  - Slide-out menu for app navigation
  - Access to user profile and settings
  - Quick navigation to key sections

- **Bottom Sheet Interface**
  - Ride-hailing style bottom sheet
  - Location selection and confirmation
  - Action buttons and controls
  - Smooth animations and transitions

### Location Selection & Search
- **Interactive Location Picking**
  - Drag the map to select start location
  - Draggable markers for precise selection
  - Start and destination location handling

- **Google Places Autocomplete**
  - Real-time place search
  - Address suggestions as user types
  - Quick location selection from search results

- **Reverse Geocoding**
  - Display street names and addresses
  - Convert coordinates to readable locations
  - Address formatting and display

### Real-Time Features
- Live user location tracking
- Dynamic map updates
- Instant location synchronization

## 🛠 Technical Stack

### Framework & Language
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language

### Maps & Location Services
- **Google Maps SDK** - Interactive map display and controls
- **Google Places API** - Place search and autocomplete functionality
- **Geolocator** - Real-time user location tracking
- **Geocoding** - Reverse geocoding for address conversion

### UI & Design
- **Material Design** - Google's design system implementation
- **Flutter Material Components** - Pre-built UI widgets

### State Management
- **setState** - Widget-level state management



## 📱 App Flow

```
Splash Screen (3 seconds)
    ↓
Onboarding Screens (First-time users)
    ↓
Authentication Flow
    ├── Login Screen
    └── Register Screen
    ↓
Home Screen
    ├── Google Maps Interface
    ├── Floating Action Buttons
    ├── Drawer Navigation
    └── Bottom Sheet for Location Selection
```

### Detailed Flow Description

**Splash Screen**
- Displays app branding and logo
- Initializes app resources
- Auto-transitions to onboarding or home

**Onboarding**
- Multi-screen introduction for new users
- Feature highlights and benefits
- Skip or complete options

**Authentication**
- Secure login for existing users
- Registration for new accounts
- Input validation and error messages

**Home Screen**
- Interactive Google Map with user location
- Floating buttons for quick actions
- Drawer for navigation options
- Bottom sheet for detailed interactions

## 🧩 Project Structure

The project follows a clean and organized Flutter structure, separating screens, widgets, models, and shared resources to ensure maintainability and scalability.

---

## 📌 Summary

Yaqood demonstrates how Flutter can be used to build a modern, map-based mobile application with smooth UI interactions, real-time location handling, and a user experience inspired by real-world ride-hailing apps.

---
