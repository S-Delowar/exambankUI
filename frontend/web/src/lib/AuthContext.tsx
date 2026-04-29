"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import {
  AuthUser,
  Session,
  fetchMe,
  getSession,
  login as authLogin,
  logout as authLogout,
  signup as authSignup,
  subscribe,
} from "./auth";

interface AuthContextValue {
  user: AuthUser | null;
  isAdmin: boolean;
  ready: boolean; // true after the initial /auth/me check (or after we know there's no session)
  login: (email: string, password: string) => Promise<void>;
  signup: (
    email: string,
    password: string,
    display_name: string,
  ) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSessionState] = useState<Session | null>(() => null);
  const [ready, setReady] = useState(false);

  // Hydrate from storage + verify with /auth/me on mount.
  useEffect(() => {
    const initial = getSession();
    setSessionState(initial);
    if (initial) {
      // confirm token validity (and pull updated is_admin if it changed)
      void fetchMe().finally(() => setReady(true));
    } else {
      setReady(true);
    }
    const unsub = subscribe((s) => setSessionState(s));
    return unsub;
  }, []);

  const doLogin = useCallback(async (email: string, password: string) => {
    await authLogin(email, password);
  }, []);

  const doSignup = useCallback(
    async (email: string, password: string, display_name: string) => {
      await authSignup(email, password, display_name);
    },
    [],
  );

  const doLogout = useCallback(async () => {
    await authLogout();
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user: session?.user ?? null,
        isAdmin: !!session?.user?.is_admin,
        ready,
        login: doLogin,
        signup: doSignup,
        logout: doLogout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside <AuthProvider>");
  return ctx;
}
