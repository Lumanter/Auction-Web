--//If you want drop the job
BEGIN
  dbms_scheduler.drop_job(job_name => 'update_Closed_Auctions');
END;

--//Job schedule update_Closed_Auctions
begin
dbms_scheduler.create_job (
   job_name           =>  'update_Closed_Auctions',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'updateClosedAuctions',
   start_date         => current_TIMESTAMP ,
   repeat_interval    =>  'FREQ=MINUTELY',
   enabled            =>  TRUE);
end;