# Doctor (Specialist) API Documentation

Complete reference of all API endpoints used by the Doctor/Specialist role in the SAHTECH web application.

---

## Authentication & Profile

### Get Profile

**Endpoint:** `GET /users/profile`

**When Used:** On app initialization and profile refresh

**Required Parameters:**

- Authorization header with Bearer token

**Response:**

```json
{
  "id": "user_id",
  "email": "doctor@example.com",
  "fullName": "Dr. Ahmed Mohamed",
  "phone": "555-1234",
  "gender": "MALE",
  "imageUrl": "https://...",
  "role": "DOCTOR",
  "specialist": {
    "speciality": "Physiotherapy",
    "clinic": "Health Center",
    "bio": "Expert in rehabilitation",
    "licenseNumber": "LIC123456",
    "isValidated": true,
    "location": "Tunis",
    "rating": 4.8,
    "reviewsCount": 45,
    "latitude": 33.8869,
    "longitude": 9.5375
  }
}
```

---

### Sign In

**Endpoint:** `POST /users/signin`

**When Used:** Doctor login

**Request Body:**

```json
{
  "email": "doctor@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    /* user details */
  }
}
```

---

### Verify OTP

**Endpoint:** `POST /users/signin/verify`

**When Used:** Two-factor authentication verification

**Request Body:**

```json
{
  "otp": "123456"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "verified": true
}
```

---

### Update Profile

**Endpoint:** `PATCH /users/update-user`

**When Used:** Doctor updates their profile information

**Request Body:**

```json
{
  "fullName": "Dr. Ahmed Mohamed",
  "email": "newemail@example.com",
  "phone": "+21698765432",
  "address": "123 Main St, Tunis",
  "speciality": "Kinésithérapie",
  "clinic": "Centre de Réadaptation",
  "bio": "Spécialiste en rééducation fonctionnelle",
  "location": "Tunis, Tunisia"
}
```

**Response:**

```json
{
  "message": "Profil enregistré avec succès",
  "user": {
    /* updated user */
  }
}
```

---

### Upload Profile Image

**Endpoint:** `POST /users/upload-image`

**When Used:** Doctor uploads or updates their profile picture

**Request:**

- Content-Type: multipart/form-data
- Field name: `file` (image file)

**Response:**

```json
{
  "message": "Photo de profil mise à jour avec succès",
  "imageUrl": "https://minio.example.com/doctor-profile-123.jpg"
}
```

---

### Change Password

**Endpoint:** `PATCH /users/change-password`

**When Used:** Doctor changes their password

**Request Body:**

```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newPassword456"
}
```

**Response:**

```json
{
  "message": "Mot de passe modifié avec succès"
}
```

---

### Update Security Settings (2FA)

**Endpoint:** `PATCH /users/update-otp`

**When Used:** Doctor toggles 2FA/MFA settings

**Request Body:** (empty)

**Response:**

```json
{
  "message": "Paramètres de sécurité mis à jour",
  "security": "MFA" | "SFA"
}
```

---

## Dashboard

### Get Dashboard Statistics

**Endpoint:** `GET /doctors/get-forms`

**When Used:** Doctor loads the dashboard

**Response:**

```json
{
  "patientsCount": 12,
  "appointmentsCount": 5,
  "pendingReports": 0,
  "unreadedcount": 3,
  "upcomingRDVs": [
    {
      "id": 1,
      "patientName": "Mohamed Cherif",
      "date": "2026-05-10",
      "startTime": "10:00"
    }
  ]
}
```

---

## Patients Management

### Get All Assigned Patients

**Endpoint:** `GET /doctors/get-patients`

**When Used:**

- Patient list page loads
- Patient detail page needs patient lookup
- Session detail page needs patient info

**Response:**

```json
{
  "patients": [
    {
      "userId": 1,
      "fullName": "Mohamed Cherif",
      "email": "m.cherif@gmail.com",
      "phone": "+21698765432",
      "gender": "MALE",
      "patient": {
        "age": 35,
        "medicalHistory": [
          {
            "title": "Hernie discale L4-L5",
            "category": "pdf",
            "fileUrl": "https://..."
          }
        ],
        "appointments": [
          {
            "reason": "Physiotherapy session",
            "AvailableSlot": {
              "date": "2026-05-08",
              "startTime": "2026-05-08T10:00:00"
            }
          }
        ],
        "height": 180,
        "weight": 75
      }
    }
  ],
  "count": 12
}
```

---

### Get Patient Sessions

**Endpoint:** `GET /doctors/patients/{patientId}/sessions`

**When Used:** Doctor views patient's medical history/sessions

**URL Parameters:**

- `patientId`: Numeric ID of the patient

**Response:**

```json
{
  "sessions": [
    {
      "sessionId": 1,
      "sessionDate": "2026-05-01",
      "notes": "Session de suivi",
      "examenClinique": {
        /* clinical exam data */
      },
      "diagnostic": {
        /* diagnosis data */
      },
      "physiotherapie": {
        /* physiotherapy data */
      },
      "conduiteATenir": {
        /* treatment plan */
      },
      "examenComplementaire": [
        /* complementary exams */
      ]
    }
  ]
}
```

---

## Medical Sessions

### Get Session Details

**Endpoint:** `GET /doctors/sessions/{sessionId}`

**When Used:** Doctor opens a session to edit/review

**URL Parameters:**

- `sessionId`: Numeric ID of the session

**Response:**

```json
{
  "sessionId": 1,
  "sessionDate": "2026-05-01",
  "examenClinique": {
    "plainte": "Lower back pain",
    "intensiteEVA": 6,
    "historique": "Started 2 weeks ago"
  },
  "diagnostic": {
    "diagnosticType": "SIMPLE",
    "severity": "MODERATE",
    "description": "Lumbar disc herniation"
  },
  "physiotherapie": {
    "bilan": {
      /* assessment data */
    },
    "protocole": {
      /* protocol data */
    },
    "resultat": {
      /* results data */
    }
  },
  "conduiteATenir": {
    "medicamenteux": "Ibuprofen 400mg",
    "infiltration": true,
    "infiltrationDetail": "Cortisone injection"
  },
  "examenComplementaire": [
    /* complementary exams */
  ]
}
```

---

### Create New Session

**Endpoint:** `POST /doctors/patients/{patientId}/sessions`

**When Used:** Doctor creates a new medical session for a patient

**URL Parameters:**

- `patientId`: Numeric ID of the patient

**Request Body:**

```json
{
  "sessionDate": "2026-05-06",
  "notes": "Initial assessment"
}
```

**Response:**

```json
{
  "sessionId": 123,
  "id": 123,
  "sessionDate": "2026-05-06",
  "notes": "Initial assessment",
  "message": "Session créée avec succès"
}
```

---

### Save Clinical Exam (Examen Clinique)

**Endpoint:** `POST /doctors/sessions/{sessionId}/examen-clinique`

**Request Body:**

```json
{
  "plainte": "Lower back pain",
  "historique": "Started 2 weeks ago",
  "intensiteEVA": 6,
  "constantScore": "{...}",
  "quickDashScore": "{...}",
  "dashArabeScore": "{...}",
  "antepulsionActive": 120,
  "antepulsionPassive": 140,
  "abductionActive": 80,
  "abductionPassive": 90,
  "retractionActive": 40,
  "retractionPassive": 45,
  "rotationExterneActive": 60,
  "rotationExternePassive": 75,
  "rotationInterneActive": 50,
  "rotationInternePassive": 65,
  "deltoideTesting": 5,
  "susEpineuxTesting": 4,
  "infraEpineuxTesting": 4,
  "subScapulaireTesting": 5,
  "testJobe": "Positive",
  "testPatte": "Negative",
  "testGerber": "Negative",
  "testNeer": "Positive",
  "testHawkins": "Positive",
  "mainBouche": 50,
  "mainTete": 60,
  "mainNuque": 45,
  "mainDos": 40,
  "observations": "Additional notes"
}
```

---

### Save Complementary Exam (Examen Complémentaire)

**Endpoint:** `POST /doctors/sessions/{sessionId}/examen-complementaire`

**Request Body:**

```json
{
  "examType": "IRM",
  "result": "Herniated disc at L4-L5",
  "fileUrl": "https://..."
}
```

---

### Delete Complementary Exam

**Endpoint:** `DELETE /doctors/examen-complementaire/{examId}`

**When Used:** Doctor removes a complementary exam from a session

---

### Save Diagnosis (Diagnostic)

**Endpoint:** `POST /doctors/sessions/{sessionId}/diagnostic`

**Request Body:**

```json
{
  "diagnosticType": "SIMPLE | HYPERALGESIC | PSEUDO_PARALYTIC | FROZEN",
  "severity": "MILD | MODERATE | SEVERE",
  "description": "Detailed diagnosis description",
  "observations": "Additional observations"
}
```

---

### Save Treatment Plan (Conduite à Tenir)

**Endpoint:** `POST /doctors/sessions/{sessionId}/conduite-a-tenir`

**Request Body:**

```json
{
  "medicamenteux": "Ibuprofen 400mg, 3x daily",
  "infiltration": true,
  "infiltrationDetail": "Cortisone injection to joint",
  "prochainRDV": "2026-05-13"
}
```

---

### Save Physiotherapy - Assessment (Bilan)

**Endpoint:** `POST /doctors/sessions/{sessionId}/physiotherapie/bilan`

**Request Body:**

```json
{
  "plainte": "Limited shoulder mobility",
  "historique": "Post-surgical rehabilitation",
  "intensiteEVA": 4,
  "constantScore": "{\"score\": 65}",
  "quickDashScore": "{\"score\": 45}",
  "dashArabeScore": "{\"score\": 48}",
  "antepulsionActive": 120,
  "antepulsionPassive": 140,
  "abductionActive": 80,
  "abductionPassive": 90,
  "deltoideTesting": 4,
  "testJobe": "Positive",
  "observations": "Good progress observed"
}
```

---

### Save Physiotherapy - Protocol (Protocole)

**Endpoint:** `POST /doctors/sessions/{sessionId}/physiotherapie/protocole`

**Request Body:**

```json
{
  "objectifsCourt": "Improve shoulder flexion to 160°",
  "objectifsLong": "Full functional recovery",
  "physiotherapieAntalgique": true,
  "typesPhysio": ["Heat therapy", "Manual therapy"],
  "massage": true,
  "balnéotherapie": false,
  "mobilisationsPassives": true,
  "mobilisationsActives": true,
  "renforcement": true,
  "proprioception": false,
  "exercicesDetail": "Daily 30-minute sessions",
  "seancesParSemaine": 3,
  "dureeSemaines": 8,
  "orthese": true,
  "typeOrthese": "Shoulder sling"
}
```

---

### Save Physiotherapy - Results (Résultat)

**Endpoint:** `POST /doctors/sessions/{sessionId}/physiotherapie/resultat`

**Request Body:**

```json
{
  "constantScoreFinal": "{\"score\": 80}",
  "quickDashScoreFinal": "{\"score\": 35}",
  "evaFinale": 2,
  "evolutionDouleur": "Significant improvement",
  "evolutionMobilite": "120° to 160°",
  "evolutionForce": "Good muscle strength recovery",
  "evolutionFonction": "Patient can perform ADLs",
  "antepulsionFinal": 160,
  "abductionFinal": 90,
  "rotationExterneFinal": 75,
  "rotationInterneFinal": 65,
  "objectifsAtteints": true,
  "conclusionKine": "Protocol successfully completed",
  "suitesDonnees": "Maintenance program recommended"
}
```

---

## Planning & Appointments

### Get Available Slots

**Endpoint:** `GET /doctors/daily-slots`

**When Used:** Doctor views their availability schedule

**Response:**

```json
{
  "data": [
    {
      "availabilityId": 1,
      "date": "2026-05-10",
      "startTime": "2026-05-10T08:00:00",
      "endTime": "2026-05-10T09:00:00",
      "isBooked": false,
      "place": "Clinic Room 1"
    }
  ]
}
```

---

### Create Availability Slot

**Endpoint:** `POST /doctors/daily-slots`

**When Used:** Doctor adds new availability

**Request Body:**

```json
{
  "date": "2026-05-10",
  "startTime": 8,
  "endTime": 17,
  "place": "Clinic Room 1"
}
```

**Response:**

```json
{
  "message": "Creneaux ajoutes avec succes",
  "data": {
    "availabilityId": 1,
    "date": "2026-05-10",
    "startTime": "2026-05-10T08:00:00",
    "endTime": "2026-05-10T17:00:00"
  }
}
```

---

### Update Availability Slot

**Endpoint:** `PATCH /doctors/daily-slots/{slotId}`

**When Used:** Doctor modifies an availability slot

**Request Body:**

```json
{
  "date": "2026-05-10",
  "startTime": 9,
  "endTime": 16,
  "place": "Clinic Room 2",
  "isBooked": false
}
```

**Response:**

```json
{
  "message": "Creneau mis a jour avec succes"
}
```

---

### Delete Availability Slot

**Endpoint:** `DELETE /doctors/daily-slots/{slotId}`

**When Used:** Doctor removes an availability slot

**Response:**

```json
{
  "message": "Creneau supprime avec succes"
}
```

---

### Get Appointments

**Endpoint:** `GET /doctors/appointments`

**When Used:** Doctor views appointment requests

**Response:**

```json
{
  "data": [
    {
      "appointmentId": 1,
      "status": "SCHEDULED | ACEPTED | REJECTED | COMPLETED | CANCELLED",
      "reason": "Regular physiotherapy session",
      "patientName": "Mohamed Cherif",
      "patientImage": "https://...",
      "date": "2026-05-08",
      "startTime": "2026-05-08T10:00:00",
      "endTime": "2026-05-08T11:00:00",
      "place": "Clinic Room 1"
    }
  ]
}
```

---

### Update Appointment Status

**Endpoint:** `PATCH /doctors/appointments/{appointmentId}`

**When Used:** Doctor accepts, rejects, or updates an appointment

**Request Body:**

```json
{
  "appointmentId": 1,
  "status": "ACEPTED | REJECTED | COMPLETED | CANCELLED"
}
```

**Response:**

```json
{
  "message": "Rendez-vous mis a jour",
  "appointment": {
    /* updated appointment */
  }
}
```

---

## Chat & Messaging

### Get Unread Message Count

**Endpoint:** `GET /chat/unread`

**When Used:** Check for new messages

**Response:**

```json
{
  "count": 3
}
```

---

### Get Conversations

**Endpoint:** `GET /chat/conversations`

**When Used:** Load all chat conversations

**Response:**

```json
{
  "data": [
    {
      "conversationId": 1,
      "patientId": 1,
      "specialistId": 5,
      "patient": {
        "user": {
          "fullName": "Mohamed Cherif",
          "imageUrl": "https://..."
        }
      },
      "messages": [
        {
          "messageId": 100,
          "content": "Hello doctor",
          "senderId": 1,
          "createdAt": "2026-05-06T10:30:00",
          "isRead": true
        }
      ]
    }
  ]
}
```

---

### Get Conversation Messages

**Endpoint:** `GET /chat/conversations/{conversationId}/messages`

**When Used:** Load messages in a specific conversation

**Response:**

```json
[
  {
    "messageId": 1,
    "conversationId": 1,
    "senderId": 1,
    "content": "Hello, I have some questions about my therapy",
    "sender": {
      "fullName": "Mohamed Cherif",
      "imageUrl": "https://..."
    },
    "createdAt": "2026-05-06T10:00:00",
    "isRead": true
  }
]
```

---

### Send Message

**Endpoint:** `POST /chat/messages`

**When Used:** Doctor sends a message to patient

**Request Body:**

```json
{
  "conversationId": 1,
  "content": "Your session went well today"
}
```

**Response:**

```json
{
  "messageId": 101,
  "conversationId": 1,
  "senderId": 5,
  "content": "Your session went well today",
  "createdAt": "2026-05-06T14:30:00"
}
```

---

### Mark Messages as Read (WebSocket Event)

**Event:** `mark_read`

**When Used:** Automatically when doctor opens a conversation

**Payload:**

```json
{
  "conversationId": 1
}
```

---

## Posts & Content

### Get My Posts

**Endpoint:** `GET /doctors/my_posts`

**When Used:** Doctor loads their published content

**Response:**

```json
{
  "posts": [
    {
      "postId": 1,
      "title": "5 Tips for Lower Back Relief",
      "description": "Effective techniques for managing chronic pain",
      "type": "ARTICLE | IMAGE | VIDEO",
      "url": "https://...",
      "isPublished": true,
      "createdAt": "2026-05-01T09:00:00"
    }
  ]
}
```

---

### Create Post

**Endpoint:** `POST /doctors/my_posts`

**When Used:** Doctor publishes new content

**Request:**

- Content-Type: multipart/form-data
- Fields:
  - `title`: Post title (string, required)
  - `description`: Post content (string, required)
  - `type`: "ARTICLE" | "IMAGE" | "VIDEO" (string, required)
  - `file`: Media file (file, optional)

**Response:**

```json
{
  "postId": 2,
  "message": "Publication créée avec succès",
  "post": {
    "title": "New Post",
    "description": "Description",
    "type": "ARTICLE",
    "url": "https://...",
    "createdAt": "2026-05-06T15:00:00"
  }
}
```

---

### Delete Post

**Endpoint:** `DELETE /doctors/my_posts/{postId}`

**When Used:** Doctor removes one of their posts

**Response:**

```json
{
  "message": "Publication supprimée avec succès"
}
```

---

## Feed

### Get All Posts (Feed)

**Endpoint:** `GET /users/posts`

**When Used:** Doctor views the public feed/accueil page

**Response:**

```json
[
  {
    "postId": 1,
    "title": "Physical Therapy Best Practices",
    "description": "Important tips from our expert therapists",
    "type": "ARTICLE",
    "url": "https://...",
    "specialist": {
      "user": {
        "fullName": "Dr. Amira Benali",
        "imageUrl": "https://..."
      }
    },
    "createdAt": "2026-05-05T10:00:00"
  }
]
```

---

## Search & Discovery

### Search Specialists

**Endpoint:** `GET /users/specialists/{searchQuery}`

**When Used:** Doctor searches for other specialists

**URL Parameters:**

- `searchQuery`: Search term (name, specialty, etc.)

**Response:**

```json
{
  "data": [
    {
      "userId": 2,
      "user": {
        "fullName": "Dr. Karim Meziane",
        "imageUrl": "https://..."
      },
      "speciality": "Cardiology",
      "latitude": 33.8869,
      "longitude": 9.5375,
      "rating": 4.5
    }
  ]
}
```

---

### Get Specialist Details

**Endpoint:** `GET /users/specialist/{specialistId}`

**When Used:** Doctor views another specialist's profile

**URL Parameters:**

- `specialistId`: Numeric ID of the specialist

**Response:**

```json
{
  "data": {
    "userId": 2,
    "user": {
      "fullName": "Dr. Karim Meziane",
      "email": "karim@example.com",
      "phone": "+21698765432",
      "gender": "MALE",
      "imageUrl": "https://..."
    },
    "speciality": "Cardiology",
    "bio": "Experienced cardiologist with 15 years practice",
    "clinic": "Heart Care Center",
    "location": "Tunis, Tunisia",
    "rating": 4.5,
    "reviewsCount": 120,
    "licenseNumber": "LIC789456",
    "latitude": 33.8869,
    "longitude": 9.5375
  }
}
```

---

## Error Responses

All endpoints may return error responses with the following format:

```json
{
  "statusCode": 400 | 401 | 403 | 404 | 500,
  "message": "Error description",
  "error": "Error type"
}
```

### Common Status Codes:

- **200**: Success
- **201**: Created
- **400**: Bad Request (invalid data)
- **401**: Unauthorized (missing/invalid token)
- **403**: Forbidden (no permission)
- **404**: Not Found
- **500**: Server Error

---

## Authentication

All endpoints (except sign in, sign up, and verify OTP) require:

**Header:**

```
Authorization: Bearer <accessToken>
```

---

## WebSocket Events (Chat)

Doctor receives real-time updates via Socket.IO:

### Connect

```javascript
socket.on("connect", () => {
  // Connected to chat server
});
```

### New Message

```javascript
socket.on("new_message", (message) => {
  // {
  //   messageId, conversationId, senderId, content,
  //   sender: { fullName, imageUrl },
  //   createdAt, isRead
  // }
});
```

### Messages Read Notification

```javascript
socket.on("messages_read", ({ conversationId }) => {
  // Notification that messages in conversation were read
});
```

### Notification

```javascript
socket.on("notification", (notification) => {
  // {
  //   conversationId, senderName, preview
  // }
});
```

---

## Notes

- All dates are in ISO 8601 format: `YYYY-MM-DDTHH:mm:ss` or `YYYY-MM-DD`
- All numeric IDs are integers
- File uploads use multipart/form-data
- Authentication tokens expire and require refresh (implement refresh token flow)
- WebSocket connections require authentication header and Bearer token
- Some responses use nested pagination (e.g., responses wrapped in `data` field)

---

**Last Updated:** May 6, 2026
**API Version:** 1.0
