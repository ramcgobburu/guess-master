import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// This function only CHECKS for completed unscored matches.
// Actual result entry + point calculation is done via the admin panel
// (client-side API calls ensure 100% data accuracy).

Deno.serve(async (_req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString();
    const { data: matches } = await supabase
      .from("matches")
      .select("match_id, team1, team2, start_date_time")
      .lt("start_date_time", threeHoursAgo)
      .order("start_date_time", { ascending: true });

    const { data: existingActuals } = await supabase.from("actuals").select("match_id");
    const scoredIds = new Set((existingActuals || []).map((a: any) => a.match_id));
    const unscored = (matches || []).filter((m: any) => !scoredIds.has(m.match_id));

    return new Response(
      JSON.stringify({
        unscored_count: unscored.length,
        unscored: unscored.map((m: any) => ({
          match_id: m.match_id,
          teams: `${m.team1} vs ${m.team2}`,
        })),
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: (e as Error).message }), { status: 500 });
  }
});
