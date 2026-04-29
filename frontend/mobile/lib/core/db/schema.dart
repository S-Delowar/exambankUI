/// SQLite DDL for schema version 1. Kept as a single place to review.
const List<String> kSchemaV1 = <String>[
  '''
  CREATE TABLE users_cache (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    display_name TEXT,
    created_at INTEGER NOT NULL,
    cached_at INTEGER NOT NULL
  );
  ''',
  '''
  CREATE TABLE exam_papers_cache (
    id TEXT PRIMARY KEY,
    source_filename TEXT NOT NULL,
    university_name TEXT,
    exam_session TEXT,
    exam_unit TEXT,
    page_count INTEGER NOT NULL,
    question_count INTEGER NOT NULL DEFAULT 0,
    cached_at INTEGER NOT NULL
  );
  ''',
  'CREATE INDEX idx_papers_uni_session ON exam_papers_cache(university_name, exam_session);',
  '''
  CREATE TABLE questions_cache (
    id TEXT PRIMARY KEY,
    paper_id TEXT NOT NULL,
    question_number TEXT NOT NULL,
    question_text TEXT NOT NULL,
    subject TEXT,
    chapter TEXT,
    correct_answer TEXT,
    solution TEXT,
    solution_status TEXT NOT NULL DEFAULT 'pending',
    has_image INTEGER NOT NULL DEFAULT 0,
    cached_at INTEGER NOT NULL
  );
  ''',
  'CREATE INDEX idx_questions_paper ON questions_cache(paper_id);',
  'CREATE INDEX idx_questions_subject_chapter ON questions_cache(subject, chapter);',
  '''
  CREATE TABLE options_cache (
    id TEXT PRIMARY KEY,
    question_id TEXT NOT NULL,
    label TEXT NOT NULL,
    text TEXT NOT NULL,
    display_order INTEGER NOT NULL
  );
  ''',
  'CREATE INDEX idx_options_question ON options_cache(question_id);',
  '''
  CREATE TABLE attempts (
    local_id TEXT PRIMARY KEY,
    server_id TEXT UNIQUE,
    user_id TEXT NOT NULL,
    kind TEXT NOT NULL,
    paper_id TEXT,
    drill_subject TEXT,
    drill_chapter TEXT,
    mode TEXT NOT NULL,
    duration_sec INTEGER,
    started_at INTEGER NOT NULL,
    submitted_at INTEGER,
    score_correct INTEGER,
    score_total INTEGER,
    status TEXT NOT NULL
  );
  ''',
  'CREATE INDEX idx_attempts_user_status ON attempts(user_id, status);',
  '''
  CREATE TABLE attempt_answers (
    attempt_local_id TEXT NOT NULL,
    question_id TEXT NOT NULL,
    selected_label TEXT,
    is_correct INTEGER,
    answered_at INTEGER NOT NULL,
    PRIMARY KEY (attempt_local_id, question_id)
  );
  ''',
  '''
  CREATE TABLE bookmarks (
    question_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    synced INTEGER NOT NULL DEFAULT 0
  );
  ''',
  '''
  CREATE TABLE pending_writes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kind TEXT NOT NULL,
    payload TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    status TEXT NOT NULL DEFAULT 'pending'
  );
  ''',
  'CREATE INDEX idx_pending_status ON pending_writes(status, created_at);',
];
