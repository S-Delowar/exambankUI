"""Thin Gemini call wrappers.

`extract_page` runs the structured per-page text extraction (pass 1).
`extract_diagrams_from_crop` runs the per-question diagram localisation /
table transcription (pass 2) against a tight crop of one question.

Both retry once on transient errors and use the SDK's structured-output parse
with a fallback to `model_validate_json(response.text)`.
"""

import asyncio
import logging
from typing import TypeVar

from google import genai
from google.genai import errors as genai_errors
from google.genai import types
from pydantic import BaseModel

from .config import Settings

logger = logging.getLogger(__name__)

T = TypeVar("T", bound=BaseModel)


class _TruncationError(RuntimeError):
    """Gemini stopped with finish_reason=MAX_TOKENS — same config will repeat."""


class _AllKeysExhausted(RuntimeError):
    """Every configured GEMINI_API_KEY_* hit a quota error on this call."""


def _is_quota_error(exc: BaseException) -> bool:
    """True for 429 / RESOURCE_EXHAUSTED — meaning rotate the key, don't retry."""
    if isinstance(exc, genai_errors.APIError):
        if getattr(exc, "code", None) == 429:
            return True
        status = getattr(exc, "status", None)
        if status and "RESOURCE_EXHAUSTED" in str(status):
            return True
    return False


class GeminiExtractor:
    def __init__(self, settings: Settings):
        self._settings = settings
        self._keys: list[str] = list(settings.gemini_api_keys)
        if not self._keys:
            raise RuntimeError(
                "No Gemini API keys configured. Set GEMINI_API_KEY_1 (and "
                "optionally _2.._N) or the legacy GEMINI_API_KEY in .env."
            )
        self._key_idx = 0
        self._client = genai.Client(api_key=self._keys[self._key_idx])

    def _rotate_key(self) -> bool:
        """Advance to the next key and rebuild the client. Returns False if
        we've already used every key during the current call."""
        if self._key_idx + 1 >= len(self._keys):
            return False
        self._key_idx += 1
        self._client = genai.Client(api_key=self._keys[self._key_idx])
        logger.warning(
            "Rotated to Gemini API key #%d/%d after quota error",
            self._key_idx + 1,
            len(self._keys),
        )
        return True

    async def extract_page(
        self,
        *,
        image_png: bytes,
        system_prompt: str,
        user_prompt: str,
        response_schema: type[T],
        page_index: int,
    ) -> T:
        """Run one Gemini call for one page, returning the parsed schema."""
        image_part = types.Part.from_bytes(data=image_png, mime_type="image/png")
        contents = [image_part, user_prompt]

        config = types.GenerateContentConfig(
            system_instruction=system_prompt,
            response_mime_type="application/json",
            response_schema=response_schema,
            temperature=0.1,
            max_output_tokens=32768,
            thinking_config=types.ThinkingConfig(thinking_level="low"),
        )

        return await self._call_with_retry(
            contents=contents,
            config=config,
            response_schema=response_schema,
            label=f"page {page_index + 1}",
        )

    async def extract_from_crop(
        self,
        *,
        crop_png: bytes,
        user_prompt: str,
        response_schema: type[T],
        label: str,
    ) -> T:
        """Pass-2 call: send a per-question crop + tokens prompt, return parsed
        diagram localisations / table transcriptions. No system prompt — the
        full instructions go in the user prompt because the call is one-shot
        per question and prefix caching across crops gives little benefit
        (the prompt body changes per question)."""
        image_part = types.Part.from_bytes(data=crop_png, mime_type="image/png")
        contents = [image_part, user_prompt]

        config = types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=response_schema,
            temperature=0.1,
        )

        return await self._call_with_retry(
            contents=contents,
            config=config,
            response_schema=response_schema,
            label=label,
        )

    async def _call_with_retry(
        self,
        *,
        contents: list,
        config: "types.GenerateContentConfig",
        response_schema: type[T],
        label: str,
    ) -> T:
        last_err: Exception | None = None
        attempt = 0  # transient-error attempts (capped at 2)
        while True:
            try:
                response = await asyncio.to_thread(
                    self._client.models.generate_content,
                    model=self._settings.gemini_model,
                    contents=contents,
                    config=config,
                )
                candidate = response.candidates[0] if response.candidates else None
                finish_reason = getattr(candidate, "finish_reason", None)
                if finish_reason and str(finish_reason).endswith("MAX_TOKENS"):
                    raise _TruncationError(
                        f"Gemini hit max_output_tokens for {label}. "
                        f"Response truncated at ~{len(response.text or '')} chars. "
                        f"Raise max_output_tokens, lower thinking_level, or split the page."
                    )
                parsed = response.parsed
                if isinstance(parsed, response_schema):
                    return parsed
                if response.text:
                    return response_schema.model_validate_json(response.text)
                raise RuntimeError("Gemini returned no parseable content.")
            except _TruncationError:
                raise
            except Exception as e:
                if _is_quota_error(e):
                    logger.warning(
                        "Gemini quota error on key #%d/%d for %s: %s",
                        self._key_idx + 1,
                        len(self._keys),
                        label,
                        e,
                    )
                    if self._rotate_key():
                        # Don't burn a transient-retry slot on a quota error.
                        continue
                    raise _AllKeysExhausted(
                        f"All {len(self._keys)} Gemini API keys hit quota "
                        f"errors while processing {label}."
                    ) from e
                last_err = e
                attempt += 1
                logger.warning(
                    "Gemini call failed for %s (attempt %d/2): %s",
                    label,
                    attempt,
                    e,
                )
                if attempt >= 2:
                    raise RuntimeError(
                        f"Gemini extraction failed for {label}: {last_err}"
                    ) from last_err
                await asyncio.sleep(10.0)
