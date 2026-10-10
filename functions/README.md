# VitalMed Firebase Cloud Functions Backend

This directory houses the secure, trusted server-side functions for the VitalMed application.

## Functions Included

1. `onInventoryUpdated`
   - Triggered automatically on Firestore inventory document writes.
   - Computes:
     `Estimated Days Remaining = Current Available Stock / Average Daily Consumption`
   - Classifies risk levels (`NORMAL`, `WARNING`, `CRITICAL`, `OUT OF STOCK`).
   - Prevents duplicate alerts for already open conditions.
   - Automatically resolves existing alerts when stock returns to normal.
   - Dispatches FCM multicast push notifications to authorized pharmacy staff.

2. `completeRedistributionTransfer`
   - HTTPS Callable function that performs atomic cross-pharmacy stock adjustments.
   - Uses Firestore atomic transactions (`runTransaction`) to:
     - Verify source pharmacy surplus and non-negative stock invariants.
     - Decrement source pharmacy inventory.
     - Increment destination pharmacy inventory.
     - Create immutable audit logs in `stock_movements` for both parties.
     - Update transfer status to `COMPLETED`.

3. `notifySubscribedPatientsOnRestock`
   - Triggered when previously depleted medicine stock is restocked (> 0).
   - Finds matching active patient subscriptions in `patient_subscriptions`.
   - Sends real-time in-app notifications and FCM pushes to subscribed patients.

## Deployment & Setup

```bash
cd functions
npm install
firebase deploy --only functions
```
