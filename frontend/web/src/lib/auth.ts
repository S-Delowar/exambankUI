// Module-level session store + raw auth API calls.
//
// Lives outside React so api.ts can read the current access token to attach
// `Authorization: Bearer …` and trigger refresh on 401 without going through
// any hook. AuthContext.tsx subscribes to changes for re-renders.

import { API_BASE_URL } from "./api";

export interface AuthUser {
  id: string;
  email: string;
  // Required field — the backend enforces NOT NULL on users.display_name
  // and signup requires it. See migration 0009.
  display_name: string;
  is_admin: boolean;
  created_at: string;
}

export interface Session {
  user: AuthUser;
  access_token: string;
  refresh_token: string;
}

const STORAGE_KEY = "exambank_session";

let memorySession: Session | null = null;
const listeners = new Set<(s: Session | null) => void>();

function readStorage(): Session | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw) as Session;
  } catch {
    return null;
  }
}

function writeStorage(s: Session | null) {
  if (typeof window === "undefined") return;
  if (s) window.localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
  else window.localStorage.removeItem(STORAGE_KEY);
}

function emit() {
  for (const cb of listeners) cb(memorySession);
}

export function getSession(): Session | null {
  if (memorySession) return memorySession;
  memorySession = readStorage();
  return memorySession;
}

export function setSession(s: Session | null) {
  memorySession = s;
  writeStorage(s);
  emit();
}

export function subscribe(cb: (s: Session | null) => void): () => void {
  listeners.add(cb);
  return () => {
    listeners.delete(cb);
  };
}

// Raw fetches — kept here (not in api.ts) so api.ts can call refresh() during
// its own retry loop without circular imports.

async function authFetch<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });
  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try {
      const j = (await res.json()) as { detail?: string };
      if (j.detail) detail = j.detail;
    } catch {
      // ignore
    }
    throw new Error(detail);
  }
  return (await res.json()) as T;
}

interface AuthEnvelope {
  user: AuthUser;
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

export async function login(email: string, password: string): Promise<Session> {
  const env = await authFetch<AuthEnvelope>("/auth/login", { email, password });
  const s: Session = {
    user: env.user,
    access_token: env.access_token,
    refresh_token: env.refresh_token,
  };
  setSession(s);
  return s;
}

export async function signup(
  email: string,
  password: string,
  display_name: string,
): Promise<Session> {
  const env = await authFetch<AuthEnvelope>("/auth/signup", {
    email,
    password,
    display_name,
  });
  const s: Session = {
    user: env.user,
    access_token: env.access_token,
    refresh_token: env.refresh_token,
  };
  setSession(s);
  return s;
}

// Concurrent requests should share one in-flight refresh — multiple parallel
// 401s racing to call /auth/refresh would burn the rotating refresh token.
let refreshInFlight: Promise<string | null> | null = null;

export async function refresh(): Promise<string | null> {
  const cur = getSession();
  if (!cur) return null;
  if (refreshInFlight) return refreshInFlight;
  refreshInFlight = (async () => {
    try {
      const tok = await authFetch<{
        access_token: string;
        refresh_token: string;
        expires_in: number;
      }>("/auth/refresh", { refresh_token: cur.refresh_token });
      const next: Session = {
        user: cur.user,
        access_token: tok.access_token,
        refresh_token: tok.refresh_token,
      };
      setSession(next);
      return tok.access_token;
    } catch {
      setSession(null);
      return null;
    } finally {
      refreshInFlight = null;
    }
  })();
  return refreshInFlight;
}

export async function logout(): Promise<void> {
  const cur = getSession();
  if (!cur) return;
  // Best-effort revoke on the server; clear local state regardless.
  try {
    await fetch(`${API_BASE_URL}/auth/logout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${cur.access_token}`,
      },
      body: JSON.stringify({ refresh_token: cur.refresh_token }),
    });
  } catch {
    // ignore
  }
  setSession(null);
}

export async function fetchMe(): Promise<AuthUser | null> {
  const cur = getSession();
  if (!cur) return null;
  const res = await fetch(`${API_BASE_URL}/auth/me`, {
    headers: { Authorization: `Bearer ${cur.access_token}` },
    cache: "no-store",
  });
  if (!res.ok) return null;
  const u = (await res.json()) as AuthUser;
  setSession({ ...cur, user: u });
  return u;
}
