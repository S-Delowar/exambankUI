"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

// Admin landing — quizzes is the primary admin surface (matches your
// workflow: curate questions → publish quiz → roster). Jobs and Upload are
// secondary, reachable via AdminNav.
export default function AdminLanding() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/admin/quizzes");
  }, [router]);
  return null;
}
