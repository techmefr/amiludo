import { createClient, type User } from "npm:@supabase/supabase-js@2.49.4";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

const reply = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const view = (user: User) => ({
  id: user.id,
  email: user.email ?? "",
  name: String(user.user_metadata?.name ?? ""),
  admin: user.app_metadata?.role === "admin",
  confirmed: Boolean(user.email_confirmed_at),
  blocked: Boolean(
    user.banned_until && new Date(user.banned_until) > new Date(),
  ),
  createdAt: user.created_at,
  lastSignInAt: user.last_sign_in_at ?? null,
});

type Request = {
  action?: string;
  id?: string;
  email?: string;
  name?: string;
  redirectTo?: string;
  admin?: boolean;
  blocked?: boolean;
};

async function run(body: Request, callerId: string): Promise<Response> {
  const target = typeof body.id === "string" ? body.id : "";
  if (body.action !== "list" && body.action !== "invite") {
    if (!target) return reply(400, { error: "missing_user" });
    if (target === callerId) return reply(400, { error: "self" });
  }
  switch (body.action) {
    case "list": {
      const { data, error } = await admin.auth.admin.listUsers({
        perPage: 1000,
      });
      if (error) return reply(400, { error: error.message });
      return reply(200, { users: data.users.map(view) });
    }
    case "invite": {
      const email = String(body.email ?? "").trim().toLowerCase();
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
        return reply(400, { error: "invalid_email" });
      }
      const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
        data: { name: String(body.name ?? "").trim().slice(0, 40) },
        redirectTo: body.redirectTo,
      });
      if (error) return reply(400, { error: error.message });
      return reply(200, { user: view(data.user) });
    }
    case "role": {
      const { data, error } = await admin.auth.admin.updateUserById(target, {
        app_metadata: { role: body.admin === true ? "admin" : null },
      });
      if (error) return reply(400, { error: error.message });
      return reply(200, { user: view(data.user) });
    }
    case "block": {
      const { data, error } = await admin.auth.admin.updateUserById(target, {
        ban_duration: body.blocked === true ? "876000h" : "none",
      });
      if (error) return reply(400, { error: error.message });
      return reply(200, { user: view(data.user) });
    }
    case "delete": {
      const { error } = await admin.auth.admin.deleteUser(target);
      if (error) return reply(400, { error: error.message });
      return reply(200, { deleted: target });
    }
    default:
      return reply(400, { error: "unknown_action" });
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply(405, { error: "post_only" });
  const token = (req.headers.get("Authorization") ?? "").replace(
    /^Bearer\s+/i,
    "",
  );
  const { data } = await admin.auth.getUser(token);
  if (data.user?.app_metadata?.role !== "admin") {
    return reply(403, { error: "admin_only" });
  }
  const body = (await req.json().catch(() => ({}))) as Request;
  return run(body, data.user.id);
});
