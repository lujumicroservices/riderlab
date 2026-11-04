// Deletes the caller's auth user (and cascaded cloud rows).
// Requires a valid user JWT. Uses the service role only on the server.

import { createClient } from "npm:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// Apple guideline 5.1.1(v): accounts created with Sign in with Apple must have
// their Apple tokens revoked on deletion. The app sends a fresh
// authorization code; we exchange it for a refresh token and revoke that.
// Secrets (Apple Developer → Keys → key with "Sign in with Apple"):
//   APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY (.p8 contents),
//   APPLE_CLIENT_ID (optional, defaults to the iOS bundle id).
const APPLE_AUD = "https://appleid.apple.com";

async function appleClientSecret(): Promise<{ id: string; secret: string }> {
  const teamId = Deno.env.get("APPLE_TEAM_ID")?.trim();
  const keyId = Deno.env.get("APPLE_KEY_ID")?.trim();
  const p8 = Deno.env.get("APPLE_PRIVATE_KEY")?.trim().replace(/\\n/g, "\n");
  const id = Deno.env.get("APPLE_CLIENT_ID")?.trim() || "com.rawthrottle.riderlab";
  if (!teamId || !keyId || !p8) throw new Error("apple_not_configured");
  const key = await importPKCS8(p8, "ES256");
  const secret = await new SignJWT({})
    .setProtectedHeader({ alg: "ES256", kid: keyId })
    .setIssuer(teamId)
    .setSubject(id)
    .setAudience(APPLE_AUD)
    .setIssuedAt()
    .setExpirationTime("5m")
    .sign(key);
  return { id, secret };
}

async function revokeApple(code: string): Promise<void> {
  const { id, secret } = await appleClientSecret();
  const tokenRes = await fetch(`${APPLE_AUD}/auth/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: id,
      client_secret: secret,
      code,
      grant_type: "authorization_code",
    }),
  });
  const tokens = await tokenRes.json().catch(() => ({}));
  const token = tokens.refresh_token ?? tokens.access_token;
  if (!tokenRes.ok || typeof token !== "string") {
    throw new Error(`apple_token_${tokenRes.status}_${tokens.error ?? "no_token"}`);
  }
  const revokeRes = await fetch(`${APPLE_AUD}/auth/revoke`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: id,
      client_secret: secret,
      token,
      token_type_hint: tokens.refresh_token ? "refresh_token" : "access_token",
    }),
  });
  if (!revokeRes.ok) throw new Error(`apple_revoke_${revokeRes.status}`);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }
  if (req.method !== "POST") {
    return json(405, { error: "method_not_allowed" });
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.toLowerCase().startsWith("bearer ")) {
    return json(401, { error: "unauthorized" });
  }
  const jwt = auth.slice("bearer ".length).trim();

  const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim();
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();
  if (!supabaseUrl || !serviceKey) {
    return json(500, { error: "misconfigured" });
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  const user = userData?.user;
  if (userErr || !user) {
    return json(401, { error: "unauthorized" });
  }

  // Revoke Apple before deleting, so a failed exchange is still logged
  // against an existing user. Deletion continues either way: blocking it on
  // Apple would leave the user unable to delete their account.
  let appleRevoked: boolean | null = null;
  const body = await req.json().catch(() => ({}));
  const appleCode = typeof body?.apple_authorization_code === "string"
    ? body.apple_authorization_code.trim()
    : "";
  if (appleCode) {
    try {
      await revokeApple(appleCode);
      appleRevoked = true;
    } catch (e) {
      appleRevoked = false;
      console.error("apple revoke failed:", user.id, (e as Error).message);
    }
  }

  // Best-effort storage cleanup for rodada photos uploaded by this user.
  try {
    const { data: photos } = await admin
      .from("rodada_photos")
      .select("storage_path")
      .eq("user_id", user.id);
    const paths = (photos ?? [])
      .map((p: { storage_path?: string }) => p.storage_path)
      .filter((p): p is string => typeof p === "string" && p.length > 0);
    if (paths.length > 0) {
      await admin.storage.from("rodada-photos").remove(paths);
    }
  } catch (e) {
    console.error("rodada photo cleanup:", e);
  }

  const { error: delErr } = await admin.auth.admin.deleteUser(user.id);
  if (delErr) {
    console.error("deleteUser:", delErr);
    return json(500, { error: "delete_failed", detail: delErr.message });
  }

  return json(200, { ok: true, apple_revoked: appleRevoked });
});
