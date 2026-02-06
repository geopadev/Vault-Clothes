# Project Requirements

**Source**: `Team4C.pdf`
**Status**: Stable

## 1. Core User Capabilities

### 1.1 Discovery & Filtering

- **Filter Items**: Users must be able to filter listings by **Size** (XS-XXL, etc.), **Brand**, **Condition** (New-Acceptable), **Fit** (Slim-Baggy), **Price** (Range), **Material**, **Colour**, and **Style**.
- **Search**: Free text search for item titles and descriptions.
- **Browsing**: Main feed displaying active listings.

### 1.2 Seller Trust & Reputation

- **Public Profile**: Visible seller profile containing:
  - Aggregate Rating Score.
  - Text Reviews from buyers.
  - Account Age / Verification level.
  - Active and Past Listings.
- **Trust Indicators**: Logic to distinguish new sellers from established ones.

### 1.3 Listing Management

- **Create Listing**: Sellers can upload photos, set price, title, description, and condition.
- **Edit/Manage**: Sellers can modify active listings and update status (e.g., mark as Sold).
- **Visibility**: Listings must be categorized and searchable immediately after creation.

### 1.4 Buying & Transactions

- **Shopping Cart**: Users can add multiple items to a cart for purchase.
- **Order Tracking**: Buyers can view the status of orders (Processing, Shipped, Delivered).
- **History**: Users can view their full purchase and sales history.

### 1.5 Communication & Engagement

- **Direct Messaging**: Buyers and Sellers can chat directly regarding a specific listing.
- **Wishlist**: Users can save items for later.
- **Notifications**: Automated alerts for wishlist updates (Price Drop, Availability) and order status changes.

### 1.6 Authentication

- **Secure Access**: Email/Password registration and login.
- **Role Management**: All authenticated users can act as both Buyer and Seller.

## 2. Non-Functional Requirements (Constraints)

### 2.1 Performance

- **Search Latency**: Filtered results must load within **2 seconds** (95th percentile).
- **Messaging**: Messages delivered within **3 seconds**.
- **Uptime**: 99% availability target for core services.

### 2.2 Security & Compliance

- **Data Protection**: All sensitive queries and data transmission must be encrypted (HTTPS/TLS).
- **Privacy**: Compliance with GDPR (Data minimization, user right to deletion).
- **Access Control**: Strict authorization checks (e.g., User A cannot view User B’s private purchase history).

### 2.3 Usability

- **Accessibility**: Must meet **WCAG 2.1 AA** standards (ARIA labels, contrast, keyboard navigation).
- **Responsiveness**: UI must adapt consistently to mobile and web viewports.

## 3. Data Integrity

- **Validation**: All inputs (Price, Text) must be sanitized to prevent injection attacks.
- **Consistency**: Listings, Transactions, and Reviews must be stored in a consistent state (ACID properties where applicable).
