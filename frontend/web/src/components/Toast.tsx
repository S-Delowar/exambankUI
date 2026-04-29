"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from "react";

type ToastKind = "error" | "success" | "info";

interface Toast {
  id: number;
  kind: ToastKind;
  message: string;
}

interface ToastCtx {
  push: (kind: ToastKind, message: string) => void;
}

const Ctx = createContext<ToastCtx | null>(null);

export function useToast() {
  const ctx = useContext(Ctx);
  if (!ctx) {
    throw new Error("useToast must be used inside <ToastProvider>");
  }
  return ctx;
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const nextId = useRef(1);

  const push = useCallback((kind: ToastKind, message: string) => {
    const id = nextId.current++;
    setToasts((prev) => [...prev, { id, kind, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4000);
  }, []);

  return (
    <Ctx.Provider value={{ push }}>
      {children}
      <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2 max-w-sm">
        {toasts.map((t) => (
          <ToastItem
            key={t.id}
            toast={t}
            onDismiss={() =>
              setToasts((prev) => prev.filter((x) => x.id !== t.id))
            }
          />
        ))}
      </div>
    </Ctx.Provider>
  );
}

function ToastItem({ toast, onDismiss }: { toast: Toast; onDismiss: () => void }) {
  const [entered, setEntered] = useState(false);
  useEffect(() => {
    const h = requestAnimationFrame(() => setEntered(true));
    return () => cancelAnimationFrame(h);
  }, []);
  const color =
    toast.kind === "error"
      ? "bg-red-600 text-white"
      : toast.kind === "success"
        ? "bg-emerald-600 text-white"
        : "bg-slate-800 text-white";
  return (
    <div
      className={`${color} rounded-md shadow-lg px-3 py-2 text-sm flex items-start gap-2 transition-all duration-150 ${
        entered ? "opacity-100 translate-y-0" : "opacity-0 translate-y-2"
      }`}
    >
      <span className="flex-1 break-words">{toast.message}</span>
      <button
        onClick={onDismiss}
        className="text-white/70 hover:text-white"
        aria-label="Dismiss"
      >
        ×
      </button>
    </div>
  );
}
