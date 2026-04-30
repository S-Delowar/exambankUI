"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { FormEvent, useState, Suspense } from "react";
import { useAuth } from "@/lib/AuthContext";

function SignupForm() {
  const { signup } = useAuth();
  const router = useRouter();
  const search = useSearchParams();
  const next = search.get("next") || "/quiz/physics";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    const trimmed = displayName.trim();
    if (!trimmed) {
      setError("Please enter your name.");
      return;
    }
    setBusy(true);
    try {
      await signup(email, password, trimmed);
      router.replace(next);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Sign-up failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="max-w-md mx-auto px-4 py-12">
      <h1 className="text-2xl font-semibold mb-6">Create an account</h1>
      <form onSubmit={onSubmit} className="space-y-4">
        <div>
          <label className="block text-sm text-slate-700 mb-1">Email</label>
          <input
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm text-slate-700 mb-1">Name</label>
          <input
            type="text"
            required
            minLength={1}
            maxLength={64}
            autoComplete="name"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm text-slate-700 mb-1">Password</label>
          <input
            type="password"
            required
            minLength={8}
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm"
          />
          <p className="text-xs text-slate-500 mt-1">At least 8 characters.</p>
        </div>
        {error && (
          <div className="rounded-md bg-red-50 border border-red-200 p-2 text-sm text-red-700">
            {error}
          </div>
        )}
        <button
          type="submit"
          disabled={busy}
          className="w-full px-4 py-2 rounded-md bg-blue-600 text-white text-sm disabled:opacity-50"
        >
          {busy ? "Creating account…" : "Sign up"}
        </button>
      </form>
      <p className="text-sm text-slate-600 mt-6">
        Already have an account?{" "}
        <Link href="/login" className="text-blue-600 hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}

export default function SignupPage() {
  return (
    <Suspense fallback={<div className="max-w-md mx-auto px-4 py-12">Loading...</div>}>
      <SignupForm />
    </Suspense>
  );
}
