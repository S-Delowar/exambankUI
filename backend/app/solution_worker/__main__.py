"""Module entry point: `python -m app.solution_worker`.

Runs one pass over every (exam_type, question_type) table, then exits when all
pending rows are drained. For HSC written, each sub-part has its own solution.
"""

import argparse
import asyncio
import logging

from ..config import get_settings
from .runner import run_loop


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    parser = argparse.ArgumentParser(
        description="Generate AI explanations for pending questions across all 4 question tables."
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=None,
        help="Rows per batch (default: from config).",
    )
    args = parser.parse_args()
    batch_size = args.batch_size or get_settings().solution_worker_batch_size
    asyncio.run(run_loop(batch_size))


if __name__ == "__main__":
    main()
