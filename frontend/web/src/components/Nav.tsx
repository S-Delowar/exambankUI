"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/AuthContext";

// Single header component that dispatches between Student and Admin layouts
// based on the current pathname. We keep one slot in RootLayout (instead of
// stacking navs from a route-group layout) so there is exactly one header.
export default function Nav() {
  const pathname = usePathname();
  const isAdminPath = pathname?.startsWith("/admin") ?? false;

  return isAdminPath ? <AdminNav /> : <StudentNav />;
}

function NavLink({
  href,
  children,
  onClick,
}: {
  href: string;
  children: React.ReactNode;
  onClick?: () => void;
}) {
  return (
    <Link
      href={href}
      onClick={onClick}
      className="text-slate-600 hover:text-slate-900"
    >
      {children}
    </Link>
  );
}

function UserMenu({ onNavigate }: { onNavigate?: () => void }) {
  const { user, isAdmin, ready, logout } = useAuth();
  const router = useRouter();

  async function onLogout() {
    onNavigate?.();
    await logout();
    router.replace("/login");
  }

  if (!ready) return null;
  if (!user) {
    return (
      <>
        <Link
          href="/login"
          onClick={onNavigate}
          className="text-sm text-slate-600 hover:text-slate-900"
        >
          Log in
        </Link>
        <Link
          href="/signup"
          onClick={onNavigate}
          className="text-sm px-3 py-1.5 rounded-md bg-blue-600 text-white"
        >
          Sign up
        </Link>
      </>
    );
  }
  return (
    <>
      <span className="text-sm text-slate-500 hidden sm:inline">
        {user.display_name}
        {isAdmin ? (
          <span className="ml-2 px-1.5 py-0.5 rounded bg-amber-100 text-amber-800 text-[10px] uppercase tracking-wide">
            admin
          </span>
        ) : null}
      </span>
      <button
        onClick={onLogout}
        className="text-sm text-slate-600 hover:text-slate-900 text-left"
      >
        Log out
      </button>
    </>
  );
}

function HamburgerButton({
  open,
  onClick,
}: {
  open: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={open ? "Close menu" : "Open menu"}
      aria-expanded={open}
      className="md:hidden inline-flex items-center justify-center w-9 h-9 rounded-md text-slate-700 hover:bg-slate-100"
    >
      <svg
        width="20"
        height="20"
        viewBox="0 0 20 20"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        {open ? (
          <>
            <line x1="5" y1="5" x2="15" y2="15" />
            <line x1="15" y1="5" x2="5" y2="15" />
          </>
        ) : (
          <>
            <line x1="3" y1="6" x2="17" y2="6" />
            <line x1="3" y1="10" x2="17" y2="10" />
            <line x1="3" y1="14" x2="17" y2="14" />
          </>
        )}
      </svg>
    </button>
  );
}

function useMobileMenu() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  useEffect(() => {
    setOpen(false);
  }, [pathname]);
  return { open, setOpen, close: () => setOpen(false) };
}

function StudentNav() {
  const { user, isAdmin } = useAuth();
  const { open, setOpen, close } = useMobileMenu();
  return (
    <header className="border-b border-slate-200 bg-white">
      <nav className="max-w-7xl mx-auto px-4 h-14 flex items-center gap-3 sm:gap-6">
        <Link href="/" className="font-semibold text-slate-900">
          ExamBank
        </Link>
        <div className="hidden md:flex items-center gap-6">
          {user && (
            <>
              <NavLink href="/dashboard">Dashboard</NavLink>
              <NavLink href="/quizzes">Quizzes</NavLink>
            </>
          )}
          {isAdmin && <NavLink href="/admin">Admin</NavLink>}
        </div>
        <div className="flex-1" />
        <div className="hidden md:flex items-center gap-6">
          <UserMenu />
        </div>
        <HamburgerButton open={open} onClick={() => setOpen((v) => !v)} />
      </nav>
      {open && (
        <div className="md:hidden border-t border-slate-200 bg-white">
          <div className="px-4 py-3 flex flex-col gap-3">
            {user && (
              <>
                <NavLink href="/dashboard" onClick={close}>
                  Dashboard
                </NavLink>
                <NavLink href="/quizzes" onClick={close}>
                  Quizzes
                </NavLink>
              </>
            )}
            {isAdmin && (
              <NavLink href="/admin" onClick={close}>
                Admin
              </NavLink>
            )}
            <div className="border-t border-slate-100 pt-3 flex flex-col gap-3">
              <UserMenu onNavigate={close} />
            </div>
          </div>
        </div>
      )}
    </header>
  );
}

function AdminNav() {
  const { open, setOpen, close } = useMobileMenu();
  return (
    <header className="border-b border-amber-200 bg-amber-50">
      <nav className="max-w-7xl mx-auto px-4 h-14 flex items-center gap-3 sm:gap-6">
        <Link href="/admin" className="font-semibold text-slate-900 truncate">
          ExamBank
          <span className="ml-2 px-1.5 py-0.5 rounded bg-amber-200 text-amber-900 text-[10px] uppercase tracking-wide">
            admin
          </span>
        </Link>
        <div className="hidden md:flex items-center gap-6">
          <NavLink href="/admin/quizzes">Quizzes</NavLink>
          <NavLink href="/admin/upload">Upload</NavLink>
          <NavLink href="/admin/jobs">Jobs</NavLink>
          <NavLink href="/dashboard">↩ Student view</NavLink>
        </div>
        <div className="flex-1" />
        <div className="hidden md:flex items-center gap-6">
          <UserMenu />
        </div>
        <HamburgerButton open={open} onClick={() => setOpen((v) => !v)} />
      </nav>
      {open && (
        <div className="md:hidden border-t border-amber-200 bg-amber-50">
          <div className="px-4 py-3 flex flex-col gap-3">
            <NavLink href="/admin/quizzes" onClick={close}>
              Quizzes
            </NavLink>
            <NavLink href="/admin/upload" onClick={close}>
              Upload
            </NavLink>
            <NavLink href="/admin/jobs" onClick={close}>
              Jobs
            </NavLink>
            <NavLink href="/dashboard" onClick={close}>
              ↩ Student view
            </NavLink>
            <div className="border-t border-amber-200 pt-3 flex flex-col gap-3">
              <UserMenu onNavigate={close} />
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
