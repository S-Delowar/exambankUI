"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function PhysicsQuizRedirect() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/quizzes/physics/admission_test");
  }, [router]);
  return null;
}
