# Enable foreign key support in SQLite
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") if ActiveRecord::Base.connection.adapter_name == "SQLite"
