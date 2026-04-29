"use client";

import { useParams, useRouter } from "next/navigation";
import { useEffect } from "react";

// Legacy path — quiz route moved to /quizzes/[subject]/[exam_type] when the
// data model became (subject, exam_type)-keyed. The old path didn't carry
// exam_type so we redirect to the admission_test variant, which is the only
// exam_type with content today. Bookmarks pointing at /subjects/physics
// thus land on the equivalent quiz page.
export default function SubjectRedirect() {
  const router = useRouter();
  const params = useParams<{ subject: string }>();
  useEffect(() => {
    if (params.subject) {
      router.replace(`/quizzes/${params.subject}/admission_test`);
    }
  }, [router, params.subject]);
  return null;
}
