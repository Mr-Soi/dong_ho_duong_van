IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name='catch208') DROP EVENT SESSION catch208 ON SERVER;
CREATE EVENT SESSION catch208 ON SERVER
ADD EVENT sqlserver.error_reported(
  ACTION(sqlserver.sql_text,sqlserver.database_id,sqlserver.client_app_name,sqlserver.username)
  WHERE (error_number=208)
)
ADD TARGET package0.ring_buffer;
ALTER EVENT SESSION catch208 ON SERVER STATE=START;
