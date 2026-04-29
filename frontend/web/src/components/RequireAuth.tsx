"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/lib/AuthContext";

interface Props {
  children: React.ReactNode;
  adminOnly?: boolean;
}

export default function RequireAuth({ children, adminOnly = false }: Props) {
  const { user, isAdmin, ready } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!ready) return;
    if (!user) {
      const next = encodeURIComponent(pathname || "/");
      router.replace(`/login?next=${next}`);
    }
  }, [ready, user, pathname, router]);

  if (!ready) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-10 text-slate-500">
        Loading…
      </div>
    );
  }
  if (!user) {
    return null; // redirect in flight
  }
  if (adminOnly && !isAdmin) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-10">
        <h1 className="text-xl font-semibold mb-2">403 — Admin only</h1>
        <p className="text-slate-600 text-sm">
          This page is only available to administrators.
        </p>
      </div>
    );
  }
  return <>{children}</>;
}
