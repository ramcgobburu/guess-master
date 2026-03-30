import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CRICDATA_API_KEY = Deno.env.get("CRICDATA_API_KEY")!;
const ESPN_LEAGUE_ID = "8048";

const TEAM_NAME_MAP: Record<string, string> = {
  "chennai super kings": "CSK",
  "mumbai indians": "MI",
  "royal challengers bengaluru": "RCB",
  "royal challengers bangalore": "RCB",
  "kolkata knight riders": "KKR",
  "sunrisers hyderabad": "SRH",
  "rajasthan royals": "RR",
  "delhi capitals": "DC",
  "punjab kings": "PBKS",
  "lucknow super giants": "LSG",
  "gujarat titans": "GT",
};

function mapTeamName(name: string): string {
  const mapped = TEAM_NAME_MAP[name.toLowerCase().trim()];
  if (mapped) return mapped;
  return name.toUpperCase().trim();
}

async function fetchWithRetry(
  url: string,
  options: RequestInit = {},
  retries = 3,
): Promise<Response> {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(url, { ...options, signal: AbortSignal.timeout(15000) });
      return res;
    } catch (e) {
      console.log(`Fetch attempt ${i + 1} failed for ${url}: ${(e as Error).message}`);
      if (i === retries - 1) throw e;
      await new Promise((r) => setTimeout(r, 2000 * (i + 1)));
    }
  }
  throw new Error("Unreachable");
}

interface MatchRow {
  match_id: string;
  team1: string;
  team2: string;
  start_date_time: string;
  cric_api_id: string | null;
  espn_event_id: string | null;
}

// ---- CricData: scorecard for highest individual score ----
interface CricScorecardResult {
  tossWinner: string;
  matchWinner: string;
  firstInningsScore: number;
  totalWickets: number;
  highestScore: number;
  highestScoreTied: boolean;
}

async function fetchCricScorecard(cricId: string): Promise<CricScorecardResult | null> {
  try {
    const url = `https://api.cricapi.com/v1/match_scorecard?apikey=${CRICDATA_API_KEY}&id=${cricId}`;
    const res = await fetchWithRetry(url);
    const json = await res.json();
    if (json.status === "failure" || !json.data) return null;

    const data = json.data;
    const tossWinner = mapTeamName(data.tossWinner || "");
    const matchWinner = mapTeamName(data.matchWinner || "");
    const scores = data.score || [];
    const firstInningsScore = scores.length > 0 ? (scores[0].r || 0) : 0;
    const totalWickets = scores.reduce((sum: number, s: any) => sum + (s.w || 0), 0);

    let highestScore = 0;
    let highestScoreTied = false;
    const allRuns: number[] = [];
    for (const inning of data.scorecard || []) {
      for (const b of inning.batting || []) {
        allRuns.push(b.r || 0);
      }
    }
    if (allRuns.length > 0) {
      highestScore = Math.max(...allRuns);
      highestScoreTied = allRuns.filter((r) => r === highestScore).length >= 2;
    }

    return { tossWinner, matchWinner, firstInningsScore, totalWickets, highestScore, highestScoreTied };
  } catch (e) {
    console.error("CricData scorecard failed:", (e as Error).message);
    return null;
  }
}

// ---- ESPN: toss, winner, scores, MOM ----
interface EspnResult {
  tossWinner: string;
  matchWinner: string;
  firstInningsScore: number;
  totalWickets: number;
  momTeam: string;
  matchEnded: boolean;
  secondInningsBatting: number[];
}

async function fetchEspnData(espnId: string): Promise<EspnResult | null> {
  try {
    const url = `https://site.api.espn.com/apis/site/v2/sports/cricket/${ESPN_LEAGUE_ID}/summary?event=${espnId}`;
    const res = await fetchWithRetry(url, {
      headers: { "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" },
    });
    const json = await res.json();

    const header = json.header || {};
    const comp = (header.competitions || [])[0];
    if (!comp) return null;

    const status = comp.status || {};
    const stateType = status.type || {};
    const isComplete = stateType.state === "post" || stateType.completed === true || stateType.detail === "Final";
    if (!isComplete) return { tossWinner: "", matchWinner: "", firstInningsScore: 0, totalWickets: 0, momTeam: "", matchEnded: false, secondInningsBatting: [] };

    // Teams
    const competitors = comp.competitors || [];
    const teamMap: Record<string, string> = {};
    let winnerAbbr = "";
    for (const c of competitors) {
      const abbr = c.team?.abbreviation || "";
      teamMap[c.team?.id || ""] = mapTeamName(abbr);
      if (c.winner === true || c.winner === "true") winnerAbbr = mapTeamName(abbr);
    }

    // Toss from notes
    let tossWinner = "";
    for (const n of json.notes || []) {
      if (n.type === "toss") {
        const text = (n.text || "").toLowerCase();
        for (const [fullName, abbr] of Object.entries(TEAM_NAME_MAP)) {
          if (text.includes(fullName)) { tossWinner = abbr; break; }
        }
        break;
      }
    }

    // Scores from linescores
    let firstInningsScore = 0;
    let totalWickets = 0;
    for (const c of competitors) {
      const linescores = c.linescores || [];
      for (const ls of linescores) {
        totalWickets += ls.wickets || 0;
      }
    }
    // First innings: find the team that batted first (inning 1 with runs > 0)
    for (const c of competitors) {
      const ls = c.linescores || [];
      if (ls.length > 0 && ls[0].runs > 0) {
        firstInningsScore = ls[0].runs;
        break;
      }
    }

    // MOM from featuredAthletes
    let momTeam = "";
    for (const fa of status.featuredAthletes || []) {
      if (fa.name === "playerOfTheMatch") {
        const faTeamId = fa.team?.id || "";
        momTeam = teamMap[faTeamId] || mapTeamName(fa.team?.name || "");
        break;
      }
    }

    // 2nd innings batting from matchcards
    const battingRuns: number[] = [];
    for (const mc of json.matchcards || []) {
      if (mc.headline === "Batting") {
        for (const p of mc.playerDetails || []) {
          const runs = parseInt(p.runs);
          if (!isNaN(runs)) battingRuns.push(runs);
        }
      }
    }

    return {
      tossWinner,
      matchWinner: winnerAbbr,
      firstInningsScore,
      totalWickets,
      momTeam,
      matchEnded: true,
      secondInningsBatting: battingRuns,
    };
  } catch (e) {
    console.error("ESPN data failed:", (e as Error).message);
    return null;
  }
}

Deno.serve(async (_req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Find matches that started 3+ hours ago and have no actuals
    const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString();
    const { data: matches, error: matchErr } = await supabase
      .from("matches")
      .select("match_id, team1, team2, start_date_time, cric_api_id, espn_event_id")
      .lt("start_date_time", threeHoursAgo)
      .order("start_date_time", { ascending: true });

    if (matchErr) return new Response(JSON.stringify({ error: matchErr.message }), { status: 500 });

    const { data: existingActuals } = await supabase.from("actuals").select("match_id");
    const scoredIds = new Set((existingActuals || []).map((a: any) => a.match_id));
    const unscored = (matches || []).filter((m: MatchRow) => !scoredIds.has(m.match_id));

    if (unscored.length === 0) {
      return new Response(JSON.stringify({ message: "No unscored matches found", processed: 0 }));
    }

    const results: any[] = [];

    for (const match of unscored) {
      console.log(`Processing match ${match.match_id}: ${match.team1} vs ${match.team2}`);

      if (!match.espn_event_id) {
        results.push({ match_id: match.match_id, status: "skipped", reason: "No ESPN event ID mapped" });
        continue;
      }

      // Step 1: Get ESPN data (toss, winner, scores, MOM)
      const espn = await fetchEspnData(match.espn_event_id);
      if (!espn || !espn.matchEnded) {
        results.push({ match_id: match.match_id, status: "skipped", reason: espn ? "Match not ended yet" : "ESPN fetch failed" });
        continue;
      }

      // Step 2: Try CricData for full scorecard (highest individual score from both innings)
      let highestScore = 0;
      let highestScoreTied = false;
      let scorecardSource = "espn_partial";

      if (match.cric_api_id) {
        const cric = await fetchCricScorecard(match.cric_api_id);
        if (cric) {
          highestScore = cric.highestScore;
          highestScoreTied = cric.highestScoreTied;
          scorecardSource = "cricdata";
        }
      }

      // Fallback: use ESPN 2nd innings batting (partial data)
      if (scorecardSource !== "cricdata" && espn.secondInningsBatting.length > 0) {
        highestScore = Math.max(...espn.secondInningsBatting);
        highestScoreTied = espn.secondInningsBatting.filter((r) => r === highestScore).length >= 2;
        scorecardSource = "espn_2nd_innings_only";
      }

      const actual = {
        match_id: match.match_id,
        toss_winner: espn.tossWinner || match.team1,
        match_winner: espn.matchWinner,
        score: espn.firstInningsScore,
        total_wickets: espn.totalWickets,
        highest_score: highestScore,
        highest_score_tied: highestScoreTied,
        mom: espn.momTeam || espn.matchWinner,
      };

      const { error: upsertErr } = await supabase
        .from("actuals")
        .upsert(actual, { onConflict: "match_id" });

      if (upsertErr) {
        results.push({ match_id: match.match_id, status: "error", reason: `Insert failed: ${upsertErr.message}` });
        continue;
      }

      const { data: pointsData, error: pointsErr } = await supabase
        .rpc("calculate_match_points", { p_match_id: match.match_id });

      const scored = pointsData?.[0]?.predictions_scored ?? 0;

      results.push({
        match_id: match.match_id,
        status: "success",
        actual,
        predictions_scored: scored,
        scorecard_source: scorecardSource,
        ...(pointsErr && { points_error: pointsErr.message }),
      });

      console.log(`Match ${match.match_id} done: ${scored} predictions scored (source: ${scorecardSource})`);
    }

    return new Response(
      JSON.stringify({ message: `Processed ${results.length} match(es)`, results }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("Fatal error:", e);
    return new Response(JSON.stringify({ error: (e as Error).message }), { status: 500 });
  }
});
