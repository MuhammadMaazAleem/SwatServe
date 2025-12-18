# 🧪 Quick Testing Guide - Shopkeeper Product Visibility

## Test Scenario: "Shopkeeper adds product → Customer sees it"

### Step 1: Create Shopkeeper Account
```
1. Run the app: flutter run -d chrome
2. Click "Don't have an account? Sign Up"
3. Fill in:
   - Name: Test Shopkeeper
   - Email: shop1@test.com
   - Password: test123
   - Phone: 0333-1234567
   - Role: Shopkeeper
   - License: 12345
4. Click Sign Up
```

**Expected:** 
- ✅ Account created
- ✅ Shop automatically created with name "Test Shopkeeper's Shop"
- ✅ Redirected to Shopkeeper Dashboard

### Step 2: Customize Your Shop
```
1. On dashboard, click "My Shop" card
2. Edit shop details:
   - Name: Fresh Fruits & Veggies
   - Category: Fresh Produce
   - Description: We sell the freshest fruits and vegetables in Shamozai!
   - Phone: 0333-1234567
   - Address: Main Bazaar, Shamozai
   - Delivery Time: 20-30 min
   - Minimum Order: 200
   - Status: Toggle to OPEN
3. Click "Save Changes"
```

**Expected:**
- ✅ Success message shown
- ✅ Changes saved to Firestore
- ✅ Shop now visible to customers with updated info

### Step 3: Add Products
```
1. Click "Add Product" on dashboard
2. Fill in product details:
   - Name: Fresh Apples
   - Category: Fresh Produce
   - Price: 150
   - Stock: 50
   - Description: Crispy red apples from Swat Valley
   - Image URL: (leave empty for now)
   - Available: ✓ (checked)
3. Click "Save"
4. Repeat for more products (e.g., Bananas, Oranges)
```

**Expected:**
- ✅ Product added successfully
- ✅ Product saved with your shopId (vendorId)
- ✅ Product visible in "My Products"

### Step 4: Verify as Admin (Optional)
```
1. Logout from shopkeeper account
2. Login as admin:
   - Email: admin@swatserve.com
   - Password: admin123
3. Click "Manage Users"
4. Find "Test Shopkeeper" (role: shopkeeper)
5. Click "Verify" button
```

**Expected:**
- ✅ Shopkeeper status changed to "Verified"
- ✅ Shop now fully active

### Step 5: Test Customer View
```
1. Logout from admin
2. Create customer account or login as existing customer
3. On home screen, look for "Fresh Fruits & Veggies" shop
4. Click on the shop card
5. See list of products (Fresh Apples, etc.)
6. Add product to cart
7. Proceed to checkout
```

**Expected:**
- ✅ Shop visible in customer home screen
- ✅ Shop shows correct name, description, category
- ✅ Products are visible when you click the shop
- ✅ Products show price, stock, description
- ✅ Can add to cart and order

## 🔍 Troubleshooting

### Shop not visible to customers?
**Check:**
1. Is shop status set to "Open"? (Edit via "My Shop")
2. Is shopkeeper verified by admin? (Check in Admin → Manage Users)
3. Did you reload the customer home screen? (Pull to refresh)

### Products not showing in shop?
**Check:**
1. Are products marked as "Available"? (Toggle in My Products)
2. Is product's vendorId matching your shopId? (Check Firestore)
3. Is stock > 0? (Edit in My Products)

### Error when saving shop details?
**Check:**
1. Are all required fields filled? (marked with *)
2. Is minimum order a valid number?
3. Is phone number format correct?

### Firestore Errors?
**Check security rules in Firebase Console:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vendors/{vendorId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📊 What to Look For

### In Firebase Console (Firestore):

**vendors collection should have:**
```json
{
  "name": "Fresh Fruits & Veggies",
  "description": "We sell the freshest fruits...",
  "category": "Fresh Produce",
  "ownerId": "abc123...",
  "phone": "0333-1234567",
  "address": "Main Bazaar, Shamozai",
  "rating": 4.5,
  "deliveryTime": "20-30 min",
  "minimumOrder": 200,
  "isOpen": true,
  "isFeatured": false,
  "offers": [],
  "imageUrl": "",
  "totalReviews": 0,
  "createdAt": Timestamp
}
```

**products collection should have:**
```json
{
  "vendorId": "vendor_doc_id",  // matches shop ID
  "name": "Fresh Apples",
  "category": "Fresh Produce",
  "price": 150,
  "stock": 50,
  "description": "Crispy red apples...",
  "imageUrl": null,
  "isAvailable": true,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

## ✅ Success Indicators

You know it's working when:

1. **Shopkeeper Dashboard:**
   - ✅ All 4 cards are clickable
   - ✅ "My Shop" opens edit screen with your shop data
   - ✅ "My Products" shows your added products
   - ✅ "Add Product" form saves successfully

2. **Customer Home Screen:**
   - ✅ Shop cards appear in grid/list
   - ✅ Shop name, category, rating visible
   - ✅ Can search for shop by name
   - ✅ Can filter by category

3. **Customer Shop Detail:**
   - ✅ Shop header shows name and status (OPEN)
   - ✅ Products list is not empty
   - ✅ Product cards show name, price, stock
   - ✅ "Add to Cart" button works

4. **Orders:**
   - ✅ Customer can place order
   - ✅ Shopkeeper sees order in "Orders" screen
   - ✅ Can update order status
   - ✅ Customer sees updated status

## 🎯 Complete Test Flow

**Time: ~10 minutes**

1. ⏱️ Create shopkeeper (2 min)
2. ⏱️ Customize shop (2 min)
3. ⏱️ Add 3 products (3 min)
4. ⏱️ Switch to customer account (1 min)
5. ⏱️ Browse, add to cart, order (2 min)

**Result:** Full end-to-end workflow verified! 🎉

## 📸 What You Should See

### Shopkeeper Dashboard:
```
┌─────────────┬─────────────┐
│ My Products │ Add Product │
│     📦      │      ➕     │
└─────────────┴─────────────┘
┌─────────────┬─────────────┐
│   Orders    │   My Shop   │
│     📋      │      🏪     │
└─────────────┴─────────────┘
```

### Customer Home (with your shop):
```
🔍 Search restaurants, shops...
[All] [Food] [Fresh Produce] [...]

┌─────────────────────────────┐
│ 🏪 Fresh Fruits & Veggies   │
│ Fresh Produce          ⭐4.5│
│ ⏱️ 20-30 min  💰 Min Rs 200 │
└─────────────────────────────┘
```

### Shop Detail (your products):
```
Fresh Fruits & Veggies    [OPEN]
We sell the freshest fruits...

Products:
┌─────────────────────────────┐
│ 🍎 Fresh Apples             │
│ Crispy red apples...        │
│ Rs 150          Stock: 50   │
│               [Add to Cart] │
└─────────────────────────────┘
```

---

**Everything working? You're all set!** 🚀  
**Issues? Check troubleshooting section above.** 🔧
