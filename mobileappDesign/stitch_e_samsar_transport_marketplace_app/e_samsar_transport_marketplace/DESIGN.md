---
name: E-Samsar Transport Marketplace
colors:
  surface: '#f7fafa'
  surface-dim: '#d7dadb'
  surface-bright: '#f7fafa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f4'
  surface-container: '#ebeeef'
  surface-container-high: '#e6e9e9'
  surface-container-highest: '#e0e3e3'
  on-surface: '#181c1d'
  on-surface-variant: '#3e494a'
  inverse-surface: '#2d3132'
  inverse-on-surface: '#eef1f2'
  outline: '#6f797a'
  outline-variant: '#bec8ca'
  surface-tint: '#006972'
  primary: '#00535b'
  on-primary: '#ffffff'
  primary-container: '#006d77'
  on-primary-container: '#9becf7'
  inverse-primary: '#82d3de'
  secondary: '#895100'
  on-secondary: '#ffffff'
  secondary-container: '#fd9d1a'
  on-secondary-container: '#663b00'
  tertiary: '#713d10'
  on-tertiary: '#ffffff'
  tertiary-container: '#8e5426'
  on-tertiary-container: '#ffd7bd'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9ff0fb'
  primary-fixed-dim: '#82d3de'
  on-primary-fixed: '#001f23'
  on-primary-fixed-variant: '#004f56'
  secondary-fixed: '#ffdcbc'
  secondary-fixed-dim: '#ffb86b'
  on-secondary-fixed: '#2c1700'
  on-secondary-fixed-variant: '#683d00'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#ffb783'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#6d390c'
  background: '#f7fafa'
  on-background: '#181c1d'
  surface-variant: '#e0e3e3'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  currency-display:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 1rem
  stack-gap: 0.75rem
  section-gap: 1.5rem
  card-inner-padding: 1rem
---

## Brand & Style
The design system for this Moroccan transport marketplace is built on the pillars of **reliability, efficiency, and premium service**. It balances a professional corporate identity with the dynamic energy of a logistics hub. 

The aesthetic follows a **Corporate Modern** style with a focus on high-legibility and functional clarity. It utilizes heavy whitespace to reduce cognitive load for users managing complex logistics, while employing subtle tactile elements to denote trust. The UI feels grounded and authoritative, yet accessible enough for both independent drivers and large-scale shippers.

## Colors
The palette is anchored by **Deep Teal**, signaling depth and professionalism, and **Warm Orange**, which serves as a high-visibility accent for calls-to-action and critical alerts.

**Status Palette:**
- **Pending (En attente):** Amber (#FFBF00) – signifies caution/waiting.
- **Notified (Chauffeurs notifiés):** Blue (#2196F3) – informational.
- **Assigned (Assignée):** Purple (#9C27B0) – distinctive milestone.
- **In Progress (En cours):** Deep Teal (#006D77) – aligns with primary brand action.
- **Completed (Terminée):** Green (#4CAF50) – success.
- **Canceled (Annulée):** Red (#F44336) – error/stoppage.
- **Accepted (Acceptée):** Light Green (#8BC34A) – positive confirmation.
- **Rejected (Refusée):** Gray (#9E9E9E) – neutral termination.

The background is a crisp **Off-white** (#F8F9FA) to ensure that pure white cards and colorful status indicators pop with maximum contrast.

## Typography
The system uses **Inter** for its neutral, highly legible, and systematic qualities. It is optimized for mobile screens where data density is high.

**Formatting Standards:**
- **Currency:** Amounts should be formatted as `1.200,00 MAD` with the currency code following the numerical value.
- **Dates:** Use French locale (DD/MM/YYYY), e.g., `14/03/2024`.
- **Labels:** Use `label-md` for status badges and section headers to provide clear visual categorization.

## Layout & Spacing
This is a **fluid-grid** system designed specifically for mobile devices. The layout relies on a consistent 16px (1rem) side margin for the primary container.

**Spacing Rhythm:**
- Elements within a card are separated by a **stack-gap** of 12px.
- Distinct functional sections on a screen are separated by a **section-gap** of 24px.
- Use horizontal scrolling "carousels" for quick-access categories (e.g., vehicle types) to maximize vertical screen real estate.

## Elevation & Depth
Depth is created using a **layered surface** approach. The base is the Off-white background, while interactive content sits on pure white cards.

**Shadows & Outlines:**
- **Cards:** Utilize a subtle 1px border (#E9ECEF) combined with a soft, diffused shadow (Y: 2px, Blur: 8px, Opacity: 4%, Color: #000). This ensures the card is distinct from the background even in bright sunlight.
- **Active State:** When a card is pressed, the shadow deepens slightly, and the border color shifts to the Primary Deep Teal.
- **Modals:** Use a heavy backdrop blur (20px) to maintain context while focusing the user on the task at hand.

## Shapes
The shape language is modern and professional, utilizing a **Rounded** (0.5rem / 8px base) logic, scaled up for larger components.

- **Standard Buttons/Inputs:** 12px corner radius.
- **Cards/Containers:** 16px corner radius to provide a friendly, "soft-tech" feel.
- **Status Chips:** Fully pill-shaped (999px) to distinguish them from interactive buttons.

## Components

**Buttons:**
- **Primary:** Deep Teal background, white text, 12px radius. High emphasis.
- **Secondary:** White background, Deep Teal border and text. Low emphasis.
- **WhatsApp Action:** Secondary Green (#25D366) with the WhatsApp icon, specifically used for driver-shipper communication.

**Cards:**
- Pure white background.
- Top-right corner reserved for the Status Chip.
- Bottom section often contains a "Price Tray" with the `currency-display` token.

**Input Fields:**
- 1px border (#DEE2E6), 12px radius.
- Leading icons for Location (Start/End points) and Calendar (Pickup Date).

**Status Chips:**
- Backgrounds use a 12% opacity version of the status color with 100% opacity text of the same color for high readability and "premium" aesthetic.

**Specialized Components:**
- **Route Tracker:** A vertical timeline component connecting "Pickup" and "Destination" with a dashed line.
- **AI Assistant Bubble:** A floating action button (FAB) using a gradient of Deep Teal to a slightly lighter shade, triggering the logistics AI.
- **Vehicle Selection:** Horizontal chips featuring stylized truck/van icons.