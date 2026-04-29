"""Gemini caller for solution generation."""

import asyncio
import logging
from pydantic import BaseModel

from google import genai
from google.genai import types, errors as genai_errors

from ..config import Settings

logger = logging.getLogger(__name__)


class SolutionSchema(BaseModel):
    solution: str
    label: str


def _is_quota_error(exc: BaseException) -> bool:
    """True for 429 / RESOURCE_EXHAUSTED — meaning rotate the key, don't retry."""
    if isinstance(exc, genai_errors.APIError):
        if getattr(exc, "code", None) == 429:
            return True
        status = getattr(exc, "status", None)
        if status and "RESOURCE_EXHAUSTED" in str(status):
            return True
    return False


class SolutionGenerator:
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
        we've already used every key."""
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

    async def generate(self, system_prompt: str, user_prompt: str, image_bytes_list: list[bytes] | None = None) -> SolutionSchema:
        config = types.GenerateContentConfig(
            system_instruction=system_prompt,
            temperature=0.2,
            response_mime_type="application/json",
            response_schema=SolutionSchema,
        )
        
        contents = []
        if image_bytes_list:
            for img_bytes in image_bytes_list:
                contents.append(types.Part.from_bytes(data=img_bytes, mime_type="image/png"))
        
        contents.append(user_prompt)

        while True:
            try:
                response = await asyncio.to_thread(
                    self._client.models.generate_content,
                    model=self._settings.solution_model,
                    contents=contents,
                    config=config,
                )
                if response.parsed:
                    return response.parsed
                if response.text:
                    return SolutionSchema.model_validate_json(response.text)
                raise RuntimeError("Gemini returned empty or unparseable response.")
            except Exception as e:
                if _is_quota_error(e):
                    if self._rotate_key():
                        continue
                    raise RuntimeError("All Gemini API keys hit quota limits.") from e
                raise
