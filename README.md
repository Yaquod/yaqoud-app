# Yaqood - Autonomous Urban Taxi Mobile Application 🚕

A fully-featured Flutter mobile application for location-based ride-hailing services with seamless navigation, Google Maps integration, route visualization, and ride simulation using an HTTP polling architecture.

Yaqood provides a smooth, real-world ride-hailing style experience where users can search locations, pick pickup & destination points, view routes, and simulate the process of finding a driver.

---

## 🎯 Project Overview

Yaqood is a comprehensive Flutter mobile application designed to simulate a modern ride-hailing experience.  
The app focuses on delivering a clean UI, smooth navigation, real-time location handling, and scalable architecture ready for backend integration.

The application is optimized for both **Android & iOS** and follows **Material Design** principles.

---

## ✨ Key Features

## 🟣 App Foundation

### Splash Screen
- App branding display
- Smooth transition into the application flow

### Onboarding
- Multi-screen onboarding experience
- Highlights app features and workflow
- Guides users to authentication

### Authentication
- Login & Registration screens
- Input validation and error handling
- Clean and intuitive UI flow

---

## 🗺 Home Screen & Navigation

### Interactive Google Map
- Real-time user location tracking
- Draggable camera navigation
- Dynamic map markers
- Smooth camera animations

### Floating Action Buttons (FABs)
- Quick access to map actions
- Instant location refresh
- Simple icon-based controls

### Drawer Navigation
- Slide-out navigation menu
- Easy access to main sections
- Profile & settings entry points

### Bottom Sheet Interface
- Ride-hailing style bottom sheet
- Pickup & destination selection
- Action buttons and confirmations
- Smooth animated transitions

---

## 📍 Location Selection & Search

### Interactive Location Picking
- Drag map to choose pickup location
- Draggable markers for precise positioning
- Start & destination handling

### Google Places Autocomplete
- Real-time place search
- Address suggestions while typing
- Quick selection from results

### Reverse Geocoding
- Convert coordinates → readable addresses
- Display street names and location details
- Clean address formatting

---

## 🧭 Map & Navigation Enhancements

### Route Drawing & Visualization
- Polyline route between pickup & destination
- Real-time route rendering on the map
- Auto-fit camera to show the full route
- Smooth camera transitions

### Advanced Map Controls
- Cancel route button to reset map state
- Search field moves camera to searched place
- Improved marker handling
- Fixed FocusNode lifecycle issues

### Enhanced User Interaction
- Visual feedback during location selection
- Smooth gestures and animations
- Better overall UX while navigating the map

---

## 🚗 Ride Simulation & Driver Search

### HTTP Polling Architecture
- Simulated driver search using periodic API polling
- Real-time trip state updates:
  - `PENDING → SEARCHING → FOUND → COMPLETED`
- Configurable polling intervals
- Async-ready architecture for real backend APIs

### Loading & Feedback States
- Loading indicators during driver search
- Snackbar feedback for errors and actions
- Status messages during ride request lifecycle
- Seamless UI state transitions

### Backend-Ready Networking Layer
- Prepared for REST API integration
- Scalable structure for real ride-hailing backend
- Clean async networking architecture

---


## 🛠 Technical Stack

### Framework & Language
- **Flutter**
- **Dart**

### Maps & Location Services
- Google Maps SDK
- Google Places API
- Geolocator
- Geocoding
- Flutter Polyline Points

### UI & Design
- Material Design
- Flutter Material Components



---

## 📱 App Flow

Splash Screen (3 seconds)
↓
Onboarding Screens
↓
Authentication
├── Login
└── Register
↓
Home Screen
├── Google Map
├── Route Selection
├── Trip Request
└── Vichele Search 

---

## 🧩 Project Structure

The project follows a clean and organized Flutter architecture:
- Screens
- Widgets
- Models
- Services
- Shared resources

This structure ensures maintainability, scalability, and easy future expansion.

---

## 📌 Summary

**Yaqood** demonstrates how Flutter can be used to build a modern ride-hailing style application featuring:

- Interactive maps  
- Real-time location handling  
- Route visualization  
- Ride simulation using HTTP polling  
- Clean architecture ready for backend integration  

A complete end-to-end mobile experience inspired by real-world ride-hailing apps.
---
