--------------------------------------------------------------------------------------------------------
function GM:SetupDatabase()
	lia.db.module = "sqlite"
	lia.db.hostname = "127.0.0.1"
	lia.db.username = ""
	lia.db.password = ""
	lia.db.database = ""
	lia.db.port = 3306
end
--------------------------------------------------------------------------------------------------------