import asyncio
import time
import uuid

from .schemas import JobProgress, JobStatus

# Completed/failed jobs are evicted after this many seconds.
_TTL_SECONDS = 3600  # 1 hour


class JobStore:
    def __init__(self) -> None:
        self._jobs: dict[str, JobStatus] = {}
        self._timestamps: dict[str, float] = {}  # job_id → completion time
        self._lock = asyncio.Lock()

    def _evict_stale(self) -> None:
        """Remove completed/failed jobs older than TTL. Called under lock."""
        cutoff = time.monotonic() - _TTL_SECONDS
        stale = [
            jid for jid, ts in self._timestamps.items() if ts < cutoff
        ]
        for jid in stale:
            self._jobs.pop(jid, None)
            self._timestamps.pop(jid, None)

    async def create(self) -> JobStatus:
        job_id = uuid.uuid4().hex
        status = JobStatus(job_id=job_id, state="pending")
        async with self._lock:
            self._evict_stale()
            self._jobs[job_id] = status
        return status

    async def get(self, job_id: str) -> JobStatus | None:
        async with self._lock:
            return self._jobs.get(job_id)

    async def mark_running(self, job_id: str, total_pages: int) -> None:
        async with self._lock:
            job = self._jobs[job_id]
            job.state = "running"
            job.progress = JobProgress(page=0, total=total_pages)

    async def update_progress(self, job_id: str, page: int, total: int) -> None:
        async with self._lock:
            job = self._jobs[job_id]
            job.progress = JobProgress(page=page, total=total)

    async def mark_done(
        self, job_id: str, result_path: str, paper_id: str | None = None
    ) -> None:
        async with self._lock:
            job = self._jobs[job_id]
            job.state = "done"
            job.result_path = result_path
            job.paper_id = paper_id
            self._timestamps[job_id] = time.monotonic()

    async def mark_failed(self, job_id: str, error: str) -> None:
        async with self._lock:
            job = self._jobs[job_id]
            job.state = "failed"
            job.error = error
            self._timestamps[job_id] = time.monotonic()


job_store = JobStore()
