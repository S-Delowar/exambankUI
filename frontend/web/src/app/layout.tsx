import type { Metadata, Viewport } from "next";
import "./globals.css";
import Nav from "@/components/Nav";
import { ToastProvider } from "@/components/Toast";
import { AuthProvider } from "@/lib/AuthContext";

export const metadata: Metadata = {
  title: "ExamBank",
  description: "Practice physics MCQs and review your answers.",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <AuthProvider>
          <ToastProvider>
            <Nav />
            <main className="flex-1">{children}</main>
          </ToastProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
