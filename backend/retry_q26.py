#!/usr/bin/env python3
"""Retry generating solution for question 26."""
import asyncio
from generate_specific_solutions import generate_for_questions

if __name__ == "__main__":
    asyncio.run(generate_for_questions("2018-2019", ["26"]))
