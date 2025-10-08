# Payment Flow Diagram

## Complete Transaction Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          SENDER (User A)                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  1. Tap "Scan QR" Button                                                │
│     │                                                                     │
│     ├──> Camera Opens                                                   │
│     │                                                                     │
│     └──> Scan Recipient's QR Code                                       │
│                                                                           │
│  2. QR Data Parsed                                                      │
│     {                                                                    │
│       "type": "invoice",                                                │
│       "to": "device_xyz789",                                            │
│       "device_id": "device_xyz789"                                      │
│     }                                                                    │
│                                                                           │
│  3. Payment Screen Opens                                                │
│     ┌──────────────────────────────────┐                               │
│     │ Current Balance: $100.00         │                               │
│     │ [OFFLINE] Limit: $10.00          │                               │
│     │                                   │                               │
│     │ Amount: $ [____8.50____]         │                               │
│     │                                   │                               │
│     │ Quick: [$5] [$10]                │                               │
│     │                                   │                               │
│     │ [Confirm Payment]  [Cancel]      │                               │
│     └──────────────────────────────────┘                               │
│                                                                           │
│  4. Validation Checks                                                   │
│     ✓ $8.50 <= $10.00 (offline limit)                                  │
│     ✓ $8.50 <= $100.00 (balance)                                       │
│     ✓ Amount > 0                                                        │
│                                                                           │
│  5. Create Encrypted API Token                                         │
│     apiPayload = {                                                      │
│       device_token: "abc123...",                                        │
│       user_id: "user_1234567890",                                       │
│       amount: 8.50,                                                     │
│       recipient_id: "device_xyz789",                                    │
│       created_at: "2025-10-08T12:34:56Z",                              │
│       endpoint: "/update/abc123.../user_.../2025-..."                  │
│     }                                                                    │
│     │                                                                     │
│     └──> AES-GCM Encrypt → encryptedApiToken                           │
│                                                                           │
│  6. Create Payment Token                                               │
│     token = {                                                           │
│       tx_id: "tx_uuid_12345",                                          │
│       from: "device_abc123",                                            │
│       to: "device_xyz789",                                              │
│       amount: 850,  // cents                                            │
│       cipher: "encrypted_payload...",                                   │
│       sig: "ed25519_signature...",                                      │
│       metadata: {                                                       │
│         encrypted_api_token: "base64..."                                │
│       }                                                                  │
│     }                                                                    │
│                                                                           │
│  7. Deduct Balance Locally                                             │
│     $100.00 - $8.50 = $91.50                                           │
│     Save to SharedPreferences                                           │
│                                                                           │
│  8. Broadcast via BLE Mesh                                             │
│     ┌────────────────────────┐                                         │
│     │  BLE Advertisement     │                                         │
│     │  UUID: MeshPay         │                                         │
│     │  Data: token.toJson()  │                                         │
│     └────────────────────────┘                                         │
│               │                                                          │
│               └──────────────────┐                                      │
│                                   ↓                                      │
└─────────────────────────────────────────────────────────────────────────┘

                          ┌──────────────────┐
                          │   BLE MESH       │
                          │   NETWORK        │
                          │                  │
                          │  [Relay Devices] │
                          │  TTL: 10 → 9 → 8 │
                          └──────────────────┘
                                    ↓

┌─────────────────────────────────────────────────────────────────────────┐
│                          RECIPIENT (User B)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  9. BLE Scanner Receives Token                                          │
│     BLEService.bleEvents → TokenReceived                                │
│                                                                           │
│  10. Verify Token                                                       │
│      ✓ Ed25519 signature valid                                         │
│      ✓ Recipient matches device ID                                     │
│      ✓ TTL > 0                                                          │
│                                                                           │
│  11. Decrypt API Token from Metadata                                   │
│      encryptedApiToken = token.metadata['encrypted_api_token']          │
│      │                                                                   │
│      └──> AES-GCM Decrypt → apiPayload                                 │
│                                                                           │
│      apiPayload = {                                                     │
│        device_token: "abc123...",                                       │
│        user_id: "user_1234567890",                                      │
│        amount: 8.50,                                                    │
│        endpoint: "/update/abc123.../user_1234.../2025-..."             │
│      }                                                                   │
│                                                                           │
│  12. Process Payment                                                    │
│       Balance: $50.00 + $8.50 = $58.50                                 │
│       Save to SharedPreferences                                         │
│                                                                           │
│  13. Add to Transaction History                                        │
│       {                                                                  │
│         id: "tx_uuid_12345",                                            │
│         type: "credit",                                                 │
│         amount: 8.50,                                                   │
│         from: "device_abc123",                                          │
│         status: "confirmed",                                            │
│         timestamp: "2025-10-08T12:34:57Z"                               │
│       }                                                                  │
│                                                                           │
│  14. Show Notification                                                  │
│       ┌──────────────────────────────────┐                             │
│       │ ✓ Received $8.50!                │                             │
│       └──────────────────────────────────┘                             │
│                                                                           │
│  15. Play Sound Effect                                                  │
│       🔊 "assets/sounds/receive.mp3"                                    │
│                                                                           │
│  16. Update UI                                                          │
│       Balance Card: $58.50                                              │
│       Transaction List: + New entry                                     │
│                                                                           │
│  17. [OPTIONAL] Send to Backend                                        │
│       POST https://api.yourserver.com/update/abc.../user.../2025...    │
│       Body: apiPayload                                                  │
│       │                                                                  │
│       └──> Backend confirms → Status: "uploaded"                        │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘


## Offline vs Online Limits

┌────────────────────────────────────────────────────────────────┐
│                      OFFLINE MODE                               │
├────────────────────────────────────────────────────────────────┤
│  Status: No WiFi/Mobile Data                                   │
│  Limit: $10.00 per transaction                                 │
│  Use Case: Small retail, peer-to-peer payments                 │
│                                                                  │
│  ✓ Balance $100 → Can send up to $10                          │
│  ✓ Balance $5 → Can send up to $5                             │
│  ✗ Cannot send $15 (exceeds limit)                            │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                      ONLINE MODE                                │
├────────────────────────────────────────────────────────────────┤
│  Status: WiFi/Mobile Data Connected                            │
│  Limit: $1,000.00 per transaction                              │
│  Use Case: Larger purchases, bill payments                     │
│                                                                  │
│  ✓ Balance $100 → Can send up to $100 (balance limit)         │
│  ✓ Balance $500 → Can send up to $500 (balance limit)         │
│  ✓ Balance $1500 → Can send up to $1000 (transaction limit)   │
│  ✗ Cannot send $1001 (exceeds limit)                          │
└────────────────────────────────────────────────────────────────┘


## Security Flow

┌────────────────────────────────────────────────────────────────┐
│                    ENCRYPTION LAYERS                            │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: API Token Encryption                                 │
│  ┌──────────────────────────────────────────────────┐          │
│  │ Plain API Payload                                │          │
│  │   ↓ AES-GCM-256                                  │          │
│  │ Encrypted API Token                              │          │
│  │   ↓ Base64 Encode                                │          │
│  │ "YWJjMTIz..." → metadata.encrypted_api_token     │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
│  Layer 2: Payment Token Encryption                             │
│  ┌──────────────────────────────────────────────────┐          │
│  │ Transaction Details                              │          │
│  │   ↓ X25519 ECDH (Shared Secret)                 │          │
│  │   ↓ AES-GCM Encryption                           │          │
│  │ Encrypted Payload (cipher field)                │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
│  Layer 3: Digital Signature                                    │
│  ┌──────────────────────────────────────────────────┐          │
│  │ Token JSON                                       │          │
│  │   ↓ Ed25519 Sign                                 │          │
│  │ Signature (sig field)                            │          │
│  │   ↓ Verification on receive                      │          │
│  │ ✓ Valid / ✗ Invalid                              │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
│  Layer 4: Device Token Hashing                                 │
│  ┌──────────────────────────────────────────────────┐          │
│  │ Device Token (plaintext)                         │          │
│  │   ↓ SHA-256                                       │          │
│  │ Hashed Device Token                              │          │
│  │   ↓ Used in endpoints                            │          │
│  │ "/update/{hash}/..."                             │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
└────────────────────────────────────────────────────────────────┘


## Transaction States

START → PENDING → RELAYED → UPLOADED → CONFIRMED
  ↓                              ↓
 FAILED                        FAILED

PENDING:   Token created, balance deducted
RELAYED:   Token broadcasted via BLE
UPLOADED:  Token sent to gateway (if online)
CONFIRMED: Recipient received, backend verified
FAILED:    Error occurred, balance refunded

```

## Key Points

1. **Offline First**: Works without internet, syncs when online
2. **Encrypted End-to-End**: All sensitive data encrypted
3. **BLE Mesh**: Tokens relay through nearby devices
4. **Dual Limits**: Smart limits based on connectivity
5. **Local Storage**: Balance persists in SharedPreferences
6. **API Ready**: Backend integration structure in place
7. **Device Tokens**: Unique identifiers for mesh network
8. **Metadata Support**: Extensible for future features

## Production Checklist

- [ ] Replace demo encryption keys
- [ ] Implement actual backend API
- [ ] Add transaction syncing
- [ ] Enable gateway mode properly
- [ ] Add receipt generation
- [ ] Implement refunds
- [ ] Add transaction disputes
- [ ] Multi-currency support
- [ ] Biometric authentication
- [ ] Rate limiting
- [ ] Fraud detection
- [ ] Analytics integration
