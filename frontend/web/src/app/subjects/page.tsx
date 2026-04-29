"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

// Legacy path — student listing moved to /quizzes (the word "subjects"
// leaked the previous data model). Redirect so existing bookmarks survive.
export default function SubjectsRedirect() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/quizzes");
  }, [router]);
  return null;
}
