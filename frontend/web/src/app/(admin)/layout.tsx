import RequireAuth from "@/components/RequireAuth";

// Wraps every page under /admin/* with the admin gate. Each page can drop
// its own per-page `<RequireAuth adminOnly>` once this layout is in place,
// but leaving them is harmless — the inner check short-circuits when the
// outer one already passed.
export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <RequireAuth adminOnly>{children}</RequireAuth>;
}
