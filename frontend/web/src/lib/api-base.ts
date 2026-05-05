import { getSession, refresh, setSession } from "./auth";
import { API_BASE_URL } from "./constants";

class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

async function doFetch(
  path: string,
  init: RequestInit,
  token: string | null,
): Promise<Response> {
  const headers: Record<string, string> = {
    ...(init.body && !(init.body instanceof FormData)
      ? { "Content-Type": "application/json" }
      : {}),
    ...((init.headers as Record<string, string>) || {}),
  };
  if (token) headers["Authorization"] = `Bearer ${token}`;
  return fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers,
    cache: "no-store",
  });
}

export async function request<T>(
  path: string,
  init: RequestInit = {},
): Promise<T> {
  const session = getSession();
  let token = session?.access_token ?? null;

  let res = await doFetch(path, init, token);

  // Single retry path: if access token is rejected, try a refresh once.
  if (res.status === 401 && session) {
    const next = await refresh();
    if (next) {
      token = next;
      res = await doFetch(path, init, token);
    } else {
      setSession(null);
    }
  }

  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try {
      const body = (await res.json()) as { detail?: string };
      if (body.detail) detail = body.detail;
    } catch {
      // ignore
    }
    throw new ApiError(res.status, detail);
  }
  if (res.status === 204) return undefined as T;
  const ct = res.headers.get("content-type") || "";
  if (ct.includes("application/json")) return (await res.json()) as T;
  return (await res.text()) as unknown as T;
}
