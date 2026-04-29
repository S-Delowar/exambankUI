"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/lib/AuthContext";

export default function HomePage() {
  const { user, ready } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (ready && user) router.replace("/dashboard");
  }, [ready, user, router]);

  if (!ready || user) {
    return null;
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-10 sm:py-16">
      <h1 className="text-2xl sm:text-3xl font-semibold mb-2">ExamBank</h1>
      <p className="text-slate-600 mb-6 sm:mb-8">
        Practice MCQs by subject. Pick a quiz, drill chapters, see your weak
        spots — every question comes with a worked solution.
      </p>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Link
          href="/signup"
          className="block rounded-lg border border-slate-200 hover:border-blue-500 p-6 transition"
        >
          <div className="text-lg font-medium mb-1">Sign up</div>
          <div className="text-sm text-slate-600">
            Create an account to start practicing.
          </div>
        </Link>
        <Link
          href="/login"
          className="block rounded-lg border border-slate-200 hover:border-blue-500 p-6 transition"
        >
          <div className="text-lg font-medium mb-1">Log in</div>
          <div className="text-sm text-slate-600">
            Already have an account? Resume where you left off.
          </div>
        </Link>
      </div>
    </div>
  );
}
