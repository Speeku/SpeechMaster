-- Fix foreign key constraint
-- Drop the incorrect constraint if it exists
ALTER TABLE "Performance_Report" DROP CONSTRAINT IF EXISTS "Performace_Report_session_id_fkey";
-- Create the correct constraint
ALTER TABLE "Performance_Report" ADD CONSTRAINT "Performance_Report_session_id_fkey" FOREIGN KEY (session_id) REFERENCES "Practice_Session"(id) ON DELETE CASCADE;
