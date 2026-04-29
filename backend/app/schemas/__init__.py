"""Pydantic extraction schemas, split by (exam_type, question_type).

Layout:
    common.py         -> shared Option, JobState, JobProgress, JobStatus
    admission_mcq.py  -> AdmissionMcqQuestion, AdmissionMcqPageExtraction, AdmissionMcqPdfExtraction
    admission_written.py -> AdmissionWrittenQuestion, ...
    hsc_mcq.py        -> HscMcqQuestion, ...
    hsc_written.py    -> HscWrittenSubpart, HscWrittenQuestion, ...

`ExamType` and `QuestionType` literals live in `common.py` and are re-exported
here for convenience. Every downstream module should import from `app.schemas`,
not from the sub-modules directly, so we can rearrange internals without
touching call sites.
"""

from .admission_mcq import (
    AdmissionMcqPageExtraction,
    AdmissionMcqPdfExtraction,
    AdmissionMcqQuestion,
)
from .admission_written import (
    AdmissionWrittenPageExtraction,
    AdmissionWrittenPdfExtraction,
    AdmissionWrittenQuestion,
)
from .common import (
    ExamType,
    ExtractionStatus,
    JobProgress,
    JobState,
    JobStatus,
    Option,
    QuestionImage,
    QuestionRegion,
    QuestionType,
)
from .hsc_mcq import (
    HscMcqPageExtraction,
    HscMcqPdfExtraction,
    HscMcqQuestion,
)
from .hsc_written import (
    HscWrittenPageExtraction,
    HscWrittenPdfExtraction,
    HscWrittenQuestion,
    HscWrittenSubpart,
)

__all__ = [
    "ExamType",
    "QuestionType",
    "Option",
    "QuestionImage",
    "QuestionRegion",
    "ExtractionStatus",
    "JobState",
    "JobProgress",
    "JobStatus",
    "AdmissionMcqQuestion",
    "AdmissionMcqPageExtraction",
    "AdmissionMcqPdfExtraction",
    "AdmissionWrittenQuestion",
    "AdmissionWrittenPageExtraction",
    "AdmissionWrittenPdfExtraction",
    "HscMcqQuestion",
    "HscMcqPageExtraction",
    "HscMcqPdfExtraction",
    "HscWrittenSubpart",
    "HscWrittenQuestion",
    "HscWrittenPageExtraction",
    "HscWrittenPdfExtraction",
]
