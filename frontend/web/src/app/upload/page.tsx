"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

// Legacy path — admin upload moved under /admin/upload as part of the route
// shell split. Redirect so old bookmarks don't 404.
export default function UploadRedirect() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/admin/upload");
  }, [router]);
  return null;
}
