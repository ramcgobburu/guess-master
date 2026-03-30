-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Store secrets in vault for safe access
SELECT vault.create_secret(
  'https://reznesnljluqtapihbkh.supabase.co',
  'project_url'
);

SELECT vault.create_secret(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlem5lc25samx1cXRhcGloYmtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0ODA4NzQsImV4cCI6MjA5MDA1Njg3NH0.Ja3kTTvhk4E3S2hsA0hE51msvJD-D65BIpqyTKVYyF4',
  'anon_key'
);

-- Schedule: every 20 minutes between 2 PM and 12 AM UTC (7:30 PM - 5:30 AM IST covers all match windows)
SELECT cron.schedule(
  'auto-fetch-match-results',
  '*/20 14-23 * 3-5 *',
  $$
  SELECT net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'project_url') || '/functions/v1/auto-fetch-results',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'anon_key')
    ),
    body := '{"source": "cron"}'::jsonb
  ) AS request_id;
  $$
);
