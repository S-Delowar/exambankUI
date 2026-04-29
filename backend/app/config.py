import os
from functools import lru_cache
from pathlib import Path

import yaml
from dotenv import dotenv_values
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent
CONFIG_YAML = BACKEND_DIR / "config.yaml"
CHAPTERS_YAML = BACKEND_DIR / "chapters.yaml"
CHAPTERS_BN_YAML = BACKEND_DIR / "chapters_bn.yaml"
ENV_FILE = BACKEND_DIR / ".env"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Populated by get_settings() from GEMINI_API_KEY_1..N (and legacy
    # GEMINI_API_KEY if present). Never read directly from the env by Pydantic.
    gemini_api_keys: list[str] = []
    database_url: str = "postgresql+asyncpg://exambank:exambank@localhost:5432/exambank"

    gemini_model: str = "gemini-2.5-flash"
    request_pause_seconds: float = 2.0
    output_dir: str = "./data/results"
    images_dir: str = "./data/images"
    render_dpi: int = 200
    max_pages: int = 15
    tail_context_chars: int = 600
    max_upload_mb: int = 50

    # Manual-cropping pipeline (test-cropping/crop_figures_batch.py).
    # `manual_crops_dir` holds per-PDF folders of pre-cropped figures the
    # extractor's image-linker pairs to Pass-1 [IMAGE_N] tokens.
    manual_crops_dir: str = "../test-cropping/cropped_images"
    # Optional explicit map from extracted paper_stem → manual-crop subfolder
    # name (e.g. "Dhaka_University_2019-20_unit_A_mcq" → "DU-2019-2020-A-Unit").
    # Falls back to direct stem match if a key is missing.
    manual_crops_alias: dict[str, str] = {}

    # Solution generation worker
    solution_worker_batch_size: int = 20
    solution_model: str = "gemini-3-flash-preview"

    # Auth
    jwt_secret: str = "dev-secret-change-me"
    jwt_access_ttl_min: int = 15
    jwt_refresh_ttl_days: int = 30
    rate_limit_auth_per_min: int | None = None

    # Populated by get_settings() from chapters.yaml. Not env-configurable.
    chapter_taxonomy: dict[str, list[str]] = {}
    chapter_taxonomy_nested: dict[str, dict[str, list[str]] | list[str]] = {}
    # Display labels by language. Populated from `chapters_bn.yaml` at load
    # time. Shape: {subject: {chapter_key: bn_label}}. Missing keys fall
    # back to a prettified version of the English chapter key on the client.
    chapter_labels_bn: dict[str, dict[str, str]] = {}

    @property
    def output_path(self) -> Path:
        p = Path(self.output_dir)
        if not p.is_absolute():
            p = BACKEND_DIR / p
        return p

    @property
    def images_path(self) -> Path:
        p = Path(self.images_dir)
        if not p.is_absolute():
            p = BACKEND_DIR / p
        return p

    @property
    def manual_crops_path(self) -> Path:
        p = Path(self.manual_crops_dir)
        if not p.is_absolute():
            p = BACKEND_DIR / p
        return p

    @property
    def gemini_api_key(self) -> str:
        """First key in the pool. Compatibility shim for callers that take a
        single key (e.g. solution_worker). Use the GeminiExtractor / KeyPool
        for any path that should rotate on quota errors."""
        if not self.gemini_api_keys:
            raise RuntimeError(
                "No Gemini API keys configured. Set GEMINI_API_KEY_1 (and "
                "optionally _2.._N) or the legacy GEMINI_API_KEY in .env."
            )
        return self.gemini_api_keys[0]


def _load_yaml_overrides() -> dict:
    if not CONFIG_YAML.exists():
        return {}
    with CONFIG_YAML.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    return {k: v for k, v in data.items() if v is not None}


def _load_chapter_labels_bn() -> dict[str, dict[str, str]]:
    """Read chapters_bn.yaml as a flat {subject: {key: bn_label}} map.

    Missing file or empty subjects → empty map. The frontend tolerates a
    missing entry by rendering a prettified English key.
    """
    if not CHAPTERS_BN_YAML.exists():
        return {}
    with CHAPTERS_BN_YAML.open("r", encoding="utf-8") as f:
        raw = yaml.safe_load(f) or {}
    out: dict[str, dict[str, str]] = {}
    for subject, mapping in raw.items():
        if isinstance(mapping, dict):
            out[subject] = {str(k): str(v) for k, v in mapping.items()}
    return out


def _load_chapter_taxonomy() -> tuple[dict[str, list[str]], dict]:
    """Return (flat, nested) forms of the taxonomy.

    Flat: {subject: [chapter, ...]} — papers merged, dedup preserving order.
    Nested: raw YAML structure — {subject: {paper_1: [...], paper_2: [...]}}
    or {subject: [...]} for subjects without a paper split.
    """
    if not CHAPTERS_YAML.exists():
        return {}, {}
    with CHAPTERS_YAML.open("r", encoding="utf-8") as f:
        nested = yaml.safe_load(f) or {}

    flat: dict[str, list[str]] = {}
    for subject, value in nested.items():
        chapters: list[str] = []
        if isinstance(value, list):
            chapters = [str(c) for c in value]
        elif isinstance(value, dict):
            for paper_chapters in value.values():
                if isinstance(paper_chapters, list):
                    chapters.extend(str(c) for c in paper_chapters)
        # Dedup preserving order.
        seen = set()
        flat[subject] = [c for c in chapters if not (c in seen or seen.add(c))]
    return flat, nested


def _load_gemini_api_keys() -> list[str]:
    """Collect Gemini API keys from `.env` + os.environ in priority order.

    Reads GEMINI_API_KEY_1, GEMINI_API_KEY_2, ... in numeric order, then the
    legacy single GEMINI_API_KEY as a final fallback. os.environ wins over
    .env for the same name (so production deployments using real env vars
    override checked-in defaults). Skips blanks; dedupes preserving order.
    """
    file_vals: dict[str, str | None] = (
        dotenv_values(ENV_FILE) if ENV_FILE.exists() else {}
    )
    merged: dict[str, str] = {}
    for k, v in file_vals.items():
        if v is not None:
            merged[k] = v
    for k, v in os.environ.items():
        merged[k] = v

    indexed: list[tuple[int, str]] = []
    for name, value in merged.items():
        if name.startswith("GEMINI_API_KEY_"):
            suffix = name[len("GEMINI_API_KEY_") :]
            if suffix.isdigit():
                indexed.append((int(suffix), value))
    indexed.sort(key=lambda x: x[0])

    keys: list[str] = []
    seen: set[str] = set()
    for _, v in indexed:
        v = (v or "").strip()
        if v and v not in seen:
            keys.append(v)
            seen.add(v)
    legacy = (merged.get("GEMINI_API_KEY") or "").strip()
    if legacy and legacy not in seen:
        keys.append(legacy)
        seen.add(legacy)
    return keys


@lru_cache
def get_settings() -> Settings:
    overrides = _load_yaml_overrides()
    flat, nested = _load_chapter_taxonomy()
    overrides["chapter_taxonomy"] = flat
    overrides["chapter_taxonomy_nested"] = nested
    overrides["chapter_labels_bn"] = _load_chapter_labels_bn()
    overrides["gemini_api_keys"] = _load_gemini_api_keys()
    settings = Settings(**overrides)
    settings.output_path.mkdir(parents=True, exist_ok=True)
    settings.images_path.mkdir(parents=True, exist_ok=True)
    return settings
