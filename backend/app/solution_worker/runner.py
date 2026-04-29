"""Orchestrator for one worker run."""

import logging

from ..config import get_settings
from .processors import process_all_once

logger = logging.getLogger(__name__)


async def run_loop(batch_size: int) -> None:
    """Drain every pending row across all 4 tables, then exit."""
    settings = get_settings()
    total = 0
    while True:
        processed = await process_all_once(settings, batch_size)
        if processed == 0:
            break
        total += processed
    logger.info("Solution worker done: %d rows processed.", total)
