/*
=======================================================================================
Create Databese and Schemas
=======================================================================================

Script Purpose:

This script creates a new databese named `Datawarehouse` after checking the if it already exisit.
If the database exists, it is dropped and recreated. Additionally the scrpt set up thress schemas 
within the database: `bronze` , `silver`, and 'gold'.

WARNING:

Runing this scrpt will drop the entire 'Datawarehouse' database if it exists.
All data in the database will be permanently deleted. proceed with caution
and ensure you have proper backups before runing this script.
*/


USE master;
GO

  --drop and create the 'Datawarehouse' database
  
IF EXISTS(SELECT 1 FROM sys.databeses WHERE name = 'Datawarehouse')
BEGIN
    ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Datawarehouse; --- delete the database
END;  --- checking weather database exists. if is exists, disconnect other users and delete it
GO

---create the'datawarehouse' database
  
Create DATABASE Datawarehouse;
GO


use datawarehouse
GO
  --create schemas
Create schema bronze
GO

Create schema silver;
GO
Create schema Gold
