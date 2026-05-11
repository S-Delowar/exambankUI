# ExamBank Backend Architecture Analysis

## Overview

**Technology Stack:**
- **Framework:** FastAPI 0.115+
- **Database:** PostgreSQL with AsyncPG
- **ORM:** SQLAlchemy 2.0 (async)
- **Authentication:** JWT (access + refresh tokens)
- **AI/ML:** Google Gemini API (question extraction, solution generation)
- **Image Processing:** OpenCV, PyMuPDF, Pillow
- **Migrations:** Alembic

**Project Stats:**
- **Total Files:** 194
- **Lines of Code:** ~13,000
- **API Endpoints:** 40+
- **Database Models:** 9 core models
- **Services:** 10 service modules

---

## Directory Structure

```
backend/
├── app/                          # Main application package
│   ├── routers/                  # API endpoints (14 routers)
│   ├── services/                 # Business logic (10 services)
│   ├── models/                   # SQLAlchemy models (9 models)
│   ├── schemas/                  # Pydantic schemas (extraction + API)
│   ├── extractors/               # PDF extraction pipeline
│   ├── prompts/                  # Gemini prompts (hybrid approach)
│   ├── db_storage/               # Database persistence layer
│   ├── solution_worker/          # Background solution generation
│   ├── main.py                   # FastAPI app initialization
│   ├── config.py                 # Configuration management
│   ├── database.py               # Database session management
│   ├── deps.py                   # Dependency injection
│   ├── security.py               # Auth utilities
│   └── ...                       # Other utilities
├── scripts/                      # CLI utilities
│   ├── crop_figures_batch.py    # Batch image cropping
│   ├── describe_with_gemini.py  # Image description
│   ├── redraw_with_gemini.py    # SVG redrawing
│   └── ...
├── data/                         # Data storage
│   ├── images/                   # Served images
│   ├── results/                  # Extraction JSON outputs
│   └── cropped_images/           # Manual crops
├── alembic/                      # Database migrations
│   └── versions/                 # Migration scripts (11 migrations)
├── test/                         # Test files
├── config.yaml                   # Configuration overrides
├── chapters.yaml                 # Chapter taxonomy
├── chapters_bn.yaml              # Bangla chapter labels
└── requirements.txt              # Python dependencies
```

---

## API Architecture

### **Base URL:** `http://localhost:8000`

### **API Endpoints (40+)**

#### **1. Authentication & User Management** (`/auth`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/signup` | Create new user account | Public |
| POST | `/login` | Login with email/password | Public |
| POST | `/refresh` | Refresh access token | Refresh token |
| GET | `/me` | Get current user profile | Access token |
| POST | `/logout` | Revoke refresh token | Access token |

**Features:**
- JWT-based authentication (access + refresh tokens)
- Argon2 password hashing
- Email validation
- Display name support

---

#### **2. Question Extraction** (`/extract`, `/crop-images`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/extract` | Extract questions from PDF | Admin |
| POST | `/crop-images` | Crop images from annotated PDF | Admin |
| GET | `/jobs/{job_id}` | Check extraction job status | Admin |
| GET | `/jobs/{job_id}/result` | Download extraction JSON | Admin |

**Extraction Parameters:**
- `exam_type`: `admission_test` | `hsc_board`
- `question_type`: `mcq` | `written`
- `subjects`: Comma-separated (e.g., `physics,chemistry`)
- `subject_paper`: `1` | `2` (for HSC paper-split subjects)

**Supported Combinations:**
1. Admission Test MCQ (multi-subject)
2. Admission Test Written (multi-subject)
3. HSC Board MCQ (single/multi-subject, paper-specific)
4. HSC Board Written (single/multi-subject, paper-specific)

**Extraction Pipeline:**
1. PDF → Images (200 DPI)
2. Page-by-page Gemini extraction
3. Metadata latching & backfilling
4. Image linking (manual crops or Pass 2)
5. JSON save + DB persistence
6. Job completion

---

#### **3. Exam Papers** (`/exams`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/exams` | List all exam papers | Public |
| GET | `/exams/{paper_id}` | Get paper details + questions | Public |
| GET | `/exams/{paper_id}/source.pdf` | Download source PDF | Public |
| GET | `/exams/{paper_id}/images/{filename}` | Get question image | Public |

**Paper Metadata:**
- Exam type, question type
- Board/university, year/session
- Subject, paper number
- Question counts, mismatch counts
- Extraction status

---

#### **4. Questions** (`/questions`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/questions` | List questions (filtered) | Public |
| GET | `/questions/{question_id}` | Get single question | Public |

**Query Parameters:**
- `exam_type`, `question_type`
- `subject`, `chapter`
- `board_name`, `exam_year` (HSC)
- `university_name`, `exam_session` (Admission)
- `limit`, `offset` (pagination)

**Response Variants:**
- `AdmissionMcqQuestionOut`
- `AdmissionWrittenQuestionOut`
- `HscMcqQuestionOut`
- `HscWrittenQuestionOut`

---

#### **5. Drill Mode** (`/drill`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/drill` | Get random questions for practice | User |

**Parameters:**
- `exam_type`, `question_type`
- `subjects[]`: Array of subjects
- `chapters[]`: Array of chapters
- `count`: Number of questions (default: 10)

**Features:**
- Random sampling from filtered questions
- Subject/chapter filtering
- Supports multi-subject drills

---

#### **6. Bookmarks** (`/bookmarks`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/bookmarks` | List user's bookmarks | User |
| POST | `/bookmarks` | Add bookmark | User |
| DELETE | `/bookmarks/{question_id}` | Remove bookmark | User |

---

#### **7. Attempts (Quiz/Exam)** (`/attempts`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/attempts` | Start new attempt | User |
| POST | `/attempts/{attempt_id}/answer` | Record answer | User |
| POST | `/attempts/{attempt_id}/submit` | Submit attempt | User |
| GET | `/attempts` | List user's attempts | User |
| GET | `/attempts/{attempt_id}` | Get attempt details | User |
| GET | `/attempts/{attempt_id}/questions` | Get attempt questions | User |
| GET | `/attempts/{attempt_id}/review` | Get attempt review | User |
| GET | `/attempts/{attempt_id}/pdf` | Download attempt PDF | User |

**Attempt Types:**
- **Drill:** Random practice questions
- **Subject Quiz:** Subject-specific quiz
- **Paper Quiz:** Full paper attempt

**Features:**
- Timed attempts
- Answer recording
- Auto-grading (MCQ)
- Review with solutions
- PDF export

---

#### **8. Progress & Stats** (`/progress`, `/stats`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/progress/summary` | Get user progress summary | User |
| GET | `/stats/subjects` | Get quiz statistics | User |

**Progress Metrics:**
- Total attempts, questions answered
- Correct/incorrect counts
- Subject-wise breakdown
- Chapter-wise breakdown
- Current streak

---

#### **9. Taxonomy** (`/taxonomy`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/taxonomy/chapters` | Get chapter taxonomy | Public |

**Response:**
- Nested taxonomy by subject/paper
- Bangla labels
- Chapter keys

---

#### **10. Review (Admin)** (`/review`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/review/taxonomy/chapters` | Get chapter taxonomy | Admin |
| PATCH | `/review/questions/{question_id}` | Update question | Admin |
| DELETE | `/review/questions/{question_id}` | Delete question | Admin |
| PATCH | `/review/options/{option_id}` | Update option | Admin |
| DELETE | `/review/options/{option_id}` | Delete option | Admin |
| POST | `/review/questions/{question_id}/options` | Add option | Admin |
| PATCH | `/review/subparts/{subpart_id}` | Update subpart | Admin |
| PUT | `/review/questions/{question_id}/images/{image_id}` | Replace image | Admin |
| DELETE | `/review/questions/{question_id}/images/{image_id}` | Delete image | Admin |

**Features:**
- Partial updates (PATCH)
- Field validation
- Image management
- Option management (MCQ)
- Subpart management (Written)

---

#### **11. Admin - Quizzes** (`/admin/quizzes`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/admin/quizzes` | List all quizzes | Admin |
| PUT | `/admin/quizzes/{quiz_id}/status` | Update quiz status | Admin |
| GET | `/admin/quizzes/{quiz_id}/attempts` | Get quiz attempts roster | Admin |

**Quiz Status:**
- `draft`: Not visible to students
- `published`: Available for attempts
- `archived`: Read-only

---

#### **12. Admin - Attempts** (`/admin/attempts`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/admin/attempts/{attempt_id}` | Get attempt details | Admin |
| GET | `/admin/attempts/{attempt_id}/review` | Get attempt review | Admin |

---

## Database Models

### **Core Models (9)**

#### **1. User** (`users` table)
```python
- id: UUID (PK)
- email: String (unique, indexed)
- display_name: String
- password_hash: String
- is_admin: Boolean
- created_at: DateTime
```

**Relationships:**
- `refresh_tokens` → RefreshToken
- `bookmarks` → Bookmark
- `attempts` → Attempt

---

#### **2. RefreshToken** (`refresh_tokens` table)
```python
- id: UUID (PK)
- user_id: UUID (FK → users)
- token_hash: String (indexed)
- expires_at: DateTime
- created_at: DateTime
```

---

#### **3. ExamPaper** (`exam_papers` table)
```python
- id: UUID (PK)
- exam_type: Enum (admission_test, hsc_board)
- question_type: Enum (mcq, written)
- source_filename: String
- source_pdf_path: String
- extraction_status: String
- created_at: DateTime

# Admission-specific
- university_name: String
- exam_session: String
- exam_unit: String

# HSC-specific
- board_name: String
- exam_year: String
```

**Relationships:**
- `admission_mcq_questions` → AdmissionMcqQuestion
- `admission_written_questions` → AdmissionWrittenQuestion
- `hsc_mcq_questions` → HscMcqQuestion
- `hsc_written_questions` → HscWrittenQuestion

---

#### **4. AdmissionMcqQuestion** (`admission_mcq_questions` table)
```python
- id: UUID (PK)
- paper_id: UUID (FK → exam_papers)
- question_number: String
- question_text: Text
- university_name: String
- exam_session: String
- exam_unit: String
- subject: String
- chapter: String
- correct_answer: String
- solution: Text
- solution_status: String
- has_image: Boolean
- images: JSONB
- gemini_solution: Text
- gemini_correct_answer: String
```

**Relationships:**
- `options` → AdmissionMcqOption
- `bookmarks` → Bookmark
- `answers` → AttemptAnswer

---

#### **5. AdmissionMcqOption** (`admission_mcq_options` table)
```python
- id: UUID (PK)
- question_id: UUID (FK → admission_mcq_questions)
- label: String
- text: Text
- image_filename: String
- display_order: Integer
```

---

#### **6. AdmissionWrittenQuestion** (`admission_written_questions` table)
```python
- id: UUID (PK)
- paper_id: UUID (FK → exam_papers)
- question_number: String
- question_text: Text
- university_name: String
- exam_session: String
- exam_unit: String
- subject: String
- chapter: String
- solution: Text
- solution_status: String
- has_image: Boolean
- images: JSONB
- gemini_solution: Text
```

---

#### **7. HscMcqQuestion** (`hsc_mcq_questions` table)
```python
- id: UUID (PK)
- paper_id: UUID (FK → exam_papers)
- question_number: String
- question_text: Text
- board_name: String
- exam_year: String
- subject: String
- subject_paper: String (1 or 2)
- chapter: String
- correct_answer: String
- solution: Text
- solution_status: String
- has_image: Boolean
- images: JSONB
- gemini_solution: Text
- gemini_correct_answer: String
```

**Relationships:**
- `options` → HscMcqOption

---

#### **8. HscWrittenQuestion** (`hsc_written_questions` table)
```python
- id: UUID (PK)
- paper_id: UUID (FK → exam_papers)
- question_number: String
- uddipak_text: Text
- uddipak_has_image: Boolean
- board_name: String
- exam_year: String
- subject: String
- subject_paper: String
- images: JSONB
```

**Relationships:**
- `sub_parts` → HscWrittenSubpart

---

#### **9. HscWrittenSubpart** (`hsc_written_subparts` table)
```python
- id: UUID (PK)
- question_id: UUID (FK → hsc_written_questions)
- label: String (a, b, c, d)
- marks: Integer (1, 2, 3, 4)
- text: Text
- solution: Text
- solution_status: String
- has_image: Boolean
- display_order: Integer
- gemini_solution: Text
```

---

#### **10. Bookmark** (`bookmarks` table)
```python
- id: UUID (PK)
- user_id: UUID (FK → users)
- question_id: UUID (polymorphic)
- question_type: String
- created_at: DateTime
```

---

#### **11. Attempt** (`attempts` table)
```python
- id: UUID (PK)
- user_id: UUID (FK → users)
- exam_type: String
- question_type: String
- attempt_type: String (drill, subject_quiz, paper_quiz)
- quiz_id: UUID (optional)
- started_at: DateTime
- submitted_at: DateTime
- time_limit_minutes: Integer
- question_ids: JSONB
- score: Integer
- total_questions: Integer
```

**Relationships:**
- `answers` → AttemptAnswer

---

#### **12. AttemptAnswer** (`attempt_answers` table)
```python
- id: UUID (PK)
- attempt_id: UUID (FK → attempts)
- question_id: UUID (polymorphic)
- question_type: String
- selected_answer: String
- is_correct: Boolean
- answered_at: DateTime
```

---

#### **13. QuizStatus** (`quiz_statuses` table)
```python
- id: UUID (PK)
- paper_id: UUID (FK → exam_papers)
- status: Enum (draft, published, archived)
- published_at: DateTime
- archived_at: DateTime
```

---

## Service Layer

### **Services (10 modules)**

#### **1. auth_service.py**
- User signup, login
- Token generation (access + refresh)
- Token rotation
- Password hashing/verification

#### **2. questions_service.py**
- List questions (filtered, paginated)
- Get single question
- Polymorphic question resolution
- Image URL generation

#### **3. exams_service.py**
- List exam papers
- Get paper details
- Question counts
- Mismatch counts (extraction quality)

#### **4. drill_service.py**
- Random question sampling
- Subject/chapter filtering
- Taxonomy validation

#### **5. bookmarks_service.py**
- Add/remove bookmarks
- List user bookmarks

#### **6. attempts_service.py**
- Start attempt (drill, quiz, paper)
- Record answers
- Submit attempt
- Calculate scores
- Generate review

#### **7. progress_service.py**
- Compute user progress summary
- Subject/chapter breakdowns
- Streak calculation

#### **8. review_service.py**
- Update questions (PATCH)
- Delete questions
- Manage options (MCQ)
- Manage subparts (Written)
- Image management

#### **9. pdf_service.py**
- Generate attempt PDF
- Include questions, answers, solutions

#### **10. image_cropper.py**
- Detect rectangle annotations
- Crop figures from PDFs
- Reading order sorting
- Color removal

---

## Extraction Pipeline

### **Architecture**

```
PDF Upload → Validation → Render to Images → Page-by-Page Extraction → 
Image Linking → JSON Save → DB Persistence → Job Complete
```

### **Components**

#### **1. Extractors** (`app/extractors/`)
- `admission_mcq.py` - Admission MCQ extraction
- `admission_written.py` - Admission written extraction
- `hsc_mcq.py` - HSC MCQ extraction
- `hsc_written.py` - HSC written extraction
- `_common.py` - Shared utilities (metadata latching, stamping)

#### **2. Prompts** (`app/prompts/`)
- **Hybrid approach**: Base prompt + subject-specific addendums
- `admission_mcq.py` - Multi-subject generic prompt
- `admission_written.py` - Multi-subject generic prompt
- `hsc_mcq.py` - Single-subject with addendum injection
- `hsc_written.py` - Single-subject with addendum injection
- `subject_addendums.py` - Physics, Chemistry, Math, Biology addendums
- `shared.py` - Common blocks (math, images, stitching)

#### **3. Schemas** (`app/schemas/`)
- Pydantic models for extraction
- Page-level and PDF-level schemas
- Question, Option, Image schemas

#### **4. DB Storage** (`app/db_storage/`)
- Persist extraction results to database
- Polymorphic question handling
- Image serialization

#### **5. Image Processing**
- **Manual crops**: Pre-cropped images from `/crop-images` API
- **Pass 2**: Automated cropping via Gemini (diagram localization)
- **Image linker**: Pairs `[IMAGE_N]` tokens with files

---

## Solution Generation

### **Background Worker** (`app/solution_worker/`)

**Components:**
- `generator.py` - Gemini solution generation
- `processors.py` - Batch processing by question type
- `prompts.py` - Solution generation prompts
- `runner.py` - Main worker loop
- `physics_mcq_runner.py` - Physics-specific MCQ solutions

**Features:**
- Batch processing (20 questions at a time)
- Subject-specific prompts (physics)
- Gemini API key rotation
- Quota error handling
- Solution status tracking

**Usage:**
```bash
python -m backend.app.solution_worker
```

---

## Configuration

### **config.yaml**
```yaml
gemini_model: "gemini-3-flash-preview"
request_pause_seconds: 2.0
output_dir: "./data/results"
render_dpi: 200
max_pages: 15
tail_context_chars: 600
max_upload_mb: 50
manual_crops_dir: "./data/cropped_images"
manual_crops_alias:
  "Dhaka_University_2019_20_unit_A_mcq": "DU-2019-2020-A-Unit"
```

### **.env**
```bash
GEMINI_API_KEY_1=your_key_here
GEMINI_API_KEY_2=your_key_here  # Optional: key rotation
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/exambank
JWT_SECRET=your_secret_here
JWT_ACCESS_TTL_MIN=15
JWT_REFRESH_TTL_DAYS=30
```

### **chapters.yaml**
- Subject taxonomy (physics, chemistry, math, biology)
- Paper-specific chapters (Paper 1, Paper 2)
- Snake_case chapter keys

### **chapters_bn.yaml**
- Bangla chapter labels
- Display names for frontend

---

## Authentication & Authorization

### **JWT Strategy**
- **Access Token**: Short-lived (15 min), used for API requests
- **Refresh Token**: Long-lived (30 days), used to get new access tokens

### **Roles**
- **User**: Regular user (drill, bookmarks, attempts)
- **Admin**: Full access (extraction, review, quiz management)

### **Protected Routes**
- Public: Questions, exams, taxonomy
- User: Drill, bookmarks, attempts, progress
- Admin: Extraction, review, quiz management

---

## Database Migrations

### **Alembic Migrations (11 total)**

1. `0001_initial_schema.py` - Core tables
2. `0002_auth_and_user_data.py` - Auth + user features
3. `0003_four_question_tables.py` - Question type separation
4. `0004_source_pdf_path.py` - PDF storage
5. `0005_question_images.py` - Image support
6. `0006_option_image_filename.py` - Option images
7. `0007_admin_and_subject_quiz.py` - Quiz features
8. `0008_quiz_status_and_attempt_exam_type.py` - Quiz status
9. `0009_users_display_name_not_null.py` - Display name required
10. `43f2a85d37b7_add_gemini_fields_to_admission_mcq.py` - Gemini solutions
11. `e5d31493a649_add_gemini_fields_to_hsc_mcq.py` - Gemini solutions

---

## Scripts & Utilities

### **CLI Scripts** (`backend/scripts/`)

1. **crop_figures_batch.py** - Batch image cropping
2. **describe_with_gemini.py** - Generate image descriptions
3. **redraw_with_gemini.py** - Redraw figures as SVG
4. **reimport_papers_from_json.py** - Re-import extraction results
5. **backfill_image_links.py** - Backfill image links

---

## Key Features

### **1. Hybrid Prompt Approach**
- **Admission tests**: Generic multi-subject prompts
- **HSC board**: Base prompt + subject-specific addendums
- **Benefits**: Better extraction quality for subject-specific notation

### **2. Image Handling**
- **Manual crops**: Pre-annotated PDFs → `/crop-images` API
- **Automatic linking**: Pairs `[IMAGE_N]` tokens with files
- **Pass 2**: Gemini-based diagram localization (fallback)

### **3. Polymorphic Questions**
- 4 question types with different schemas
- Unified API responses
- Type-specific services

### **4. Flexible Attempts**
- Drill mode (random practice)
- Subject quizzes
- Full paper attempts
- Timed exams

### **5. Progress Tracking**
- Subject/chapter breakdowns
- Streak calculation
- Historical attempts

---

## Performance Considerations

### **Extraction**
- ~2-5 seconds per page (Gemini API)
- Checkpointing for resume on failure
- Async processing (background jobs)

### **Database**
- Indexed fields: email, token_hash, question filters
- Pagination for large result sets
- Polymorphic queries optimized

### **Caching**
- Prompt caching (LRU cache)
- Gemini prefix caching (byte-identical prompts)

---

## Security

### **Authentication**
- Argon2 password hashing
- JWT with short-lived access tokens
- Refresh token rotation
- Token revocation on logout

### **Authorization**
- Role-based access control (User, Admin)
- Dependency injection for auth checks
- Protected admin routes

### **Input Validation**
- Pydantic schemas for all inputs
- File type validation (PDF only)
- File size limits (50 MB default)
- SQL injection prevention (SQLAlchemy ORM)

---

## Deployment

### **Requirements**
- Python 3.10+
- PostgreSQL 13+
- Gemini API key(s)

### **Environment**
- Development: SQLite (optional)
- Production: PostgreSQL + Cloudinary (images)

### **Docker Support**
- `Dockerfile` for containerization
- `docker-compose.yml` for local development

---

## Future Enhancements

### **Planned Features**
1. **Multi-language support** (English, Bangla)
2. **Advanced analytics** (performance trends, weak areas)
3. **Collaborative features** (study groups, leaderboards)
4. **Mobile app** (Flutter - already in progress)
5. **Offline mode** (PWA)

### **Technical Improvements**
1. **Caching layer** (Redis for frequently accessed data)
2. **CDN integration** (for images)
3. **Horizontal scaling** (multiple workers)
4. **Real-time features** (WebSocket for live quizzes)
5. **Advanced search** (Elasticsearch for full-text search)

---

## Summary

**ExamBank Backend** is a well-architected FastAPI application with:
- ✅ **40+ API endpoints** covering extraction, questions, attempts, and admin features
- ✅ **Hybrid AI approach** with subject-specific prompts for better extraction
- ✅ **Flexible question types** (4 types: Admission MCQ/Written, HSC MCQ/Written)
- ✅ **Comprehensive user features** (drill, bookmarks, attempts, progress)
- ✅ **Robust admin tools** (extraction, review, quiz management)
- ✅ **Production-ready** (auth, migrations, error handling, logging)

The architecture is modular, maintainable, and scalable, with clear separation of concerns across routers, services, models, and utilities.
