"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

// Legacy path — extraction history moved under /admin/jobs as part of the
// route shell split. Redirect so old bookmarks don't 404.
export default function HistoryRedirect() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/admin/jobs");
  }, [router]);
  return null;
}
