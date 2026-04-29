"""Re-export the shared SQLAlchemy `Base` so model sub-modules don't reach into
`app.database` directly."""

from ..database import Base

__all__ = ["Base"]
