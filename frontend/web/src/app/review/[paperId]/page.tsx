"use client";

import { useParams, useRouter } from "next/navigation";
import { useEffect } from "react";

// Legacy path — paper review moved under /admin/papers/[paperId]/review as
// part of the route shell split. Redirect so old bookmarks don't 404.
export default function ReviewRedirect() {
  const router = useRouter();
  const params = useParams<{ paperId: string }>();
  useEffect(() => {
    if (params.paperId) {
      router.replace(`/admin/papers/${params.paperId}/review`);
    }
  }, [router, params.paperId]);
  return null;
}
